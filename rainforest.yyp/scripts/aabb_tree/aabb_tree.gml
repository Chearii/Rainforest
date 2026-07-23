// an AABB BVH tree, based heavily on erin catto's implementation,
// and Sopiro's TypeScript implementation: https://github.com/Sopiro/DynamicBVH/tree/master
//

// a bounding box with no needed parameters

function NullAABBTreeNode() constructor
{
    _id = -1;
    box = undefined;
    //obj_index = noone; // the box itself contains object data (entity field)
    parent_index = noone;
    child_1 = noone;
    child_2 = noone;

    height = 0;
    is_leaf = true;

    lonely = false;
}

// the node struct

function AABBTreeNode(_box, _parent_id, _is_leaf) constructor
{
    _id = -1;
    box = _box;
    parent_index = _parent_id;
    child_1 = noone;
    child_2 = noone;

    height = 0;
    is_leaf = _is_leaf;

    lonely = false;
}

// the tree struct

function aabb_tree_alloc_node(tree, node)
{
    if (node._id >= tree.node_count)
    {
        // we need a new index for this node
        array_push(tree.nodes, node);
    }
    else
    {
        // find a suitable lonely node

        assert(array_length(tree.lonely_nodes), "loneliness queue is empty!");

        node._id = array_pop(tree.lonely_nodes);

        nodes[node._id] = node;
        nodes[node._id].lonely = false;
    }
}

