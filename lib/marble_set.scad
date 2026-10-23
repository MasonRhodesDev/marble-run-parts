// Connector library for the household tube marble run set (Marble Genius style).
// Include from any part:  include <../../lib/marble_set.scad>;
//
// Orientation, as marbles see it: the MALE end is the TOP of a piece and the
// FEMALE socket is the BOTTOM. A marble enters through the male end and leaves
// through the socket into the male end of the piece below. Parts are drawn in
// whatever orientation prints best; say which in the part file.
//
// Dimensions are nominal CAD values for a slicer profile that applies
// +0.15 mm per side to holes and -0.05 mm per side to outer contours (so a
// bore prints about 0.30 wider and a spigot about 0.10 narrower than drawn;
// confirm with calipers on a coupon). See docs/set-profile.md.

// ---------------------------------------------------------------------------
// Measured on the set, calipers, 2026-10-23
// ---------------------------------------------------------------------------
MS_MALE_HI     = 23.60;   // male end, across the raised arcs
MS_MALE_LO     = 22.90;   // male end, across the six flats (shallow tangent cuts, ~4.5 wide)
MS_MALE_LEN    = 6.4;     // male end height; official edge chamfers are cosmetic (eyeballed)
MS_FEMALE_ID   = 23.50;   // female bore, round, constant from the mouth to the male step
MS_UNIT_H      = 34.91;   // stacking pitch: body height (41.31 overall minus the male end)
MS_WALL        = 2.2;     // body wall, and the male end at its flats
MS_MALE_BORE   = MS_MALE_LO - 2 * MS_WALL;   // 18.5: the set's marble passage
MS_BODY_OD     = MS_FEMALE_ID + 2 * MS_WALL; // 27.9 if the walls are concentric
MS_MARBLE_D    = 16;      // assumed; measure the largest of ten
MS_SOCKET_KEEPOUT = MS_MALE_LEN + 1;         // 7.4: plain bore below a mouth before any feature

// ---------------------------------------------------------------------------
// CAD targets for printed parts
// Fit status: coupon v1 (2026-10-23) at these diameters: socket seated an
// official male end perfectly at the top end; spigot fitted an official
// socket very well. Lengths were then cut to the set's.
// ---------------------------------------------------------------------------
ms_female_id     = 23.35;   // socket bore
ms_male_hi       = 23.65;   // spigot arcs
ms_male_lo       = 22.90;   // spigot flats
ms_flats         = 6;
ms_male_len      = 6.5;     // spigot height
ms_male_chamfer  = 0.5;     // spigot tip chamfer
ms_male_overlap  = 1.0;     // spigot continues this far into its body (constraint: >= 1)
ms_mouth_chamfer = 0.6;     // socket lead-in; use 0.8 when the mouth prints on the plate
ms_max_lead_in   = 1.0;     // no lead-in may be deeper than this (keep-out probe starts here)
ms_wall          = 2.2;
ms_bore          = 18.5;    // marble passage, same as the set
ms_seat_h        = ms_wall + ms_male_overlap; // floor under a socket that ends inside a part
ms_marble_clear  = 1.5;     // passage must exceed the marble by this

function ms_units(n) = n * MS_UNIT_H;

// ---------------------------------------------------------------------------
// Constant relations, checked once at include time. A part cannot break
// these; they guard edits to the numbers above.
// ---------------------------------------------------------------------------
assert(ms_male_overlap >= 1, "ms_male_overlap must be at least 1 mm");
assert(ms_male_lo < MS_FEMALE_ID && MS_FEMALE_ID < ms_male_hi,
       "spigot: flats must clear the official bore and arcs must press on it");
assert(ms_female_id < MS_MALE_HI, "socket: bore must press on the official arcs");
assert(ms_bore >= MS_MARBLE_D + ms_marble_clear, "ms_bore is too small for the marble");
assert((ms_male_lo - ms_bore) / 2 >= MS_WALL - 0.05, "ms_bore leaves the spigot wall under 2.2");
if (ms_mouth_chamfer < 0.5) echo("WARNING: ms_mouth_chamfer under 0.5 binds on elephant foot");

// ---------------------------------------------------------------------------
// Drawing modules. The checks live here, on the numbers actually drawn.
// ---------------------------------------------------------------------------

