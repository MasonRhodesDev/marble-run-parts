MS_MALE_HI     = 23.60;
MS_MALE_LO     = 22.90;
MS_MALE_LEN    = 6.4;
MS_FEMALE_ID   = 23.50;
MS_UNIT_H      = 34.91;
MS_WALL        = 2.2;
MS_MALE_BORE   = MS_MALE_LO - 2 * MS_WALL;
MS_BODY_OD     = MS_FEMALE_ID + 2 * MS_WALL;
MS_MARBLE_D    = 16;
MS_SOCKET_KEEPOUT = MS_MALE_LEN + 1;

ms_female_id     = 23.35;
ms_male_hi       = 23.65;
ms_male_lo       = 22.90;
ms_flats         = 6;
ms_male_len      = 6.5;
ms_male_chamfer  = 0.5;
ms_male_overlap  = 1.0;
ms_mouth_chamfer = 0.6;
ms_max_lead_in   = 1.0;
ms_wall          = 2.2;
ms_bore          = 18.5;
ms_seat_h        = ms_wall + ms_male_overlap;
ms_marble_clear  = 1.5;

function ms_units(n) = n * MS_UNIT_H;
ms_male_keepout = ms_male_len + ms_male_overlap + 1;

assert(ms_male_overlap >= 1, "ms_male_overlap must be at least 1 mm");
assert(ms_male_lo < MS_FEMALE_ID && MS_FEMALE_ID < ms_male_hi,
       "spigot: flats must clear the official bore and arcs must press on it");
assert(ms_female_id < MS_MALE_HI, "socket: bore must press on the official arcs");
assert(ms_bore >= MS_MARBLE_D + ms_marble_clear, "ms_bore is too small for the marble");
assert((ms_male_lo - ms_bore) / 2 >= MS_WALL - 0.05, "ms_bore leaves the spigot wall under 2.2");
if (ms_mouth_chamfer < 0.5) echo("WARNING: ms_mouth_chamfer under 0.5 binds on elephant foot");

module ms_male_spigot(h = ms_male_len, bore = ms_bore, chamfer = ms_male_chamfer, overlap = ms_male_overlap) {
    assert(h >= MS_MALE_LEN, str("spigot: height ", h, " is under the official ", MS_MALE_LEN));
    assert(overlap >= 1, "spigot: overlap into the body must be at least 1 mm");
    assert(is_undef(bore) || (ms_male_lo - bore) / 2 >= MS_WALL - 0.05,
           str("spigot: bore ", bore, " leaves a wall under ", MS_WALL, " at the flats"));
    assert(is_undef(bore) || bore >= MS_MARBLE_D + ms_marble_clear,
           str("spigot: bore ", bore, " is under marble + ", ms_marble_clear));
    total = h + overlap;
    difference() {
        translate([0, 0, -overlap]) union() {
            cylinder(h = total - chamfer, d = ms_male_hi);
            translate([0, 0, total - chamfer])
                cylinder(h = chamfer, d1 = ms_male_hi, d2 = ms_male_hi - 2 * chamfer);
        }
        for (i = [0:ms_flats - 1])
            rotate([0, 0, i * 360 / ms_flats])
                translate([ms_male_lo / 2, -20, -overlap - 1]) cube([10, 40, total + 2]);
        if (!is_undef(bore)) translate([0, 0, -overlap - 1]) cylinder(h = total + 2, d = bore);
    }
}

module ms_female_bore(h, feature_depth = undef, chamfer = ms_mouth_chamfer) {
    fd = is_undef(feature_depth) ? h : feature_depth;
    assert(chamfer <= ms_max_lead_in, str("socket: lead-in ", chamfer, " exceeds ", ms_max_lead_in));
    assert(h >= MS_SOCKET_KEEPOUT, str("socket: depth ", h, " is under the keep-out ", MS_SOCKET_KEEPOUT));
    assert(fd >= MS_SOCKET_KEEPOUT, str("socket: first feature at ", fd, " below the mouth; keep-out is ", MS_SOCKET_KEEPOUT));
    assert(fd <= h + 0.01, "socket: feature_depth cannot exceed the socket depth");
    translate([0, 0, -0.01]) cylinder(h = h + 0.02, d = ms_female_id);
    translate([0, 0, h - chamfer]) cylinder(h = chamfer + 0.01, d1 = ms_female_id, d2 = ms_female_id + 2 * chamfer);
}

module ms_female_socket(h = MS_SOCKET_KEEPOUT + 1, wall = ms_wall, floor_h = ms_seat_h, passage = ms_bore) {
    difference() {
        cylinder(h = h + floor_h, r = ms_female_id / 2 + wall);
        translate([0, 0, floor_h]) ms_female_bore(h);
        ms_passage(floor_h + 1);
    }
}

module ms_passage(h, d = ms_bore) {
    assert(d >= MS_MARBLE_D + ms_marble_clear, str("passage ", d, " is under marble + ", ms_marble_clear));
    translate([0, 0, -0.01]) cylinder(h = h + 0.02, d = d);
}

module ms_check_units(body_h, units) {
    assert(abs(body_h - ms_units(units)) <= 0.1,
           str("stacks: body ", body_h, " is not ", units, " units (", ms_units(units), ")"));
}

module ms_fit_coupon() {
    ms_female_socket(h = ms_male_len + 1.5, floor_h = 2);
    translate([40, 0, 0]) {
        difference() { cylinder(h = 2, d = ms_male_hi + 6); ms_passage(2); }
        translate([0, 0, ms_male_overlap]) ms_male_spigot();
    }
}

module ms_male_keepout_bore(m) { translate([m[0], m[1], m[2]]) mirror([0, 0, m[3] > 0 ? 1 : 0])
                                 translate([0, 0, 0.2]) cylinder(h = ms_male_keepout - 0.2, d = ms_bore - 0.2); }
module ms_male_keepout_wall(m) { translate([m[0], m[1], m[2]]) mirror([0, 0, m[3] > 0 ? 1 : 0])
                                 translate([0, 0, ms_male_chamfer + 0.2]) difference() {
                                     cylinder(h = ms_male_keepout - ms_male_chamfer - 0.2, d = ms_male_lo - 0.2);
                                     translate([0, 0, -1]) cylinder(h = ms_male_keepout + 2, d = ms_bore + 0.2);
                                 } }
module ms_keepout_bore(s)  { translate([s[0], s[1], s[2]]) mirror([0, 0, s[3] < 0 ? 0 : 1])
                             cylinder(h = MS_SOCKET_KEEPOUT, d = ms_female_id - 0.1); }
module ms_keepout_wall(s)  { translate([s[0], s[1], s[2]]) mirror([0, 0, s[3] < 0 ? 0 : 1])
                             translate([0, 0, ms_max_lead_in + 0.05]) difference() {
                                 cylinder(h = MS_SOCKET_KEEPOUT - ms_max_lead_in - 0.1, d = ms_female_id + 2 * ms_wall - 0.1);
                                 translate([0, 0, -1]) cylinder(h = MS_SOCKET_KEEPOUT + 2, d = ms_female_id + 0.1);
                             } }
