// Cylinder with a centered hole. Units: millimetres.
// The hole opens at the top. Through bottom also opens the bottom face.
// Bottom margin is the floor thickness and is ignored when the hole goes through.
// Use F6 Render before exporting STL or 3MF.

/* [Hole] */
// Through bottom
through_bottom = true;
// Bottom margin, ignored when the hole goes through
hole_bottom_margin = 1; // [0:0.01:50]
// Diameter
hole_diameter = 5.15; // [0.2:0.01:50]

/* [Outer cylinder] */
// Diameter
outer_diameter = 10; // [0.4:0.01:100]
// Height
height = 6; // [0.2:0.01:100]

/* [Quality] */
// Circle segments
fn = 64; // [6:1:128]

/* [Hidden] */
eps = 0.02;

module cylinder_with_hole(
    outer_diameter,
    height,
    hole_diameter,
    through_bottom,
    hole_bottom_margin,
    fn,
    eps
) {
    assert(outer_diameter > 0 && height > 0, "Outer diameter and height must be > 0");
    assert(hole_diameter > 0, "Hole diameter must be > 0");
    assert(hole_diameter < outer_diameter, "Hole diameter must be smaller than the outer diameter");
    assert(hole_bottom_margin >= 0, "Hole bottom margin must be >= 0");
    assert(through_bottom || hole_bottom_margin > 0, "Blind hole needs a bottom margin greater than 0");
    assert(through_bottom || hole_bottom_margin < height, "Bottom margin must be less than the height");
    assert(fn >= 3, "Circle segments must be at least 3");

    difference() {
        cylinder(h = height, d = outer_diameter, $fn = fn);
        if (through_bottom)
            translate([0, 0, -eps])
                cylinder(h = height + 2 * eps, d = hole_diameter, $fn = fn);
        else
            translate([0, 0, hole_bottom_margin])
                cylinder(h = height - hole_bottom_margin + eps, d = hole_diameter, $fn = fn);
    }
}

cylinder_with_hole(
    outer_diameter,
    height,
    hole_diameter,
    through_bottom,
    hole_bottom_margin,
    fn,
    eps
);
