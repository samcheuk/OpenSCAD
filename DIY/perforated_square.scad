// Perforated square plate. Units: millimetres.
// Holes pass through the plate. Odd rows are offset by half of spacing X.
// Padding is the minimum distance from the plate edge to a hole edge.
// Holes that do not fit are omitted, and the grid is centered.
// Densest honeycomb: spacing Y = spacing X * 0.866, with both spacings greater than the diameter.
// Use F6 Render before exporting STL or 3MF.

/* [Plate] */
// Side length
plate_size = 100; // [1:0.1:500]
// Thickness
plate_height = 3; // [0.2:0.1:50]
// Padding
padding = 3; // [0:0.1:200]

/* [Holes] */
// Diameter
hole_diameter = 5; // [0.2:0.1:200]
// Spacing X, center to center along a row
spacing_x = 6; // [0.2:0.1:200]
// Spacing Y, center to center between rows
spacing_y = 5.2; // [0.2:0.1:200]

/* [Quality] */
// Circle segments
fn = 32; // [6:1:128]

/* [Hidden] */
eps = 0.02;
max_holes = 4000;

function center_span(plate_size, padding, hole_diameter) =
    plate_size - 2 * padding - hole_diameter;

function hole_centers(plate_size, padding, hole_diameter, spacing_x, spacing_y) =
    let (
        span = center_span(plate_size, padding, hole_diameter),
        n_x = floor(span / spacing_x) + 1,
        n_y = floor(span / spacing_y) + 1,
        lo = padding + hole_diameter / 2,
        hi = lo + span,
        x0 = lo + (span - (n_x - 1) * spacing_x) / 2,
        y0 = lo + (span - (n_y - 1) * spacing_y) / 2
    )
    [
        for (iy = [0 : n_y - 1], ix = [0 : n_x - 1])
            let (
                stagger = (iy % 2) * (n_x > 1 ? spacing_x / 2 : 0),
                x = x0 + ix * spacing_x + stagger
            )
            if (x >= lo - 0.000001 && x <= hi + 0.000001)
                [x, y0 + iy * spacing_y]
    ];

module perforated_plate(
    plate_size,
    plate_height,
    padding,
    hole_diameter,
    spacing_x,
    spacing_y,
    fn,
    eps,
    max_holes
) {
    span = center_span(plate_size, padding, hole_diameter);
    n_x = floor(span / spacing_x) + 1;
    n_y = floor(span / spacing_y) + 1;
    centers = hole_centers(plate_size, padding, hole_diameter, spacing_x, spacing_y);

    assert(plate_size > 0 && plate_height > 0, "Side length and thickness must be > 0");
    assert(padding >= 0, "Padding must be >= 0");
    assert(hole_diameter > 0, "Diameter must be > 0");
    assert(spacing_x > 0 && spacing_y > 0, "Spacing must be > 0");
    assert(fn >= 3, "Circle segments must be at least 3");
    assert(span >= 0, "Plate cannot fit one hole: reduce padding or diameter, or increase the side length");
    assert(n_x * n_y <= max_holes, "Too many holes: increase spacing or reduce the plate size");
    assert(len(centers) > 0, "No hole fits: reduce padding or diameter");

    difference() {
        cube([plate_size, plate_size, plate_height]);
        for (p = centers)
            translate([p[0], p[1], -eps])
                cylinder(h = plate_height + 2 * eps, d = hole_diameter, $fn = fn);
    }
}

perforated_plate(
    plate_size,
    plate_height,
    padding,
    hole_diameter,
    spacing_x,
    spacing_y,
    fn,
    eps,
    max_holes
);
