// SKADIS tablet corner set. Units: millimetres.
// Four corners: top left, top right, bottom left, bottom right.
// The outer edge of each L is the outer edge of the part.
// Hooks are part of the back. Each hook is a round bar that passes
// through a SKADIS slot and turns down behind the 5 mm board.
// Hooks sit in the middle of the holder, on the 40 mm pitch.
// Two side by side need the bar to stay on the holder, about 45 mm wide.
// Otherwise another hook is added above and below when the height allows.
// One thickness covers the wall, shelf, edge, outer holder, and back.
// The horizontal front capture is as wide as the holder.
// The vertical front capture is as tall as the holder.
// Left and right hooks share one grid. Export the print layout after F6.

/* [Tablet] */
// Width
tablet_width = 180; // [40:0.1:400]
// Height
tablet_height = 250; // [40:0.1:400]
// Thickness, include a case
tablet_thickness = 7; // [1:0.1:30]

/* [L holder] */
// Width along the top or bottom edge
holder_width = 42; // [20:0.1:160]
// Height along the side edge
holder_height = 36; // [16:0.1:160]
// Wall, shelf, edge, outer holder, and back thickness
holder_thickness = 2; // [0.8:0.1:8]
// Vertical front capture, overlap onto the device
capture_x = 8; // [1:0.1:40]
// Horizontal front capture, overlap onto the device
capture_y = 8; // [1:0.1:40]
// Side wall, top left
side_wall_top_left = true;
// Side wall, bottom left
side_wall_bottom_left = true;
// Side wall, top right
side_wall_top_right = true;
// Side wall, bottom right
side_wall_bottom_right = true;

/* [View] */
// Layout
layout = "print"; // [print, assembly]

/* [Hidden] */
eps = 0.02;
pocket_clearance = 1;
thickness_clearance = 0.8;
// Standard SKADIS. Not a Customizer parameter.
pitch = 40;
board_thickness = 5;
slot_w = 5;
// Bar is narrower than the 5 mm hole.
hook_clear = 0.6;
tongue_r = (slot_w - hook_clear) / 2;
board_gap = 0.4;
chin_drop = 10;
hook_fn = 24;
print_gap = 12;

function side_on(x_sign, z_sign) =
    x_sign < 0
        ? (z_sign < 0 ? side_wall_bottom_left : side_wall_top_left)
        : (z_sign < 0 ? side_wall_bottom_right : side_wall_top_right);

function bar() = holder_thickness;

function x_margin() = tongue_r;

// The catch hangs below the slot, so the lower inset keeps it off the bed.
function z_lo() = chin_drop + tongue_r + 0.2;

function z_hi() = holder_height - tongue_r;

function gap_side() = pocket_clearance / 2;

function left_bar() =
    (side_wall_top_left || side_wall_bottom_left) ? bar() : 0;

function right_bar() =
    (side_wall_top_right || side_wall_bottom_right) ? bar() : 0;

function tablet_x0() = left_bar() + gap_side();

function tablet_z0() = bar() + gap_side();

function tablet_x1() = tablet_x0() + tablet_width;

function tablet_z1() = tablet_z0() + tablet_height;

function base_right_outer() = tablet_x1() + gap_side() + right_bar();

function fit_cols() =
    let (span = holder_width - 2 * x_margin())
        span < -0.01 ? 0 : floor(span / pitch) + 1;

function fit_rows() =
    let (span = z_hi() - z_lo())
        span < -0.01 ? 0 : floor(span / pitch) + 1;

// Side by side when two bars fit on the width. Otherwise one centred column.
function hook_cols() = fit_cols() >= 2 ? fit_cols() : 1;

// Top and bottom when the width cannot hold two hooks and the height can.
function hook_rows() = fit_cols() >= 2 ? fit_rows() : max(fit_rows(), 1);

// Air between the holders so their hooks share one SKADIS grid.
// The printed L does not grow.
function grid_extra_x() =
    let (
        n = max(hook_cols(), 1),
        span = (n - 1) * pitch,
        lo_a = x_margin(),
        hi_a = holder_width - x_margin(),
        ro = base_right_outer(),
        lo_b = ro - holder_width + x_margin(),
        hi_b = ro - x_margin(),
        s0 = lo_b - (hi_a - span),
        s1 = (hi_b - span) - lo_a,
        target = max(1, ceil(s0 / pitch)) * pitch
    )
    hook_cols() < 1 ? 0 : (target <= s1 + 0.01 ? 0 : target - s1);