function AABBTree() constructor
{
    nodes = [];

    // queue for "lonely nodes"; nodes still available in the tree that aren't being used
    lonely_nodes = [];

    node_count = 0;
    root_index = noone;

    // performance monitoring
    colscan_start = 0;
    colscan_end = 0;

    static AllocateInternalNode = function(node)
    {
        if (node._id >= array_length(nodes))
        {
            // we need a new index for this node
            array_push(nodes, node);
        }
        else
        {
            // find a suitable lonely node

            assert(array_length(lonely_nodes), "loneliness queue is empty!");

            node._id = array_pop(lonely_nodes);

            nodes[node._id] = node;
            nodes[node._id].lonely = false;
        }
    }

    static InsertNode = function(_node)
    {
        _node._id = node_count;

        AllocateInternalNode(_node);

        _node = nodes[_node._id];

        node_count++;

        return _node._id;
    }

    static AllocateLeafNode = function(obj, box)
    {
        var _node = new AABBTreeNode(box, noone, true);

        _node.box.entity = obj;

        _node._id = node_count;

        AllocateInternalNode(_node);

        _node = nodes[_node._id];

        node_count++;

        return _node._id;
    }

    static CreateNullNode = function()
    {
        var _node = new AABBTreeNode(undefined, noone, true);

        _node._id = node_count;

        AllocateInternalNode(_node);

        _node = nodes[_node._id];

        node_count++;

        return _node._id;
    }

    // calculate the tree's cost via a surface-area function
    static ComputeCost = function()
    {
        var cost = 0.0;
        var i = 0;

        repeat(node_count)
        {
            // pre-increment for-loop originally, so we gotta increment i first
            i++;

            if (i >= node_count)
            {
                break; // because you never know...
            }

            if (!nodes[i].is_leaf) // we don't care about leaves
            {
                cost += nodes[i].box.GetArea();
            }
        }

        return cost;
    }

    // from box2d, modified to fit rainforest's systems
    static PickBest = function(insert_node)
    {
        //show_debug_message($"root: {root_index}");

        // generic union that gets repurposed constantly
        var _combined = new AABBUnion(nodes[root_index].box, insert_node.box);

        // I doubt these change mid function
        var center_d = insert_node.box.data.origin;
        var insert_area = insert_node.box.GetArea();
        var root_area = nodes[root_index].box.GetArea();

        var direct_cost = _combined.GetArea();
        var inherit_cost = 0;

        var best_sibling = root_index;
        var best_cost = direct_cost;
        var current_cost = 0;

        /*
        var _Q = [];

        array_push(_Q, root_index);  // init with the first node inside
        */

        var index = root_index;

        var stuck = 0;

        while (!nodes[index].is_leaf)
        {
            // since we can't possibly scan EVERY node...
            assert(stuck <= node_count, "PickBest infinitely looped");

            current_cost = 0;
            //var index = array_pop(_Q);

            /*
            PARANOIA (uncomment if needed):
            assert(!nodes[index].lonely, $"given node ({index}) is a lonely node!");
            */

            var child1 = nodes[index].child_1;
            var child2 = nodes[index].child_2;

            current_cost = direct_cost + inherit_cost;

            if (current_cost < best_cost)
            {
                best_cost = current_cost;
                best_sibling = index;
            }

            // Inheritance cost seen by children
            inherit_cost += direct_cost - root_area;

            var leaf1 = nodes[child1].is_leaf;
            var leaf2 = nodes[child2].is_leaf;

            // Cost of descending into child 1
            var lower_cost1 = INFINITY;
            _combined.Union(nodes[child1].box, insert_node.box);
            var direct_cost1 = _combined.GetArea();
            var area1 = 0.0;

            if (leaf1)
            {
                // Child 1 is a leaf
                // Cost of creating new node and increasing area of node P
                var cost1 = direct_cost1 + inherit_cost;

                // Need this here due to while condition above
                if (cost1 < best_cost)
                {
                    best_sibling = child1;
                    best_cost = cost1;
                }
            }
            else
            {
                // Child 1 is an internal node
                area1 = nodes[child1].box.GetArea();

                // Lower bound cost of inserting under child 1. The minimum accounts for two possibilities:
                // 1. Child1 could be the sibling with cost1 = inheritedCost + directCost1
                // 2. A descendant of child1 could be the sibling with the lower bound cost of
                //       cost1 = inheritedCost + (directCost1 - area1) + areaD
                // This minimum here leads to the minimum of these two costs.
                lower_cost1 = inherit_cost + direct_cost1 + min(insert_area - area1, 0.0);
            }

            // Cost of descending into child 2
            var lower_cost2 = INFINITY;
            _combined.Union(nodes[child2].box, insert_node.box);
            var direct_cost2 = _combined.GetArea();
            var area2 = 0.0;
            if (leaf2)
            {
                var cost2 = direct_cost2 + inherit_cost;

                if (cost2 < best_cost)
                {
                    best_sibling = child2;
                    best_cost = cost2;
                }
            }
            else
            {
                area2 = nodes[child2].box.GetArea();
                lower_cost2 = inherit_cost + direct_cost2 + min(insert_area - area2, 0.0);
            }

            if (leaf1 && leaf2)
            {
                //show_debug_message($"called at {current_time}: both nodes are leaves; early-exiting loop");
                break;
            }

            // Can the cost possibly be decreased?
            if ((best_cost <= lower_cost1) && (best_cost <= lower_cost2))
            {
                //show_debug_message($"called at {current_time}: cost cannot be decreased further; early-exiting loop");
                break;
            }

            if ((lower_cost1 == lower_cost2) && (leaf1 == false))
            {
                assert(lower_cost1 < INFINITY, "lower_cost1 exceeds infinity");
                assert(lower_cost2 < INFINITY, "lower_cost2 exceeds infinity");

                // No clear choice based on lower bound surface area. This can happen when both
                // children fully contain D. Fall back to node distance.
                var d1 = vec2_sub(nodes[child1].box.data.origin, center_d);
                var d2 = vec2_sub(nodes[child2].box.data.origin, center_d);
                lower_cost1 = vec2_length_squared(d1);
                lower_cost2 = vec2_length_squared(d2);
            }

            // Descend
            if ((lower_cost1 < lower_cost2) && (!leaf1))
            {
                index = child1;
                root_area = area1;
                direct_cost = direct_cost1;
            }
            else
            {
                index = child2;
                root_area = area2;
                direct_cost = direct_cost2;
            }

            assert(!nodes[index].is_leaf, $"at end of loop operation: node {index} is a leaf");
        }

        // clean up our mess
        delete _combined;

        // if we find a best sibling, return it
        return best_sibling;
    }

    static Rotate = function(node_index)
    {
        var this_node = nodes[node_index];

        // generic union that gets repurposed constantly
        var _combined = new AABB(0, 1, 0, 1);

        var child1 = nodes[this_node.child_1];
        var child2 = nodes[this_node.child_2];

        var cost_diffs = [0, 0, 0, 0];

        if (!child1.is_leaf)
        {
            var area1 = child1.box.GetArea();
            _combined.Union(nodes[child1.child_1].box, child2.box);
            cost_diffs[0] = _combined.GetArea() - area1;

            _combined.Union(nodes[child1.child_2].box, child2.box);
            cost_diffs[1] = _combined.GetArea() - area1;
        }

        if (!child2.is_leaf)
        {
            var area2 = child2.box.GetArea();
            _combined.Union(nodes[child2.child_1].box, child1.box);
            cost_diffs[2] = _combined.GetArea() - area2;

            _combined.Union(nodes[child2.child_2].box, child1.box);
            cost_diffs[3] = _combined.GetArea() - area2;
        }

        var best_diff_idx = 0;
        var i = 1;
        repeat(3) // for loop from i = 1 to 1 = 3
        {
            if (cost_diffs[i] < cost_diffs[best_diff_idx])
            {
                best_diff_idx = i;
            }
            i++;
        }

        // only rotate if it reduces our surface area!
        if (cost_diffs[best_diff_idx] >= 0)
        {
            delete _combined;
            return;
        }

        var c1, c2;

        //show_debug_message($"best diff index: {best_diff_idx}");

        if (best_diff_idx == 0)
        {
            nodes[child1.child_2].parent_index = this_node._id;
            nodes[node_index].child_2 = child1.child_2;

            nodes[child1._id].child_2 = child2._id;
            nodes[child2._id].parent_index = child1._id;

            c2 = nodes[child1._id].child_2;

            nodes[child1._id].box.Union(nodes[child1.child_1].box, nodes[c2].box);
        }
        else if (best_diff_idx == 1)
        {
            nodes[child1.child_1].parent_index = this_node._id;
            nodes[node_index].child_2 = child1.child_1;

            nodes[child1._id].child_1 = child2._id;
            nodes[child2._id].parent_index = child1._id;

            c1 = nodes[child1._id].child_1;

            nodes[child1._id].box.Union(nodes[c1].box, nodes[child1.child_2].box);
        }
        else if (best_diff_idx == 2)
        {
            nodes[child2.child_2].parent_index = this_node._id;
            nodes[node_index].child_1 = child2.child_2;

            nodes[child2._id].child_2 = child1._id;
            nodes[child1._id].parent_index = child2._id;

            c2 = nodes[child2._id].child_2;

            nodes[child2._id].box.Union(nodes[child2.child_1].box, nodes[c2].box);
        }
        else if (best_diff_idx == 3)
        {
            nodes[child2.child_1].parent_index = this_node._id;
            nodes[node_index].child_1 = child2.child_1;

            nodes[child2._id].child_1 = child1._id;
            nodes[child1._id].parent_index = child2._id;

            c1 = nodes[child2._id].child_1;

            nodes[child2._id].box.Union(nodes[c1].box, nodes[child2.child_2].box);
        }

        // clean up our mess
        delete _combined;
    }

    static ClearNodes = function()
    {
        array_resize(nodes, 0);
        array_resize(lonely_nodes, 0);
    }

    // does a FULL RESET of the tree; use at your own risk!
    // should likely only be used for room transitions
    static Reset = function()
    {
        array_resize(nodes, 0);
        array_resize(lonely_nodes, 0);

        node_count = 0;
        root_index = noone;
    }
}

