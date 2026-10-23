// Mid-run vortex. A marble arrives through the male end on top of the inlet
// tube, is turned by a rounded scoop into a trough, leaves through a window in
// the lip nearly along the rim tangent, spirals down the 45 degree bowl and exits through
// the female socket at the bottom into the piece below.
//
// Drawn in USE orientation, which is also the print orientation: it stands on
// the outlet socket, mouth on the plate (lead-in 0.8 for elephant foot). No
// supports: every surface is 45 degrees or steeper, bridges stay under 20 mm. Connector numbers come from the library; see docs/set-profile.md.

include <../../lib/marble_set.scad>;

which = "vortex";       // "vortex" or "coupon"

units      = 3;         // body height in set units: socket mouth to male shoulder
bowl_d     = 110;       // rim diameter (inside)
wall       = ms_wall;
cone_deg   = 45;        // bowl wall from horizontal; never below 45
lip_h      = 12;        // vertical lip above the cone rim
sock_depth = 8;         // outlet socket depth (keep-out is 7.4)

$fn = $preview ? 32 : 96;

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

// ---------------------------------------------------------------------------
// Inlet (v5, three units tall). A drop tube with the male end on top stands
// OUTSIDE the lip. The marble falls down the tube, a rounded scoop (bend radius
// bend_r on the marble path) turns it into a trough descending trough_deg, and it
// leaves through a window in the lip, floor flush with the lip inner face, moving
// nearly along the rim tangent. Nothing of the inlet is inside the bowl.
// The block under the inlet is bounded below by a 45 degree cone corbel through the
// lip foot, so it needs no support and nothing reaches toward the socket.
// ---------------------------------------------------------------------------
z_shoulder = ms_units(units);                // male shoulder: stack height from the mouth
z_tip      = z_shoulder + ms_male_len;
r_lip_in   = cone_r_out;                     // 55: lip inner face
r_lip_out  = cone_r_out + wall;              // 57.2
tube_r     = sock_r;                         // drop tube body radius, the set's 27.9 OD
tube_pr    = r_lip_in + ms_male_hi / 2 + 0.4;// tube axis distance from the bowl axis: spigot clears the lip inner face
entry_deg  = 25;                             // trough heading, degrees off the rim tangent toward the bowl centre
bend_r     = 20;                             // marble centre path radius in the scoop
trough_deg = 20;                             // descent of the trough, degrees below horizontal
sill_rise  = 4;                              // trough floor at the lip inner face, above the cone rim
marble_r   = MS_MARBLE_D / 2;
chan_r     = ms_bore / 2;                    // channel cut radius, 9.25
chan_lift  = chan_r - marble_r;              // cut path sits this far above the marble centre path
z_open_top = z_tip - ms_male_keepout - 0.1;  // cuts stay below the male keep-out
trough_ext = 14;                             // trough cut continues this far past the lip inner face
n_bend     = 16;

// exit point E on the lip inner face at azimuth 0; heading D; tube axis P upstream of E
e_pt   = [r_lip_in, 0];
dvec   = [-sin(entry_deg), cos(entry_deg)];
psi    = 90 + entry_deg;                     // heading angle of D
sh_a   = r_lip_in * sin(entry_deg);
s_len  = -sh_a + sqrt(sh_a * sh_a + tube_pr * tube_pr - r_lip_in * r_lip_in);   // tube axis to E along D
p_pt   = [e_pt[0] - s_len * dvec[0], e_pt[1] - s_len * dvec[1]];
tube_x = p_pt[0];
tube_y = p_pt[1];

// marble centre path in the vertical plane of the trough: s along D from the tube axis, z up
phi_e    = 270 - trough_deg;
bend_dx  = bend_r * (1 + cos(phi_e));
lt_len   = (s_len - bend_dx) / cos(trough_deg);                 // straight trough length to E
z_sill   = z_rim + sill_rise;                                    // cut floor at E
z_e_path = z_sill + marble_r;
z_bend0  = z_e_path + lt_len * sin(trough_deg) + bend_r * cos(trough_deg);   // path starts here, inside the tube
bend_b   = [bend_dx, z_bend0 + bend_r * sin(phi_e)];
function bend_pt(i) = let(a = 180 + (phi_e - 180) * i / n_bend) [bend_r * (1 + cos(a)), z_bend0 + bend_r * sin(a)];
function trough_pt(t) = [bend_b[0] + t * cos(trough_deg), bend_b[1] - t * sin(trough_deg)];
path_pts = concat([for (i = [0 : n_bend]) bend_pt(i)],
                  [for (t = [lt_len / 3, 2 * lt_len / 3, lt_len, lt_len + trough_ext / cos(trough_deg)]) trough_pt(t)]);

function r_cone(z) = sock_r + (z - z0) * (r_lip_out - sock_r) / cone_h;
function world_r(q) = norm([p_pt[0] + q[0] * dvec[0], p_pt[1] + q[0] * dvec[1]]);
// corbel: block may only exist above z_rim + (r - r_lip_out); check the channel floor keeps a wall over it
margins = [for (q = path_pts) if (world_r(q) > r_lip_out) (q[1] - marble_r) - (z_rim + world_r(q) - r_lip_out) - ms_wall];

echo(tube_axis = p_pt, s_len = s_len, heading = psi, z_bend0 = z_bend0, z_sill = z_sill, z_rim = z_rim,
     lt_len = lt_len, lip_top = z_lip, min_floor_margin = min(margins));
assert(min(margins) >= 0, str("channel floor dips under the 45 degree corbel by ", -min(margins)));
assert(z_bend0 < z_open_top - chan_r, "scoop starts too close to the male keep-out");
assert(z_shoulder >= z_lip + 2, str("tower shoulder ", z_shoulder, " must clear the lip top ", z_lip));
ms_check_units(z_shoulder, units);

// socket mouths and male tips for scripts/check_keepout.sh
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

// the cone wall below the rim: the channel cut must never touch it
module cone_wall() {
    intersection() {
        difference() { bowl_outer(); bowl_inside(); }
        translate([0, 0, 0]) cylinder(h = z_rim, r = r_lip_out + 1);
    }
}

// (r, z) region above the 45 degree corbel through the lip foot, outside the lip inner face
module corbel_profile() {
    r_far = tube_pr + tube_r + 1;
    polygon([[r_lip_in + 0.05, z_rim - 0.01], [r_lip_out, z_rim - 0.01],
             [r_far, z_rim - 0.01 + r_far - r_lip_out],
             [r_far, z_shoulder], [r_lip_in + 0.05, z_shoulder]]);
}

// block outline before the corbel clips it: tube column to the shoulder, plus tall prisms along the trough
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

// rounded, open-topped channel: spheres swept along the marble path, each also lifted to the
// keep-out line so the top is open
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
            // male end on top of the tube, overlap into the block
            translate([p_pt[0], p_pt[1], z_shoulder]) ms_male_spigot(bore = undef);
        }
        // outlet socket: mouth at z = 0 facing down, plain bore up to the floor
        translate([0, 0, sock_depth]) mirror([0, 0, 1]) ms_female_bore(sock_depth, chamfer = 0.8);
        ms_passage(z0 + 1);
        trough_cut();
        // drop bore, open through the tip of the male end
        translate([p_pt[0], p_pt[1], z_open_top - 0.5]) cylinder(h = z_tip - z_open_top + 8, r = chan_r);
    }
}

if (is_undef($ms_no_render)) { if (which == "coupon") ms_fit_coupon(); else part(); }