function base_top_outer() = tablet_z1() + gap_side() + bar();

function grid_extra_z() =
    let (
        n = max(hook_rows(), 1),
        span = (n - 1) * pitch,
        lo_a = z_lo(),
        hi_a = z_hi(),
        ro = base_top_outer(),
        lo_b = ro - holder_height + z_lo(),
        hi_b = ro - holder_height + z_hi(),
        s0 = lo_b - (hi_a - span),
        s1 = (hi_b - span) - lo_a,
        target = max(1, ceil(s0 / pitch)) * pitch
    )
    hook_rows() < 1 ? 0 : (target <= s1 + 0.01 ? 0 : target - s1);

function right_outer() = base_right_outer() + grid_extra_x();

function top_outer() = base_top_outer() + grid_extra_z();

function y_front() = bar() + tablet_thickness + thickness_clearance;

// [origin_a, origin_b, 1 if both groups sit on one grid]
function hook_pair(lo_a, hi_a, lo_b, hi_b, span) =
    let (
        a0 = lo_a,
        a1 = hi_a - span,
        b0 = lo_b,
        b1 = hi_b - span,
        a_nat = (a0 + a1) / 2,
        b_nat = (b0 + b1) / 2,
        target = round((b_nat - a_nat) / pitch) * pitch,
        s_lo = max(a0 - a_nat, b0 - target - a_nat),
        s_hi = min(a1 - a_nat, b1 - target - a_nat),
        aligned = s_lo <= s_hi + 0.01,
        origin_a = aligned ? a_nat + (s_lo + s_hi) / 2 : a_nat,
        origin_b = aligned ? origin_a + target : b_nat
    )
    [origin_a, origin_b, aligned ? 1 : 0];

function left_hole_lo() = x_margin();

function left_hole_hi() = holder_width - x_margin();

function right_hole_lo() = right_outer() - holder_width + x_margin();

function right_hole_hi() = right_outer() - x_margin();

function bottom_hole_lo() = z_lo();

function bottom_hole_hi() = z_hi();

function top_hole_lo() = top_outer() - holder_height + z_lo();

function top_hole_hi() = top_outer() - holder_height + z_hi();

function hook_rear() = board_thickness + board_gap + 2 * tongue_r;

// Slot centre on the back face. The bar clears the 5 mm board, then turns down.
// The face of the downward bar toward the board is board_gap behind the board.
module board_hook() {
    y_root = min(tongue_r, bar() - tongue_r);
    y_behind = -(board_thickness + board_gap + tongue_r);
    module cap(y, z) {
        translate([0, y, z])
            sphere(r = tongue_r, $fn = hook_fn);
    }
    hull() {
        cap(y_root, 0);
        cap(y_behind, 0);
    }
    hull() {
        cap(y_behind, 0);
        cap(y_behind, -chin_drop);
    }
}

module hooks_on(origin_x, origin_z, cols, rows) {
    for (ix = [0 : cols - 1])
        for (iz = [0 : rows - 1])
            translate([origin_x + ix * pitch, 0, origin_z + iz * pitch])
                board_hook();
}

module corner_piece(x_sign, z_sign, origin_x, origin_z, cols, rows) {
    outer_x = x_sign < 0 ? 0 : right_outer();
    z0 = z_sign < 0 ? 0 : top_outer() - bar();
    z_edge = z_sign < 0 ? tablet_z0() : tablet_z1();
    side = side_on(x_sign, z_sign);
    arm_x0 = x_sign < 0 ? 0 : outer_x - holder_width;
    piece_z = z_sign < 0 ? 0 : top_outer() - holder_height;
    lip_z0 = z_sign < 0 ? bar() - eps : z_edge - capture_y;
    lip_z1 = z_sign < 0 ? z_edge + capture_y : top_outer() - bar() + eps;
    side_far = z_sign < 0 ? holder_height : top_outer() - holder_height;

