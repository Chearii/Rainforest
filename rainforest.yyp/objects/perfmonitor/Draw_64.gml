var _y = 16;

draw_text(16, _y, $"FPS: {fps}, Real FPS: {fps_real} (avg. per 16 tics: {realfps_avg})");
_y += 24;
draw_text(16, _y, $"Layout Tree Nodes: {rfst_trees[TREE_LAYOUT].node_count}\nLayout Tree Node Array Size: {array_length(rfst_trees[TREE_LAYOUT].nodes)}");
_y += 48;
draw_text(16, _y, $"Entities Tree Nodes: {rfst_trees[TREE_ENTITIES].node_count}\nEntities Tree Node Array Size: {array_length(rfst_trees[TREE_ENTITIES].nodes)}");
_y += 48;

var target_msec = 1000 / FPS_TARGET;

var cost_delta  = totaltreecost - target_msec;

draw_text(16, _y, $"Total objects: {numboxes}, Ray-cast cost: {totaltreecost}ms");
_y += 24;
draw_text(16, _y, $"{abs(cost_delta)}ms " + ((cost_delta > 0) ? "slower" : "faster" ) + $" than target of {target_msec}ms");
_y += 24;
draw_text(16, _y, "Collision? " + ((raycastping) ? "Yes" : "No"));