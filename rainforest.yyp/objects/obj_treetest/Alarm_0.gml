// setup tree data
if (rfst_my_tree >= 0)
{
	rfst_node = aabb_tree_insert_leaf(rfst_trees[rfst_my_tree], self, rfst_aabb);
}

var general_speed = 2.5;

if (moving)
{
	xsp = general_speed * cos(degtorad(rand_angle));
	ysp = general_speed * -sin(degtorad(rand_angle));
}