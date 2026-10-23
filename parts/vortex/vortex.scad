// Marble run vortex module with a tube-set inlet socket and outlet spigot.
// Prints upright on the spigot with no supports: every surface is 45 deg or
// steeper, the only bridge is the window roof.
// Connector dimensions come from marble_set.scad; see SET_PROFILE.md.

include <../../lib/marble_set.scad>;

part = "vortex";        // "vortex" or "coupon"

// connector aliases (edit marble_set.scad, not these)
female_id = ms_female_id;
male_hi   = ms_male_hi;
male_lo   = ms_male_lo;
male_flats = ms_flats;
conn_len  = ms_female_depth;   // socket depth
male_len  = ms_male_len;
conn_wall = ms_wall;
bore      = ms_bore;

// bowl
bowl_d         = 110;   // rim diameter (inside)
wall           = 2.4;
cone_deg       = 45;    // wall angle from horizontal; never below 45
units          = 2;     // body height in set units, spigot shoulder to socket mouth
lip_min        = 12;    // lip is sized to hit the unit height, never below this

// inlet: vertical socket just inside the lip; marble drops down a shaft onto a
// 45 deg ramp and leaves through a side window along the rim tangent.
inlet_h        = conn_len + 4;  // socket height above the lip top
ramp_deg       = 45;
window_h       = 26;

$fn = 96;

sock_r     = female_id/2 + conn_wall;
cone_r_out = bowl_d/2;
cone_r_in  = bore/2 + 2;
cone_h     = (cone_r_out - cone_r_in) * tan(cone_deg);
lip_h      = max(lip_min, ms_units(units) - cone_h - inlet_h);
spigot_h   = male_len;
z_rim      = spigot_h + cone_h;          // top of cone, bottom of lip
z_lip      = z_rim + lip_h;              // top of lip
r_axis     = cone_r_out - sock_r + 0.6;  // socket wall merges into the lip
z_cone_at_axis = spigot_h + (r_axis - cone_r_in) * tan(cone_deg);

module male_spigot(h) { mirror([0,0,1]) translate([0,0,-h]) ms_male_spigot(h = h, bore = 0.01); }

module bowl_outer() {
    union() {
        translate([0,0,spigot_h])
            cylinder(h = cone_h, r1 = cone_r_in + wall, r2 = cone_r_out + wall);
        translate([0,0,z_rim - 0.01])
            cylinder(h = lip_h + 0.01, r = cone_r_out + wall);
    }
}

// everything above the inner cone surface, used to clip the socket
module bowl_inside() {
    union() {
        translate([0,0,spigot_h])
            cylinder(h = cone_h + 0.01, r1 = cone_r_in, r2 = cone_r_out);
        translate([0,0,z_rim])
            cylinder(h = lip_h + inlet_h + 5, r = cone_r_out);
    }
}

module socket_body() {
    intersection() {
        translate([r_axis, 0, spigot_h])
            cylinder(h = z_lip + inlet_h - spigot_h, r = sock_r);
        bowl_inside();
    }
}

module inlet_cuts() {
    z_top   = z_lip + inlet_h;
    z_floor = z_cone_at_axis + 2.5;          // window sill, just above the cone
    translate([r_axis, 0, 0]) {
        // set's male end seats here
        translate([0,0,z_top - conn_len]) ms_female_bore(conn_len);
        // drop shaft with a sloped floor: high on -y, low at the window (+y)
        hull() {
            translate([0, -bore/2, z_floor + bore * tan(ramp_deg)]) cylinder(h = 0.1, d = 0.1);
            translate([0,  bore/2, z_floor]) cylinder(h = 0.1, d = 0.1);
            translate([0, 0, z_top - conn_len + 0.5]) cylinder(h = 0.1, r = bore/2);
            translate([0, 0, z_floor + 0.05]) cylinder(h = 0.05, r = bore/2);
        }
        // tangential window through the socket wall toward +y
        translate([-bore/2, 0, z_floor]) cube([bore, sock_r + 1, window_h]);
    }
}

module vortex() {
    difference() {
        union() {
            difference() {
                union() { male_spigot(spigot_h); translate([0,0,spigot_h-0.01]) cylinder(h=0.02, d=male_hi); bowl_outer(); }
                bowl_inside();
            }
            socket_body();
        }
        translate([0,0,-1]) cylinder(h = spigot_h + 2, r = bore/2);
        inlet_cuts();
    }
}

module coupon() { ms_fit_coupon(); }

if (part == "coupon") coupon(); else vortex();
