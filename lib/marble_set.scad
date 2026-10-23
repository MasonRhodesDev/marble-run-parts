// Connector library for the household tube marble run set (Marble Genius style).
// Include from any custom part:  include <marble_set.scad>;
// Dimensions are nominal CAD values tuned for a slicer profile that applies
// +0.15 mm to holes and -0.05 mm to contours. See SET_PROFILE.md for the
// measurements behind them and the fit log.

// Measured on the set, 2026-10-23, calipers
MS_MALE_HI     = 23.60;   // male end, across the raised arcs
MS_MALE_LO     = 22.90;   // male end, across the flats
MS_FEMALE_ID   = 23.23;   // female mouth, round bore
MS_MARBLE_D    = 16;      // assumed, confirm

// CAD targets for printed parts (status: coupon v1 printing, unverified)
ms_female_id   = 23.35;   // our socket bore; prints ~23.5, 0.1 press on the arcs
ms_male_hi     = 23.65;   // our spigot arcs; prints ~23.55 into the 23.23 bore
ms_male_lo     = 22.90;   // our spigot flats
ms_flats       = 6;
ms_conn_len    = 18;      // engagement length that the set uses
ms_wall        = 2.4;     // socket wall
ms_bore        = 17.5;    // marble passage, 1.5 mm over the marble

// Male end that plugs into a set female mouth or a printed ms_female_socket.
// Round at ms_male_hi with ms_flats flats cut to ms_male_lo, like the set's.
module ms_male_spigot(h = ms_conn_len, bore = ms_bore) {
    difference() {
        cylinder(h = h, d = ms_male_hi);
        for (i = [0:ms_flats-1])
            rotate([0, 0, i * 360 / ms_flats])
                translate([ms_male_lo/2, -20, -1]) cube([10, 40, h + 2]);
        translate([0, 0, -1]) cylinder(h = h + 2, d = bore);
    }
}

// Female socket that accepts a set male end. Solid ring; subtract your own
// passage below the seat.
module ms_female_socket(h = ms_conn_len, wall = ms_wall) {
    difference() {
        cylinder(h = h, r = ms_female_id/2 + wall);
        translate([0, 0, -1]) cylinder(h = h + 2, d = ms_female_id);
    }
}

// Negative shapes, for subtracting from a larger body
module ms_female_bore(h = ms_conn_len) { translate([0,0,-0.01]) cylinder(h = h + 0.02, d = ms_female_id); }
module ms_passage(h)                  { translate([0,0,-0.01]) cylinder(h = h + 0.02, d = ms_bore); }

// Fit coupon: one socket ring and one flanged spigot, 40 mm apart.
module ms_fit_coupon() {
    ms_female_socket();
    translate([40, 0, 0]) {
        difference() { cylinder(h = 2, d = ms_male_hi + 6); ms_passage(2); }
        ms_male_spigot();
    }
}
