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
// Marble path leaves the tower along +y at x = axis, at the tower wall. The sill is set
// from the bowl surface at that far point so the marble drops win_drop onto the bowl.
win_drop   = 2;                              // drop from the sill to the bowl surface at the far edge
r_far      = sqrt(r_axis * r_axis + tower_r * tower_r);
z_cone_far = z0 + (r_far - cone_r_in) * tan(cone_deg);
z_win      = z_cone_far + win_drop;          // window sill

echo(r_axis = r_axis, z_win = z_win, z_cone_far = z_cone_far, drop = z_win - z_cone_far);
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

// the bowl wall itself; cuts must never remove it
module bowl_shell() { difference() { bowl_outer(); bowl_inside(); } }

// everything above a plane that rises toward -y at ramp_deg and meets z_win at y = +bore/2
module above_ramp() {
    translate([0, ms_bore / 2, z_win]) rotate([-ramp_deg, 0, 0])
        translate([-30, -60, 0]) cube([60, 120, 120]);
}

module tower_cuts() {
    translate([r_axis, 0, 0]) {
        // drop shaft: round bore above a real ramp, low edge at the sill on the +y side
        intersection() {
            translate([0, 0, z_win]) cylinder(h = z_tip - z_win, d = ms_bore);
            above_ramp();
        }
        // tangential window through the tower wall toward +y, clipped to the tower
        // cylinder and to above the ramp so it never eats the ramp
        intersection() {
            translate([-ms_bore / 2, 0, z_win]) cube([ms_bore, tower_r + 1, window_h]);
            translate([0, 0, z_win - 1]) cylinder(h = window_h + 2, r = tower_r + 0.01);
            above_ramp();
        }
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
        difference() { tower_cuts(); bowl_shell(); }
    }
}

if (is_undef($ms_no_render)) { if (which == "coupon") ms_fit_coupon(); else part(); }
