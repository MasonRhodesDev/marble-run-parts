// Connector library for the household tube marble run set (Marble Genius style).
// Include from any custom part:  include <marble_set.scad>;
// Dimensions are nominal CAD values tuned for a slicer profile that applies
// +0.15 mm to holes and -0.05 mm to contours. See SET_PROFILE.md for the
// measurements behind them and the fit log.

// Measured on the set, 2026-10-23, calipers
MS_MALE_HI     = 23.60;   // male end, across the raised arcs
MS_MALE_LO     = 22.90;   // male end, across the flats
MS_FEMALE_ID   = 23.23;   // female mouth, round bore
MS_MALE_LEN    = 6.4;     // male end gripping height, with a fine chamfer at the tip
MS_UNIT_H      = 34.91;   // stacking pitch: body height of the base piece
                          // (41.31 overall minus the 6.4 male end)
MS_WALL        = 2.2;     // body wall, and the male end at its flats
MS_MALE_BORE   = 18.5;    // MS_MALE_LO minus two walls: the set's marble passage
MS_BODY_OD     = 27.63;   // MS_FEMALE_ID plus two walls
MS_MARBLE_D    = 16;      // assumed, confirm
// Official sockets: the 23.23 bore runs the whole body depth and ends in a
// seat ring about one wall wide where the male end of the piece above lands.

// Body height of a custom part should be n * MS_UNIT_H so stacks line up with
// official pieces beside it.
function ms_units(n) = n * MS_UNIT_H;

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
ms_wall        = 2.2;     // socket and body wall, same as the set
ms_male_overlap = 1.0;    // male end continues this far up into the body for strength
ms_seat_h      = ms_wall + ms_male_overlap; // socket floor thickness above the male end
// Constraint: a printed male end must run at least 1 mm up into the body it
// belongs to, so the joint is more than one layer of seat ring. Parts that
// draw their own junction must honour this too.
assert(ms_male_overlap >= 1, "ms_male_overlap must be at least 1 mm");
ms_bore        = 18.5;    // marble passage, same as the set's male end

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

// ---------------------------------------------------------------------------
// Feature declaration and conditional constraints
//
// A part declares what it has, then calls ms_check() with its key dimensions.
// Rules only fire for the features declared. Declarations are dynamic-scope
// variables so every library module beneath the part can see them too.
//
//   $ms_features = ["socket", "spigot", "stacks"];
//   $ms_units    = 2;
//   ms_check(body_h = 69.82, socket_depth = 8, passage = ms_bore);
//
// Features:
//   "spigot"  has a male end          -> overlap >= 1, flats below arcs, wall >= 2.2
//   "socket"  has a female socket     -> depth >= male end + lead-in, mouth chamfer >= 0.5
//   "stacks"  sits in a stack         -> body_h is a whole number of units
//   "marble"  a marble passes through -> passage >= marble + 1.5 (default on)
// ---------------------------------------------------------------------------

function ms_has(f) = !is_undef($ms_features) && len([for (x = $ms_features) if (x == f) x]) > 0;
function ms_near(a, b, tol = 0.05) = abs(a - b) <= tol;
function ms_is_units(h) = ms_near(h / MS_UNIT_H, round(h / MS_UNIT_H), 0.002);

module ms_check(body_h = undef, socket_depth = undef, passage = ms_bore, marble = MS_MARBLE_D) {
    assert(!is_undef($ms_features), "declare $ms_features before ms_check()");

    // spigot rules
    if (ms_has("spigot")) {
        assert(ms_male_overlap >= 1, "spigot: ms_male_overlap must be at least 1 mm");
        assert(ms_male_lo < ms_male_hi, "spigot: flats must sit below the arcs");
        assert((ms_male_lo - passage) / 2 >= MS_WALL - 0.05,
               str("spigot: wall at the flats is ", (ms_male_lo - passage) / 2, " mm, need ", MS_WALL));
    }

    // socket rules
    if (ms_has("socket")) {
        assert(!is_undef(socket_depth), "socket: pass socket_depth to ms_check()");
        assert(socket_depth >= MS_MALE_LEN + ms_mouth_chamfer,
               str("socket: depth ", socket_depth, " is shallower than the male end plus lead-in ", MS_MALE_LEN + ms_mouth_chamfer));
        assert(ms_mouth_chamfer >= 0.5, "socket: mouth chamfer under 0.5 mm will bind on elephant foot");
    }

    // stacking rule
    if (ms_has("stacks")) {
        assert(!is_undef(body_h), "stacks: pass body_h to ms_check()");
        assert(ms_is_units(body_h),
               str("stacks: body ", body_h, " is not a whole number of units (", MS_UNIT_H, "); nearest ", round(body_h / MS_UNIT_H) * MS_UNIT_H));
        if (!is_undef($ms_units))
            assert(ms_near(body_h, ms_units($ms_units), 0.05),
                   str("stacks: body ", body_h, " does not match the declared ", $ms_units, " units"));
    }

    // marble passage, on unless the part says otherwise
    if (ms_has("marble") || is_undef($ms_features) || !ms_has("no-marble"))
        assert(passage >= marble + 1.5,
               str("marble: passage ", passage, " must be at least marble + 1.5 = ", marble + 1.5));
}
