imhit = aabb_tree_test_ray_cast(rfst_trees[TREE_LAYOUT], pt1, pt2);
totaltreecost += ((rfst_trees[TREE_LAYOUT].colscan_end - rfst_trees[TREE_LAYOUT].colscan_start) / 1000);

if (mouse_check_button(mb_left))
{
    pt1.x = mouse_x;
    pt1.y = mouse_y;
}
else if (mouse_check_button(mb_right))
{
    pt2.x = mouse_x;
    pt2.y = mouse_y;
}