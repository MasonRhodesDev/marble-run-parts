// Mid-run vortex. A marble arrives through the male end on top of the inlet
// tower, drops down the tower onto a 45 degree ramp, leaves through a window
// along the rim tangent, spirals down the 45 degree bowl and exits through
// the female socket at the bottom into the piece below.
//
// Drawn in USE orientation, which is also the print orientation: it stands on
// the outlet socket, mouth on the plate (lead-in 0.8 for elephant foot). No
// supports: every surface is 45 degrees or steeper, the only bridge is the
// window roof. Connector numbers come from the library; see docs/set-profile.md.

include <../../lib/marble_set.scad>;

which = "vortex";       // "vortex" or "coupon"

units      = 2;         // body height in set units: socket mouth to male shoulder
bowl_d     = 110;       // rim diameter (inside)
wall       = ms_wall;
cone_deg   = 45;        // bowl wall from horizontal; never below 45
lip_h      = 12;        // vertical lip above the cone rim
sock_depth = 8;         // outlet socket depth (keep-out is 7.4)
ramp_deg   = 45;
window_h   = 26;

$fn = 96;

// outlet socket and floor
sock_r   = ms_female_id / 2 + wall;         // 13.875, the set's body radius
z_floor0 = sock_depth;                       // top of socket bore
z0       = sock_depth + ms_seat_h;           // top of floor, bottom of bowl cavity

// bowl
cone_r_in  = sock_r - wall * sqrt(2);        // inner cone starts here so the wall is `wall` thick
cone_r_out = bowl_d / 2;
cone_h     = (cone_r_out - cone_r_in) * tan(cone_deg);
z_rim      = z0 + cone_h;
z_lip      = z_rim + lip_h;

// inlet tower: a set-sized tube standing inside the lip, male end on top
tower_r    = sock_r;
r_axis     = cone_r_out - tower_r + 0.6;     // tower wall merges into the lip
z_shoulder = ms_units(units);                // male shoulder: stack height from the mouth
z_tip      = z_shoulder + ms_male_len;
z_cone_at_axis = z0 + (r_axis - cone_r_in) * tan(cone_deg);
z_win      = z_cone_at_axis + 2.5;           // window sill, just above the bowl surface

assert(z_shoulder >= z_lip + 2, str("tower shoulder ", z_shoulder, " must clear the lip top ", z_lip));
ms_check_units(z_shoulder, units);

// socket mouths for scripts/check_keepout.sh: [x, y, z_mouth, dir]
ms_sockets = [[0, 0, 0, -1]];

module bowl_outer() {
    union() {
        cylinder(h = z0 + 0.01, r = sock_r);
        translate([0, 0, z0]) cylinder(h = cone_h, r1 = sock_r, r2 = cone_r_out + wall);
        translate([0, 0, z_rim - 0.01]) cylinder(h = lip_h + 0.01, r = cone_r_out + wall);
    }
}

// everything above the inner bowl surface (used to clip the tower)
module bowl_inside() {
    union() {
        translate([0, 0, z0]) cylinder(h = cone_h + 0.01, r1 = cone_r_in, r2 = cone_r_out);
        translate([0, 0, z_rim]) cylinder(h = z_tip - z_rim + 5, r = cone_r_out);
    }
}

module tower_body() {
    intersection() {
        translate([r_axis, 0, z0]) cylinder(h = z_shoulder - z0, r = tower_r);
        bowl_inside();
    }
}

module tower_cuts() {
    translate([r_axis, 0, 0]) {
        // drop shaft with a sloped floor: high on -y, low at the window (+y)
        hull() {
            translate([0, -ms_bore / 2, z_win + ms_bore * tan(ramp_deg)]) cylinder(h = 0.1, d = 0.1);
            translate([0,  ms_bore / 2, z_win]) cylinder(h = 0.1, d = 0.1);
            translate([0, 0, z_tip]) cylinder(h = 0.1, d = ms_bore);
            translate([0, 0, z_win + 0.05]) cylinder(h = 0.05, d = ms_bore);
        }
        // tangential window through the tower wall toward +y
        translate([-ms_bore / 2, 0, z_win]) cube([ms_bore, tower_r + 1, window_h]);
    }
}

module part() {
    difference() {
        union() {
            difference() { bowl_outer(); bowl_inside(); }
            tower_body();
            // male end on top of the tower, overlap into the tower body
            translate([r_axis, 0, z_shoulder]) ms_male_spigot(bore = undef);
        }
        // outlet socket: mouth at z = 0 facing down, plain bore up to the floor
        translate([0, 0, sock_depth]) mirror([0, 0, 1]) ms_female_bore(sock_depth, chamfer = 0.8);
        ms_passage(z0 + 1);
        tower_cuts();
    }
}

if (is_undef($ms_no_render)) { if (which == "coupon") ms_fit_coupon(); else part(); }
