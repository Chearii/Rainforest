#macro ENTITY_NONE 0
#macro ENTITY_OBJECT 1

// a bounding box given a set of basic parameters

function AABB(left, right, top, bottom) constructor
{
    lower_bound =
    {
        x : left,
        y : top
    }

    upper_bound =
    {
        x : right,
        y : bottom
    }

    data = {
        origin : {
            x : (lower_bound.x + upper_bound.x) / 2,
            y : (lower_bound.y + upper_bound.y) / 2
        },
        radius : {
            x : (upper_bound.x - lower_bound.x) / 2,
            y : (upper_bound.y - lower_bound.y) / 2
        },
        entity : noone // can be anything, from an object ID, to another struct
    }

    static GetArea = function()
    {
        var d_x = upper_bound.x - lower_bound.x;
        var d_y = upper_bound.y - lower_bound.y;
        return (d_x * d_y);
    }

    static GetPerimeter = function()
    {
        var d_x = upper_bound.x - lower_bound.x;
        var d_y = upper_bound.y - lower_bound.y;
        return 2.0 * (d_x + d_y);
    }

    static Union = function(_a, _b)
    {
        assert((_a != undefined)||(_a != noone), "box A is invalid");
        assert(_a.lower_bound != undefined, "box A is invalid");
        assert((_b != undefined)||(_b != noone), "box B is invalid");
        assert(_b.lower_bound != undefined, "box B is invalid");

        lower_bound.x = min(_a.lower_bound.x, _b.lower_bound.x);
        lower_bound.y = min(_a.lower_bound.y, _b.lower_bound.y);

        upper_bound.x = max(_a.upper_bound.x, _b.upper_bound.x);
        upper_bound.y = max(_a.upper_bound.y, _b.upper_bound.y);
    }

    static Update = function()
    {
        data.origin.x = (lower_bound.x + upper_bound.x) / 2;
        data.origin.y = (lower_bound.y + upper_bound.y) / 2;

        data.radius.x = (upper_bound.x - lower_bound.x) / 2;
        data.radius.y = (upper_bound.y - lower_bound.y) / 2;
    }

    static SetBounds = function(left, right, top, bottom)
    {
        lower_bound.x = left;
        lower_bound.y = top;

        upper_bound.x = right;
        upper_bound.y = bottom;

        Update();
    }
}

// a bounding box from a union of bounding boxes A and B

function AABBUnion(_a, _b) constructor
{
    lower_bound =
    {
        x : min(_a.lower_bound.x, _b.lower_bound.x),
        y : min(_a.lower_bound.y, _b.lower_bound.y)
    }

    upper_bound =
    {
        x : max(_a.upper_bound.x, _b.upper_bound.x),
        y : max(_a.upper_bound.y, _b.upper_bound.y)
    }

    data = {
        origin : {
            x : (lower_bound.x + upper_bound.x) / 2,
            y : (lower_bound.y + upper_bound.y) / 2
        },
        radius : {
            x : (upper_bound.x - lower_bound.x) / 2,
            y : (upper_bound.y - lower_bound.y) / 2
        },
        entity : noone, // can be anything, from an object, to another struct
        entity_type : ENTITY_NONE
    }

    static GetArea = function()
    {
        var d_x = upper_bound.x - lower_bound.x;
        var d_y = upper_bound.y - lower_bound.y;
        return (d_x * d_y);
    }

    static GetPerimeter = function()
    {
        var d_x = upper_bound.x - lower_bound.x;
        var d_y = upper_bound.y - lower_bound.y;
        return 2.0 * (d_x + d_y);
    }

    static Union = function(_a, _b)
    {
        lower_bound.x = min(_a.lower_bound.x, _b.lower_bound.x);
        lower_bound.y = min(_a.lower_bound.y, _b.lower_bound.y);

        upper_bound.x = max(_a.upper_bound.x, _b.upper_bound.x);
        upper_bound.y = max(_a.upper_bound.y, _b.upper_bound.y);

        Update();
    }

    static Update = function()
    {
        data.origin.x = (lower_bound.x + upper_bound.x) / 2;
        data.origin.y = (lower_bound.y + upper_bound.y) / 2;

        data.radius.x = (upper_bound.x - lower_bound.x) / 2;
        data.radius.y = (upper_bound.y - lower_bound.y) / 2;
    }

    static SetBounds = function(left, right, top, bottom)
    {
        lower_bound.x = left;
        lower_bound.y = top;

        upper_bound.x = right;
        upper_bound.y = bottom;

        Update();
    }
}

function aabb_get_area(_box)
{
    var d_x = _box.upper_bound.x - _box.lower_bound.x;
    var d_y = _box.upper_bound.y - _box.lower_bound.y;
    return (d_x * d_y);
}

