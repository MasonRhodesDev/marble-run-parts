// Straight tube, one set unit tall: the official base piece, drawn from the
// measured connector. Also the reference consumer of the library.
//
// Drawn in PRINT orientation: male end down on the plate, socket mouth up.
// In the run it is inverted (male end up). Needs a brim on the spigot.

include <../../lib/marble_set.scad>;

units = 1;              // body height in set units
$fn = 96;

body_h   = ms_units(units);
body_od  = ms_female_id + 2 * ms_wall;
z_body   = ms_male_len;                 // shoulder: body starts here
z_mouth  = z_body + body_h;             // socket mouth, top of the print
sock_h   = body_h - ms_seat_h;          // socket runs the body depth down to a floor

// connector ends for scripts/check_keepout.sh: [x, y, z, dir]
ms_sockets = [[0, 0, z_mouth, +1]];
ms_males   = [[0, 0, 0, -1]];

ms_check_units(body_h, units);

module part() {
    difference() {
        union() {
            translate([0, 0, ms_male_len]) mirror([0, 0, 1]) ms_male_spigot(bore = undef);
            translate([0, 0, z_body - 0.01]) cylinder(h = body_h + 0.01, d = body_od);
        }
        translate([0, 0, z_mouth - sock_h]) ms_female_bore(sock_h);
        ms_passage(z_body + ms_seat_h + 1);
    }
}

if (is_undef($ms_no_render)) part();
