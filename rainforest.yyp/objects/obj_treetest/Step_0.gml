if (point_in_rectangle(mouse_x, mouse_y,rfst_aabb.lower_bound.x,rfst_aabb.lower_bound.y,rfst_aabb.upper_bound.x,rfst_aabb.upper_bound.y))
{
	if (mouse_check_button_pressed(mb_middle))
	{
		// remove this box
		instance_destroy(self);
		return;
	}
}

if (abs(xsp) || abs(ysp)) // WHYYY ARE NEGATIVES CONSIDERED FALSE???
{
	if (rfst_my_tree != TREE_LAYOUT)
	{
		// scan through the layout tree via raycast
		var v1 = {x : self.x, y : self.y};
		var v2 = {x: v1.x + xsp, y: v1.y + ysp};
		aabb_tree_test_ray_cast(rfst_trees[TREE_LAYOUT], v1, v2);
		totaltreecost += ((rfst_trees[TREE_LAYOUT].colscan_end - rfst_trees[TREE_LAYOUT].colscan_start) / 1000);
	}

	rainforest_instance_move(xsp, ysp, self);
}

if (bbox_left <= 0)
{
	xsp = abs(xsp);
}
else if (bbox_right >= room_width)
{
	xsp = abs(xsp) * -1;	
}

if (bbox_top <= 0)
{
	ysp = abs(ysp);
}
else if (bbox_bottom >= room_height)
{
	ysp = abs(ysp) * -1;	
}
