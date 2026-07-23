
var current_color = draw_get_colour();

var color_box = #00ff00;

draw_sprite(sprite_index, image_index, x, y);

draw_set_colour(color_box);
draw_rectangle(rfst_aabb_precise.lower_bound.x,rfst_aabb_precise.lower_bound.y,rfst_aabb_precise.upper_bound.x,rfst_aabb_precise.upper_bound.y,true);

//draw_set_colour(#ff0000);
//draw_rectangle(rfst_aabb.lower_bound.x,rfst_aabb.lower_bound.y,rfst_aabb.upper_bound.x,rfst_aabb.upper_bound.y,true);

draw_set_colour(c_blue);

if ((rfst_node >= 0))
{
	var _node = rfst_trees[rfst_my_tree].nodes[rfst_node];
	if  (_node.parent_index != noone)
	{
		var _box = rfst_trees[rfst_my_tree].nodes[_node.parent_index].box;

		draw_rectangle(_box.lower_bound.x,_box.lower_bound.y,_box.upper_bound.x,_box.upper_bound.y,true);
	}
}

draw_set_colour(current_color);
