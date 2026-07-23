color_nothitting = #ff0000;
color_hitting = #00ff00;
color_line = #ff00e1;

imhit = false;

pt1 = {x : 0, y : 0};
pt2 = {x : 0, y : 0};

pt1.x = x;
pt2.x = x + 16;
pt1.y = y;
pt2.y = y;

box = new AABB(-16, 2048, -16, 2048);