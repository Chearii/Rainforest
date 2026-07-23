imhit = aabb_test_overlap_wtih_line_from_vec2_bool(box, pt1, pt2);

if (mouse_check_button(mb_middle))
{
	if (mouse_check_button(mb_left))
        aabb_set_positions(box, box.lower_bound.x, box.lower_bound.y, mouse_x, mouse_y);
	else if (mouse_check_button(mb_right))
        aabb_set_positions(box, mouse_x, mouse_y, box.upper_bound.x, box.upper_bound.y);
}
else if (mouse_check_button(mb_left))
{
    pt1.x = mouse_x;
    pt1.y = mouse_y;
}
else if (mouse_check_button(mb_right))
{
    pt2.x = mouse_x;
    pt2.y = mouse_y;
}