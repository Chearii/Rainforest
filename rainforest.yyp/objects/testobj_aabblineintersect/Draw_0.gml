var current_color = draw_get_colour();

var color_box = (imhit) ? color_hitting : color_nothitting;

draw_set_colour(color_box);
draw_rectangle(box.lower_bound.x,box.lower_bound.y,box.upper_bound.x,box.upper_bound.y,true);
draw_set_colour(current_color);

draw_line_colour(pt1.x,pt1.y,pt2.x,pt2.y,color_line,color_line);