// Connector library for the household tube marble run set (Marble Genius style).
// Include from any custom part:  include <marble_set.scad>;
// Dimensions are nominal CAD values tuned for a slicer profile that applies
// +0.15 mm to holes and -0.05 mm to contours. See SET_PROFILE.md for the
// measurements behind them and the fit log.

// Measured on the set, 2026-10-23, calipers
MS_MALE_HI     = 23.60;   // male end, across the raised arcs
MS_MALE_LO     = 22.90;   // male end, across the flats
MS_FEMALE_ID   = 23.23;   // female mouth, round bore
MS_MALE_LEN    = 6.4;     // male end height, with a fine chamfer at the tip
MS_MARBLE_D    = 16;      // assumed, confirm

// CAD targets for printed parts (status: coupon v1 2026-10-23 passed both
// fits at these diameters; lengths shortened to the set's after it)
ms_female_id   = 23.35;   // socket bore; prints ~23.5, 0.1 press on the arcs. Verified.
ms_male_hi     = 23.65;   // spigot arcs; prints ~23.55 into the 23.23 bore. Verified.
ms_male_lo     = 22.90;   // spigot flats
ms_flats       = 6;
ms_male_len    = 6.5;     // spigot height, matches the set's 6.4
ms_male_chamfer = 0.5;    // tip chamfer, the set's is similar
ms_female_depth = 8;      // socket depth, seats a 6.4 male with room
ms_mouth_chamfer = 0.6;   // lead-in at the socket mouth; also beats elephant
                          // foot when the mouth is printed against the plate
ms_conn_len    = ms_female_depth; // kept for older parts
ms_wall        = 2.4;     // socket wall
ms_bore        = 17.5;    // marble passage, 1.5 mm over the marble

// Male end that plugs into a set female mouth or a printed ms_female_socket.
// Round at ms_male_hi with ms_flats flats cut to ms_male_lo, like the set's.
// Tip is at z = h (plug it in upward); the chamfer is on that end.
module ms_male_spigot(h = ms_male_len, bore = ms_bore, chamfer = ms_male_chamfer) {
    difference() {
        union() {
            cylinder(h = h - chamfer, d = ms_male_hi);
            translate([0, 0, h - chamfer]) cylinder(h = chamfer, d1 = ms_male_hi, d2 = ms_male_hi - 2*chamfer);
        }
        for (i = [0:ms_flats-1])
            rotate([0, 0, i * 360 / ms_flats])
                translate([ms_male_lo/2, -20, -1]) cube([10, 40, h + 2]);
        translate([0, 0, -1]) cylinder(h = h + 2, d = bore);
    }
}

// Female socket that accepts a set male end. Solid ring; subtract your own
// passage below the seat.
// Mouth is at z = h. Chamfer the mouth; if the mouth will print against the
// plate, mirror it or raise ms_mouth_chamfer to 0.8.
module ms_female_socket(h = ms_female_depth, wall = ms_wall) {
    difference() {
        cylinder(h = h, r = ms_female_id/2 + wall);
        ms_female_bore(h);
    }
}

// Negative shapes, for subtracting from a larger body
module ms_female_bore(h = ms_female_depth, chamfer = ms_mouth_chamfer) {
    translate([0,0,-0.01]) cylinder(h = h + 0.02, d = ms_female_id);
    translate([0,0,h - chamfer]) cylinder(h = chamfer + 0.01, d1 = ms_female_id, d2 = ms_female_id + 2*chamfer);
}
module ms_passage(h)                  { translate([0,0,-0.01]) cylinder(h = h + 0.02, d = ms_bore); }

// Fit coupon: one socket ring (mouth up, on a 2 mm base so the plate end is
// not the mating end) and one flanged spigot, 40 mm apart.
module ms_fit_coupon() {
    difference() { cylinder(h = ms_female_depth + 2, r = ms_female_id/2 + ms_wall); translate([0,0,2]) ms_female_bore(ms_female_depth); ms_passage(3); }
    translate([40, 0, 0]) {
        difference() { cylinder(h = 2, d = ms_male_hi + 6); ms_passage(2); }
        ms_male_spigot();
    }
}
