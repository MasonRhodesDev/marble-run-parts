include <../../lib/marble_set.scad>;

units = 1;
$fn = 96;

body_h   = ms_units(units);
body_od  = ms_female_id + 2 * ms_wall;
z_body   = ms_male_len;
z_mouth  = z_body + body_h;
sock_h   = body_h - ms_seat_h;

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
