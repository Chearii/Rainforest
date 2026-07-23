var timeseed = time_seed();

var i = 0;
var newbox;

var num_layout_moving = 0;
var num_layout_boxes = 512;

repeat(num_layout_boxes)
{
	newbox = instance_create_depth(random_range_timeseed(48, room_width - 48), random_range_timeseed(48, room_height - 48), depth, obj_treetest);
	newbox.rfst_my_tree = TREE_LAYOUT;
	
	if (i < num_layout_moving)
	{
		newbox.moving = true;
	}
	
	i++;
}


i = 0;

var num_entity_moving = 64;
var num_entity_boxes = num_entity_moving;

repeat(num_entity_boxes)
{
	newbox = instance_create_depth(random_range(48, room_width - 48), random_range(48, room_height - 48), depth - 1, obj_treetest);
	newbox.rfst_my_tree = TREE_ENTITIES;

	if (i < num_entity_moving)
	{
		newbox.moving = true;
	}

	i++;
}
