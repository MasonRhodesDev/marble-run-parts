include <../../lib/marble_set.scad>;

which = "vortex";

units      = 3;
bowl_d     = 110;
wall       = ms_wall;
cone_deg   = 45;
lip_h      = 12;
sock_depth = 8;

$fn = $preview ? 32 : 96;

sock_r   = ms_female_id / 2 + wall;
z_floor0 = sock_depth;
z0       = sock_depth + ms_seat_h;

cone_r_in  = sock_r - wall * sqrt(2);
cone_r_out = bowl_d / 2;
cone_h     = (cone_r_out - cone_r_in) * tan(cone_deg);
z_rim      = z0 + cone_h;
z_lip      = z_rim + lip_h;

z_shoulder = ms_units(units);
z_tip      = z_shoulder + ms_male_len;
r_lip_in   = cone_r_out;
r_lip_out  = cone_r_out + wall;
tube_r     = sock_r;
tube_pr    = r_lip_in + ms_male_hi / 2 + 0.4;
entry_deg  = 25;
bend_r     = 20;
trough_deg = 20;
sill_rise  = 4;
marble_r   = MS_MARBLE_D / 2;
chan_r     = ms_bore / 2;
chan_lift  = chan_r - marble_r;
z_open_top = z_tip - ms_male_keepout - 0.1;
trough_ext = 14;
n_bend     = 16;

e_pt   = [r_lip_in, 0];
dvec   = [-sin(entry_deg), cos(entry_deg)];
psi    = 90 + entry_deg;
sh_a   = r_lip_in * sin(entry_deg);
s_len  = -sh_a + sqrt(sh_a * sh_a + tube_pr * tube_pr - r_lip_in * r_lip_in);
p_pt   = [e_pt[0] - s_len * dvec[0], e_pt[1] - s_len * dvec[1]];
tube_x = p_pt[0];
tube_y = p_pt[1];

phi_e    = 270 - trough_deg;
bend_dx  = bend_r * (1 + cos(phi_e));
lt_len   = (s_len - bend_dx) / cos(trough_deg);
z_sill   = z_rim + sill_rise;
z_e_path = z_sill + marble_r;
z_bend0  = z_e_path + lt_len * sin(trough_deg) + bend_r * cos(trough_deg);
bend_b   = [bend_dx, z_bend0 + bend_r * sin(phi_e)];
function bend_pt(i) = let(a = 180 + (phi_e - 180) * i / n_bend) [bend_r * (1 + cos(a)), z_bend0 + bend_r * sin(a)];
function trough_pt(t) = [bend_b[0] + t * cos(trough_deg), bend_b[1] - t * sin(trough_deg)];
path_pts = concat([for (i = [0 : n_bend]) bend_pt(i)],
                  [for (t = [lt_len / 3, 2 * lt_len / 3, lt_len, lt_len + trough_ext / cos(trough_deg)]) trough_pt(t)]);

function r_cone(z) = sock_r + (z - z0) * (r_lip_out - sock_r) / cone_h;
function world_r(q) = norm([p_pt[0] + q[0] * dvec[0], p_pt[1] + q[0] * dvec[1]]);
margins = [for (q = path_pts) if (world_r(q) > r_lip_out) (q[1] - marble_r) - (z_rim + world_r(q) - r_lip_out) - ms_wall];

echo(tube_axis = p_pt, s_len = s_len, heading = psi, z_bend0 = z_bend0, z_sill = z_sill, z_rim = z_rim,
     lt_len = lt_len, lip_top = z_lip, min_floor_margin = min(margins));
assert(min(margins) >= 0, str("channel floor dips under the 45 degree corbel by ", -min(margins)));
assert(z_bend0 < z_open_top - chan_r, "scoop starts too close to the male keep-out");
assert(z_shoulder >= z_lip + 2, str("tower shoulder ", z_shoulder, " must clear the lip top ", z_lip));
ms_check_units(z_shoulder, units);

ms_sockets = [[0, 0, 0, -1]];
ms_males   = [[tube_x, tube_y, z_tip, 1]];

module bowl_outer() {
    union() {
        cylinder(h = z0 + 0.01, r = sock_r);
        translate([0, 0, z0]) cylinder(h = cone_h, r1 = sock_r, r2 = cone_r_out + wall);
        translate([0, 0, z_rim - 0.01]) cylinder(h = lip_h + 0.01, r = cone_r_out + wall);
    }
}

module bowl_inside() {
    union() {
        translate([0, 0, z0]) cylinder(h = cone_h + 0.01, r1 = cone_r_in, r2 = cone_r_out);
        translate([0, 0, z_rim]) cylinder(h = z_tip - z_rim + 5, r = cone_r_out);
    }
}

module cone_wall() {
    intersection() {
        difference() { bowl_outer(); bowl_inside(); }
        translate([0, 0, 0]) cylinder(h = z_rim, r = r_lip_out + 1);
    }
}

module corbel_profile() {
    r_far = tube_pr + tube_r + 1;
    polygon([[r_lip_in + 0.05, z_rim - 0.01], [r_lip_out, z_rim - 0.01],
             [r_far, z_rim - 0.01 + r_far - r_lip_out],
             [r_far, z_shoulder], [r_lip_in + 0.05, z_shoulder]]);
}

module inlet_raw() {
    translate([p_pt[0], p_pt[1], z_rim - 0.01]) cylinder(h = z_shoulder - z_rim + 0.01, r = tube_r);
    translate([p_pt[0], p_pt[1], 0]) rotate([0, 0, psi]) {
        for (i = [0 : len(path_pts) - 2]) {
            a = path_pts[i]; b = path_pts[i + 1];
            hull() for (q = [a, b])
                translate([q[0], 0, z_rim - 0.01])
                    cylinder(h = q[1] + chan_lift + 12 - z_rim + 0.01, r = chan_r + wall);
        }
    }
}

module inlet_block() {
    intersection() {
        rotate_extrude() corbel_profile();
        inlet_raw();
    }
}

module trough_cut() {
    difference() {
        translate([p_pt[0], p_pt[1], 0]) rotate([0, 0, psi]) intersection() {
            union() for (i = [0 : len(path_pts) - 2]) {
                a = path_pts[i]; b = path_pts[i + 1];
                hull() {
                    for (q = [a, b]) {
                        translate([q[0], 0, q[1] + chan_lift]) sphere(r = chan_r, $fn = 48);
                        translate([q[0], 0, z_open_top + chan_r]) sphere(r = chan_r, $fn = 48);
                    }
                }
            }
            translate([-50, -50, 0]) cube([200, 100, z_open_top]);
        }
        cone_wall();
    }
}

module part() {
    difference() {
        union() {
            render() difference() { bowl_outer(); bowl_inside(); }
            inlet_block();
            translate([p_pt[0], p_pt[1], z_shoulder]) ms_male_spigot(bore = undef);
        }
        translate([0, 0, sock_depth]) mirror([0, 0, 1]) ms_female_bore(sock_depth, chamfer = 0.8);
        ms_passage(z0 + 1);
        trough_cut();
        translate([p_pt[0], p_pt[1], z_open_top - 0.5]) cylinder(h = z_tip - z_open_top + 8, r = chan_r);
    }
}

if (is_undef($ms_no_render)) { if (which == "coupon") ms_fit_coupon(); else part(); }
