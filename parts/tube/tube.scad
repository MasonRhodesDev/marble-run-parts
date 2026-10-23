// Straight tube, one set unit tall: the official base piece, drawn from the
// measured connector. Also a reference model for checking the library.
// Prints upright on the male end (short spigot, 2.2 mm wall, needs a brim)
// or upside down on the socket mouth with ms_mouth_chamfer raised to 0.8.

include <../../lib/marble_set.scad>;

units = 1;              // body height in set units
$fn = 96;

body_h  = ms_units(units);
body_od = ms_female_id + 2 * ms_wall;   // 27.63 like the set
seat_h  = ms_seat_h;                     // socket floor: one wall plus the male overlap

module tube() {
    difference() {
        union() {
            // male end below the body, tip downward
            // male end, tip downward, extended ms_male_overlap into the body
            mirror([0, 0, 1]) translate([0, 0, -(ms_male_len + ms_male_overlap)]) ms_male_spigot(h = ms_male_len + ms_male_overlap, bore = 0.01);
            translate([0, 0, ms_male_len - 0.01]) cylinder(h = body_h + 0.01, d = body_od);
        }
        // full-depth socket bore, ending on a seat ring just above the male end
        translate([0, 0, ms_male_len + seat_h]) ms_female_bore(body_h - seat_h);
        // marble passage through seat and male end
        ms_passage(ms_male_len + seat_h + 1);
    }
}

tube();
