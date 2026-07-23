rfst_aabb_precise = new AABB(bbox_left, bbox_right, bbox_top, bbox_bottom);

rfst_aabb_precise.data.entity = self;

rfst_aabb = new AABB(bbox_left - TREE_AABB_FUDGE,
                                          bbox_right + TREE_AABB_FUDGE,
										  bbox_top - TREE_AABB_FUDGE,
										  bbox_bottom + TREE_AABB_FUDGE);

rfst_aabb.data.entity = self;

// set this object's tree
rfst_my_tree = -1;

rfst_node = -1;

rand_angle = (time_seed() + random_range(0,359)) % 360;
moving = false;

xsp = 0;
ysp = 0;

alarm[0] = 1;

// hello!
numboxes++;