#macro FPS_TARGET 120

function aabb_tree_test_ray_cast(tree, vec1, vec2)
{
    if (tree.node_count < 1)
    {
        // we outta nodes
        show_debug_message("no collision found; tree is empty");
        return false;
    }

    // box2d optimizations

    var delta = {
        x : vec2.x - vec1.x,
        y : vec2.y - vec1.y
    };

    var delta_nrm = vec2_normalize(delta);

    // v is perpendicular to the segment.
    var v = vec2_cross_sv(1.0, delta_nrm);
    var abs_v = {
        x : abs(v.x),
        y : abs(v.y)
    };

    // build an AABB that represents the line segment
    // { b2Min( p1, p2 ), b2Max( p1, p2 ) }
    var ray_box = new AABB(
        min(vec1.x, vec2.x), max(vec1.x, vec2.x), min(vec1.y, vec2.y), max(vec1.y, vec2.y));

    var stack = [];
    array_push(stack, tree.root_index);

    var fps_to_msec = (1000 / FPS_TARGET);
    tree.colscan_start = get_timer();

    var iter = 0;
    while (!array_is_empty(stack))
    {
        iter++;
        var index = array_shift(stack);

        if (index < 0)
        {
            //show_debug_message($"in loop: node isn't valid or nonexistent ({index}); continuing");
            continue;
        }

        if (aabb_test_overlap_with_aabb(tree.nodes[index].box, ray_box) == false)
        {
            // our Big Stupid First Box doesn't hit this node's box; no collision
            //show_debug_message("in loop: boxes don't overlap with initial broad test; continuing");
            continue;
        }

        // Separating axis for segment (Gino, p80).
        // |dot(v, p1 - c)| > dot(|v|, h)
        // radius extension is added to the node in this case
        var c = tree.nodes[index].box.data.origin;
        var h = tree.nodes[index].box.data.radius;
        var term1 = abs(vec2_dot(v, vec2_sub(vec1, c)));
        var term2 = vec2_dot(abs_v, h);

        if (term2 < term1)
        {
            //show_debug_message("in loop: boxes don't overlap with line; continuing");
            //show_debug_message($"box dimensions: [l: {tree.nodes[index].box.lower_bound.x}, r: {tree.nodes[index].box.upper_bound.x} t: {tree.nodes[index].box.lower_bound.y}, b: {tree.nodes[index].box.upper_bound.y}]");
            //show_debug_message($"line spans from v1: [{vec1.x}, {vec1.y}] to v2: [{vec2.x}, {vec2.y}]");
            continue;
        }

        if (tree.nodes[index].is_leaf)
        {
            // use the precise box
            var _node_box = (tree.nodes[index].box.data.entity)
                                ? tree.nodes[index].box.entity.rfst_aabb_precise
                                : tree.nodes[index].box;

            //show_debug_message("in loop: node is leaf, testing collision...");

            if (aabb_test_ray_cast(_node_box, vec1, vec2))
            {
                tree.colscan_end = get_timer();

                // well, we made it this far...
                raycastping = true;

                //var scan_msec = (tree.colscan_end - tree.colscan_start) / 1000;
                //var msec_diff = (scan_msec - fps_to_msec);
                //show_debug_message($"collision found; took {iter} iterations and {scan_msec} msec ({abs(msec_diff)} " + ((msec_diff > 0) ? "slower" : "faster") + $" than {fps_to_msec})");

                delete ray_box;
                return true;
            }
        }
        else
        {
            //show_debug_message("in loop: node has children; pushing to stack...");
            array_push(stack, tree.nodes[index].child_1);
            array_push(stack, tree.nodes[index].child_2);
        }
    }

    tree.colscan_end = get_timer();
    //var scan_msec = (tree.colscan_end - tree.colscan_start) / 1000;
    //var msec_diff = (scan_msec - fps_to_msec);

    //show_debug_message($"no collision found; took {iter} iterations and {scan_msec} msec ({abs(msec_diff)} " + ((msec_diff > 0) ? "slower" : "faster") + $" than {fps_to_msec})");

    delete ray_box;
    return false;
}

