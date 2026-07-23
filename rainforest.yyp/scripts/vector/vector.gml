function vec2_add(a, b)
{
    return {
        x : a.x + b.x,
        y : a.y + b.y
    };
}

function vec2_sub(a, b)
{
    return {
        x : a.x - b.x,
        y : a.y - b.y
    };
}

function vec2_mul_add(a, s, b)
{
    return {
        x : a.x + s * b.x,
        y : a.y + s * b.y
    };
}

// from box2d
// "Perform the cross product on a scalar and a vector. In 2D this produces a vector."
function vec2_cross_sv(s, v)
{
    return {
        x : -s * v.y,
        y : s * v.x
    };
}

function vec2_dot(a, b)
{
    return a.x * b.x + a.y * b.y;
}

function vec2_get_reciprocal(v)
{
    var mag = sqrt(v.x * v.x + v.y * v.y);

    if (mag == 0)
        return INFINITY;  // in IEEE, division by zero produces -inf or inf; this is an attempt to
                          // replicate that

    var inv = (1 / mag);

    return inv;
}

function vec2_normalize(v)
{
    var inv = vec2_get_reciprocal(v);

    if (inv == INFINITY) // division by zero or some SERIOUSLY unlucky edgecase
        return {x : INFINITY, y : INFINITY};

    var ret_v = {
        x : v.x * inv,
        y : v.y * inv,
    };

    return ret_v;
}

// from box2d
// "Get the length squared of this vector"
function vec2_length_squared(v)
{
    return (v.x * v.x) + (v.y * v.y);
}