    union() {
        translate([arm_x0, 0, piece_z])
            cube([holder_width, bar(), holder_height]);
        translate([arm_x0, 0, z0])
            cube([holder_width, y_front() + bar(), bar()]);
        // Horizontal capture. Width matches the holder.
        translate([arm_x0, y_front(), lip_z0])
            cube([holder_width, bar(), lip_z1 - lip_z0]);
        if (side) {
            side_x = x_sign < 0 ? 0 : outer_x - bar();
            side_z0 = min(z0, side_far);
            side_z1 = max(z0 + bar(), z_sign < 0 ? holder_height : top_outer());
            translate([side_x, 0, side_z0])
                cube([bar(), y_front() + bar(), side_z1 - side_z0]);
            // Vertical capture. Height matches the holder.
            cap_x = x_sign < 0 ? bar() - eps : outer_x - bar() - capture_x;
            translate([cap_x, y_front(), piece_z])
                cube([capture_x + eps, bar(), holder_height]);
        }
        hooks_on(origin_x, origin_z, cols, rows);
    }
}

module orient_holder(x0, x1, z1, flip) {
    // Outer shelf face on the bed. The plate stands up.
    // Hooks stick out from the back, clear of that face.
    if (flip)
        translate([x1, hook_rear(), z1])
            rotate([0, 180, 0])
                children();
    else
        translate([-x0, hook_rear(), 0])
            children();
}

module tablet_holder_set() {
    cols = hook_cols();
    rows = hook_rows();
    x_span = (max(cols, 1) - 1) * pitch;
    z_span = (max(rows, 1) - 1) * pitch;
    pair = hook_pair(
        left_hole_lo(), left_hole_hi(),
        right_hole_lo(), right_hole_hi(),
        x_span
    );
    zpair = hook_pair(
        bottom_hole_lo(), bottom_hole_hi(),
        top_hole_lo(), top_hole_hi(),
        z_span
    );
    assert(tablet_width > 0 && tablet_height > 0 && tablet_thickness > 0,
        "Tablet width, height, and thickness must be > 0");
    assert(holder_width > 0 && holder_height > 0, "L holder width and height must be > 0");
    assert(holder_thickness > 0, "L holder thickness must be > 0");
    assert(capture_x > 0 && capture_y > 0, "Front capture X and Y must be > 0");
    assert(capture_x <= holder_width, "Vertical capture is deeper than the holder is wide");
    assert(pitch > 0 && board_thickness > 0, "Pitch and board thickness must be > 0");
    assert(cols >= 1 && rows >= 1, "L holder is too small for one hook");
    assert(holder_width >= bar() && holder_height >= bar(),
        "L holder width and height must cover the L section");
    assert(2 * holder_width < right_outer(),
        "L holder width is too long for the tablet width");
    assert(2 * holder_height < tablet_height,
        "L holder height is too long for the tablet height");
    assert(layout == "print" || layout == "assembly", "Layout must be print or assembly");

    echo("Hook columns per holder", cols);
    echo("Hook rows per holder", rows);
    echo("Left/right columns share the grid", pair[2]);
    echo("Top/bottom rows share the grid", zpair[2]);
    echo("Extra clearance for the hook grid", grid_extra_x(), grid_extra_z());

    if (layout == "assembly") {
        color("slategray")
            corner_piece(-1, -1, pair[0], zpair[0], cols, rows);
        color("slategray")
            corner_piece(1, -1, pair[1], zpair[0], cols, rows);
        color("slategray")
            corner_piece(-1, 1, pair[0], zpair[1], cols, rows);
        color("slategray")
            corner_piece(1, 1, pair[1], zpair[1], cols, rows);
        // Preview only. F6 does not export this tablet block.
        %translate([tablet_x0(), bar(), tablet_z0()])
            cube([tablet_width, tablet_thickness, tablet_height]);
    } else {
        holder_stride = holder_width + print_gap;
        holder_rise = hook_rear() + y_front() + bar() + print_gap;
        orient_holder(0, holder_width, 0, false)
            corner_piece(-1, -1, pair[0], zpair[0], cols, rows);
        translate([holder_stride, 0, 0])
            orient_holder(right_outer() - holder_width, right_outer(), 0, false)
                corner_piece(1, -1, pair[1], zpair[0], cols, rows);
        translate([0, holder_rise, 0])
            orient_holder(0, holder_width, top_outer(), true)
                corner_piece(-1, 1, pair[0], zpair[1], cols, rows);
        translate([holder_stride, holder_rise, 0])
            orient_holder(right_outer() - holder_width, right_outer(), top_outer(), true)
                corner_piece(1, 1, pair[1], zpair[1], cols, rows);
    }
}

tablet_holder_set();
