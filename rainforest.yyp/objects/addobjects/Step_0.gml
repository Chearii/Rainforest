if (mouse_check_button_pressed(mb_left))
{
	var newbox = instance_create_depth(mouse_x, mouse_y, depth, obj_treetest);
	newbox.rfst_my_tree = TREE_ENTITIES;
}