function aabb_set_positions(_box, l, t, r, b)
{
    _box.lower_bound.x = l;
    _box.lower_bound.y = t;
    _box.upper_bound.x = r;
    _box.upper_bound.y = b;

    _box.data.origin = {
        x : ( _box.lower_bound.x +  _box.upper_bound.x) / 2,
        y : ( _box.lower_bound.y +  _box.upper_bound.y) / 2
    };

    _box.data.radius = {
        x : ( _box.upper_bound.x -  _box.lower_bound.x) / 2,
        y : ( _box.upper_bound.y -  _box.lower_bound.y) / 2
    };
}

// from box2d; quik-n-dirty AABB discrete test
function aabb_test_overlap_with_aabb(a, b)
{
    return !((b.lower_bound.x > a.upper_bound.x) || (b.lower_bound.y > a.upper_bound.y) ||
             (a.lower_bound.x > b.upper_bound.x) || (a.lower_bound.y > b.upper_bound.y));
}

// tests if a line intersects with an AABB via the slabs test
// https://noonat.github.io/intersect/#intersection-tests
function aabb_test_overlap_wtih_line_from_vec2(_box, vec1, vec2, pad = {x : 0, y : 0})
{
    var line_delta = {
        x : vec2.x - vec1.x,
        y : vec2.y - vec1.y
    }

    var x_scale = 1.0 / line_delta.x;
    var y_scale = 1.0 / line_delta.y;
    var x_sign = sign(x_scale);
    var y_sign = sign(y_scale);
    var t_x_near = (_box.data.origin.x - x_sign * (_box.data.radius.x + pad.x) - vec1.x) * x_scale;
    var t_y_near = (_box.data.origin.y - y_sign * (_box.data.radius.y + pad.y) - vec1.y) * y_scale;
    var t_x_far = (_box.data.origin.x + x_sign * (_box.data.radius.x + pad.x) - vec1.x) * x_scale;
    var t_y_far = (_box.data.origin.y + y_sign * (_box.data.radius.y + pad.y) - vec1.y) * y_scale;

    // if the nearest collision time on one axis is ahead of the farthest collision time on the opposite axis, we're not colliding
    if (t_x_near > t_y_far || t_y_near > t_x_far)
    {
        return undefined;
    }

    var t_near = max(t_x_near, t_y_near);
    var t_far = min(t_x_far, t_y_far);

    // if our nearest time is ahead of 1.0, or our farthest time is below 0.0, we're not colliding
    if (t_near >= 1 || t_far <= 0)
    {
        return undefined;
    }

    var hit_time = clamp(t_near, 0, 1);

    var hit = {
        time : hit_time,
        normal : {
            x : (t_x_near > t_y_near) ? -x_sign : 0,
            y : (t_x_near > t_y_near) ? 0 : -y_sign
        },
        delta : {
            x : (1.0 - hit_time) * -line_delta.x,
            y : (1.0 - hit_time) * -line_delta.y
        },
        pos : {
            x : vec1.x + line_delta.x * hit_time, // vec1 + line_delta * hit_time
            y : vec1.y + line_delta.y * hit_time
        }
    };

    return hit;
}

// boolean version, so we're not constantly returning data if we don't need it
function aabb_test_overlap_wtih_line_from_vec2_bool(_box, vec1, vec2, pad = {x : 0, y : 0})
{
    var line_delta = {
        x : vec2.x - vec1.x,
        y : vec2.y - vec1.y
    }

    var x_scale = 1.0 / line_delta.x;
    var y_scale = 1.0 / line_delta.y;
    var x_sign = sign(x_scale);
    var y_sign = sign(y_scale);
    var t_x_near = (_box.data.origin.x - x_sign * (_box.data.radius.x + pad.x) - vec1.x) * x_scale;
    var t_y_near = (_box.data.origin.y - y_sign * (_box.data.radius.y + pad.y) - vec1.y) * y_scale;
    var t_x_far = (_box.data.origin.x + x_sign * (_box.data.radius.x + pad.x) - vec1.x) * x_scale;
    var t_y_far = (_box.data.origin.y + y_sign * (_box.data.radius.y + pad.y) - vec1.y) * y_scale;

    // if the nearest collision time on one axis is ahead of the farthest collision time on the opposite axis, we're not colliding
    if (t_x_near > t_y_far || t_y_near > t_x_far)
    {
        /*
        show_debug_message("collision time on opposite axis is faster; no collision");
        show_debug_message($"x_far: {t_x_far}, x_near: {t_x_near}");
        show_debug_message($"y_far: {t_y_far}, y_near: {t_y_near}");
        */
        return false;
    }

    var t_near = max(t_x_near, t_y_near);
    var t_far = min(t_x_far, t_y_far);

    // if our nearest time is ahead of 1.0, or our farthest time is below 0.0, we're not colliding
    if (t_near >= 1 || t_far <= 0)
    {
        //show_debug_message("collision times don't fit in bounds; no collision");
        //show_debug_message($"near: {t_near}, far: {t_far}");
        return false;
    }

    return true;
}

function aabb_test_ray_cast(_box, vec1, vec2)
{
    if (_box.data.entity != noone)
    {

    }

    // anything down here fell through; just do a basic AABB ray test
    return aabb_test_overlap_wtih_line_from_vec2_bool(_box, vec1, vec2);
}