// Male end. Base at z = 0, tip (chamfered) at z = h. Place it so that the
// extra `overlap` length lies inside the body it belongs to.
// bore = undef draws it solid (when the part cuts its own passage).
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

// Negative: socket bore of depth h with the mouth at z = h (facing +z).
// feature_depth is the distance from the mouth to the first thing that is not
// plain bore (a floor, a window, a narrowing). The keep-out rule is asserted
// on it here and verified geometrically by scripts/check_keepout.sh.
module ms_female_bore(h, feature_depth = undef, chamfer = ms_mouth_chamfer) {
    fd = is_undef(feature_depth) ? h : feature_depth;
    assert(chamfer <= ms_max_lead_in, str("socket: lead-in ", chamfer, " exceeds ", ms_max_lead_in));
    assert(h >= MS_SOCKET_KEEPOUT, str("socket: depth ", h, " is under the keep-out ", MS_SOCKET_KEEPOUT));
    assert(fd >= MS_SOCKET_KEEPOUT, str("socket: first feature at ", fd, " below the mouth; keep-out is ", MS_SOCKET_KEEPOUT));
    assert(fd <= h + 0.01, "socket: feature_depth cannot exceed the socket depth");
    translate([0, 0, -0.01]) cylinder(h = h + 0.02, d = ms_female_id);
    translate([0, 0, h - chamfer]) cylinder(h = chamfer + 0.01, d1 = ms_female_id, d2 = ms_female_id + 2 * chamfer);
}

// Positive: a socket ring of depth h, mouth at z = h, with a floor of
// ms_seat_h under it and a marble passage through the floor.
module ms_female_socket(h = MS_SOCKET_KEEPOUT + 1, wall = ms_wall, floor_h = ms_seat_h, passage = ms_bore) {
    difference() {
        cylinder(h = h + floor_h, r = ms_female_id / 2 + wall);
        translate([0, 0, floor_h]) ms_female_bore(h);
        ms_passage(floor_h + 1);
    }
}

// Negative: marble passage
module ms_passage(h, d = ms_bore) {
    assert(d >= MS_MARBLE_D + ms_marble_clear, str("passage ", d, " is under marble + ", ms_marble_clear));
    translate([0, 0, -0.01]) cylinder(h = h + 0.02, d = d);
}

// Stacking check for a part that sits in a row with official pieces.
// body_h is spigot shoulder to socket mouth. One tolerance: 0.1 mm.
module ms_check_units(body_h, units) {
    assert(abs(body_h - ms_units(units)) <= 0.1,
           str("stacks: body ", body_h, " is not ", units, " units (", ms_units(units), ")"));
}

// Fit coupon: socket ring on a 2 mm base (mouth up, so the plate end is not
// the mating end) and a flanged spigot, 40 mm apart.
module ms_fit_coupon() {
    ms_female_socket(h = ms_male_len + 1.5, floor_h = 2);
    translate([40, 0, 0]) {
        difference() { cylinder(h = 2, d = ms_male_hi + 6); ms_passage(2); }
        translate([0, 0, ms_male_overlap]) ms_male_spigot();
    }
}

// ---------------------------------------------------------------------------
// Geometric keep-out declaration. A part lists its socket mouths as
//   ms_sockets = [[x, y, z_mouth, dir], ...]   dir = +1 mouth faces +z, -1 faces -z
// scripts/check_keepout.sh renders two tests per socket against the part:
// nothing inside the bore, and the full wall present, for MS_SOCKET_KEEPOUT.
// ---------------------------------------------------------------------------
module ms_keepout_bore(s)  { translate([s[0], s[1], s[2]]) mirror([0, 0, s[3] < 0 ? 0 : 1])
                             cylinder(h = MS_SOCKET_KEEPOUT, d = ms_female_id - 0.1); }
module ms_keepout_wall(s)  { translate([s[0], s[1], s[2]]) mirror([0, 0, s[3] < 0 ? 0 : 1])
                             translate([0, 0, ms_max_lead_in + 0.05]) difference() {
                                 cylinder(h = MS_SOCKET_KEEPOUT - ms_max_lead_in - 0.1, d = ms_female_id + 2 * ms_wall - 0.1);
                                 translate([0, 0, -1]) cylinder(h = MS_SOCKET_KEEPOUT + 2, d = ms_female_id + 0.1);
                             } }