function aabb_tree_insert_leaf(tree, obj, box)
{
    var tree_nodes = tree.node_count; // allocating ANY node causes a size update, so let's do this

    var leafIndex = tree.AllocateLeafNode(obj, box);

    if (tree_nodes == 0)
    {
        tree.root_index = leafIndex;
        return leafIndex;
    }

    // Stage 1: find the best sibling for the new leaf

    var bestSibling = tree.PickBest(tree.nodes[leafIndex]);

    // sibling IS bestSibling... I think

    // Stage 2: create a new parent
    var oldParent = tree.nodes[bestSibling].parent_index;
    var newParent = tree.CreateNullNode();

    assert(newParent != bestSibling,
        "new parent is identical to best sibling; data would be overwritten!");
    assert(tree.nodes[bestSibling].box != undefined,
        $"aabb_tree_insert_leaf: best sibling ({bestSibling}) has no bounding box!");

    tree.nodes[newParent].parent_index = oldParent;
    tree.nodes[newParent].box = new AABBUnion(box, tree.nodes[bestSibling].box);
    tree.nodes[newParent].height = tree.nodes[bestSibling].height + 1;
    tree.nodes[newParent].is_leaf = false; // theoretically impossible for the new parent's height to be 0

    if (oldParent != noone)
    {
        // The sibling was not the root
        if (tree.nodes[oldParent].child_1 == bestSibling)
        {
            tree.nodes[oldParent].child_1 = newParent;
        }
        else
        {
            tree.nodes[oldParent].child_2 = newParent;
        }

        tree.nodes[newParent].child_1 = bestSibling;
        tree.nodes[newParent].child_2 = leafIndex;
        tree.nodes[bestSibling].parent_index = newParent;
        tree.nodes[leafIndex].parent_index = newParent;
    }
    else
    {
        // The sibling was the root
        tree.nodes[newParent].child_1 = bestSibling;
        tree.nodes[newParent].child_2 = leafIndex;
        tree.nodes[bestSibling].parent_index = newParent;
        tree.nodes[leafIndex].parent_index = newParent;
        tree.root_index = newParent;
    }

    // Stage 3: walk back up the tree refitting AABBs and applying rotations
    var index = tree.nodes[leafIndex].parent_index;
    var stuck = 0; // paranoia failsafe
    var tree_size = tree.node_count;

    var child1, child2;

    while (index != noone)
    {
        if (stuck >= tree_size)
        {
            // we've processed more nodes than there are in this tree; we got stuck!
            show_error(
                "aabb_tree_insert_leaf infinitely looped trying to walk up the tree.", true);
            break;
        }

        child1 = tree.nodes[index].child_1;
        child2 = tree.nodes[index].child_2;

        tree.nodes[index].box.Union(tree.nodes[child1].box, tree.nodes[child2].box);
        tree.nodes[index].height = 1 + max(tree.nodes[child1].height, tree.nodes[child2].height);

        // rotate the tree
        tree.Rotate(index);

        index = tree.nodes[index].parent_index;

        stuck++;
    }

    return leafIndex;
}

