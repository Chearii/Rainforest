
// macros

#macro INT64_MAX 9223372036854775807
#macro INFINITY INT64_MAX

#macro TREE_AABB_FUDGE 32

// data types

// "LAYOUT" is a more generalized name than "SOLIDS";
// for a sec I forgot ladders existed :,)
#macro TREE_LAYOUT 0
#macro TREE_BRICKS 1
#macro TREE_ENTITIES 2

// global BVH; the final version will have THREE acting all at once
globalvar rfst_trees;
rfst_trees = [];

array_push(rfst_trees, new AABBTree()); // TREE_LAYOUT
array_push(rfst_trees, new AABBTree()); // TREE_BRICKS
array_push(rfst_trees, new AABBTree()); // TREE_ENTITIES

// functions

// "is this array empty?"
function array_is_empty(array)
{
    return (array_length(array) <= 0);
}

function assert(bool, failmsg = "assertion failure")
{
    if (!bool)
    {
        show_error(failmsg, true);
    }
}

function time_seed()
{
    var _date = date_current_datetime();
    return date_get_second_of_year(_date) + date_get_year(_date);
}

function random_range_timeseed(a, b)
{
    var rand = (irandom(0x7FFFFFFF) + time_seed()) & 0x7FFFFFFF;

    var lowest = (b < a) ? b : a;
    var range = (b < a) ? (a - b) : (b - a);

    rand = rand % range;

    return lowest + rand;
}

// FIXME: unique aabb handling
function rainforest_instance_update_aabb(obj = self)
{
    if (variable_instance_exists(obj, "rfst_aabb") && (obj.rfst_aabb_precise != undefined))
    {
        obj.rfst_aabb_precise.SetBounds(
            obj.bbox_left, obj.bbox_right, obj.bbox_top, obj.bbox_bottom);
    }
}

// generic mover, manages AABBs and tree logic for hassle-free work
function rainforest_instance_move(x_delta, y_delta, obj = self)
{

    // move ourselves
    // FIXME: tree sweep tests for collision (if needed)
    obj.x += x_delta;
    obj.y += y_delta;

    // update our AABB
    rainforest_instance_update_aabb(obj);

    var outside_fudged_aabb = false;

    // check if our precise box left our imprecise (tree) box
    if ((obj.rfst_aabb_precise.lower_bound.x < obj.rfst_aabb.lower_bound.x) ||
        (obj.rfst_aabb_precise.upper_bound.x > obj.rfst_aabb.upper_bound.x) ||
        (obj.rfst_aabb_precise.lower_bound.y < obj.rfst_aabb.lower_bound.y) ||
        (obj.rfst_aabb_precise.upper_bound.y > obj.rfst_aabb.upper_bound.y))
    {
        outside_fudged_aabb = true;
    }

    if (outside_fudged_aabb)
    {
        if (obj.rfst_my_tree >= 0)
        {
            // if we're in a tree, we're no longer in a tree :)
            if (obj.rfst_node >= 0)
            {
                aabb_tree_remove_leaf(rfst_trees[obj.rfst_my_tree], obj.rfst_node);
            }

            obj.rfst_aabb.SetBounds(obj.rfst_aabb_precise.lower_bound.x - TREE_AABB_FUDGE,
                                    obj.rfst_aabb_precise.upper_bound.x + TREE_AABB_FUDGE,
                                    obj.rfst_aabb_precise.lower_bound.y - TREE_AABB_FUDGE,
                                    obj.rfst_aabb_precise.upper_bound.y + TREE_AABB_FUDGE);

            // reinsert ourselves into our tree
            obj.rfst_node = aabb_tree_insert_leaf(rfst_trees[obj.rfst_my_tree], obj, obj.rfst_aabb);
        }
    }
}

globalvar numboxes, totaltreecost, raycastping;

numboxes = 0;

totaltreecost = 0;

raycastping = false;