function aabb_tree_remove_leaf(tree, leaf_id)
{
    var parent = tree.nodes[leaf_id].parent_index;

    // node is root
    if (parent == noone)
    {
        assert(tree.root_index == leaf_id,
            $"leaf ID to delete ({leaf_id}) is not the root ({tree.root_index})");
        tree.root_index = noone;

        // remove or make lonely the node from the nodes array
        if (leaf_id >= (array_length(tree.nodes) - 1))
        {
            array_delete(tree.nodes, leaf_id, 1);
        }
        else
        {
            delete tree.nodes[leaf_id].box;

            tree.nodes[leaf_id]._id = -1;
            tree.nodes[leaf_id].box = undefined;
            tree.nodes[leaf_id].parent_index = noone;
            tree.nodes[leaf_id].child_1 = noone;
            tree.nodes[leaf_id].child_2 = noone;
            tree.nodes[leaf_id].is_leaf = true;
            tree.nodes[leaf_id].lonely = true;

            array_push(tree.lonely_nodes, leaf_id);
        }

        // recalculate tree size
        tree.node_count--;

        if (tree.node_count <= 0)
        {
            // empty the nodes array, there's nothing in the tree!
            tree.ClearNodes();
            tree.node_count = 0;
        }
        return;
    }

    var grand_parent = tree.nodes[parent].parent_index;
    var sibling = (tree.nodes[parent].child_1 == leaf_id) ? tree.nodes[parent].child_2
                                                          : tree.nodes[parent].child_1;

    // node has grandparent
    if (grand_parent != noone)
    {
        tree.nodes[sibling].parent_index = grand_parent;
        if (tree.nodes[grand_parent].child_1 == parent)
        {
            tree.nodes[grand_parent].child_1 = sibling;
        }
        else
        {
            tree.nodes[grand_parent].child_2 = sibling;
        }

        var ancestor = grand_parent;
        var stuck = 0; // paranoia failsafe
        var tree_size = tree.node_count;

        while (ancestor != noone)
        {
            if (stuck >= tree_size)
            {
                // we've processed more nodes than there are in this tree; we got stuck!
                show_error("aabb_tree_remove_leaf infinitely looped trying to walk up the tree.",
                           true);
                break;
            }

            var _child1 = tree.nodes[ancestor].child_1;
            var _child2 = tree.nodes[ancestor].child_2;

            tree.nodes[ancestor].box.Union(tree.nodes[_child1].box, tree.nodes[_child2].box);
            tree.nodes[ancestor].height = 1 + max(tree.nodes[_child1].height, tree.nodes[_child2].height);

            tree.Rotate(ancestor);

            ancestor = tree.nodes[ancestor].parent_index;

            stuck++;
        }
    }
    else
    {
        tree.root_index = sibling;
        tree.nodes[sibling].parent_index = noone;
    }

    // remove the node and its parent from the nodes array

    // so, we can't safely remove nodes in the middle of the array from the array without causing
    // out-of-range errors
    // BUT, we *also* can't just leave unused nodes hogging up data in the codebase
    // so let's just tell the garbage collector to delete them

    if (tree.nodes[leaf_id].parent_index >= (array_length(tree.nodes) - 1))
    {
        array_delete(tree.nodes, tree.nodes[leaf_id].parent_index, 1);
    }
    else
    {
        delete tree.nodes[tree.nodes[leaf_id].parent_index].box;

        // make this node lonely by making it completely null
        tree.nodes[tree.nodes[leaf_id].parent_index]._id = -1;
        tree.nodes[tree.nodes[leaf_id].parent_index].box = undefined;
        tree.nodes[tree.nodes[leaf_id].parent_index].parent_index = noone;
        tree.nodes[tree.nodes[leaf_id].parent_index].child_1 = noone;
        tree.nodes[tree.nodes[leaf_id].parent_index].child_2 = noone;
        tree.nodes[tree.nodes[leaf_id].parent_index].is_leaf = true;
        tree.nodes[tree.nodes[leaf_id].parent_index].lonely = true;

        array_push(tree.lonely_nodes, tree.nodes[leaf_id].parent_index);
    }

    if (leaf_id >= (array_length(tree.nodes) - 1))
    {
        array_delete(tree.nodes, leaf_id, 1);
    }
    else
    {
        delete tree.nodes[leaf_id].box;

        tree.nodes[leaf_id]._id = -1;
        tree.nodes[leaf_id].box = undefined;
        tree.nodes[leaf_id].parent_index = noone;
        tree.nodes[leaf_id].child_1 = noone;
        tree.nodes[leaf_id].child_2 = noone;
        tree.nodes[leaf_id].is_leaf = true;
        tree.nodes[leaf_id].lonely = true;

        array_push(tree.lonely_nodes, leaf_id);
    }

    // recalculate tree size
    tree.node_count -= 2;

    if (tree.node_count <= 0)
    {
        // empty the nodes array, there's nothing in the tree!
        tree.ClearNodes();
        tree.node_count = 0;
    }
}
