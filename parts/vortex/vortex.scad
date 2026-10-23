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
// Inlet (v4). A drop tube with the male end on top stands OUTSIDE the lip, tangent
// to its inner face. The marble falls down the tube, is turned by a rounded scoop
// into a shallow descending trough, and leaves through a window in the lip with
// the trough floor flush with the lip inner face, travelling nearly tangentially.
// Nothing of the inlet lies inside the bowl. A small wedge under the inlet footprint
// carries the block; see support_deg for its overhang angle.
// ---------------------------------------------------------------------------
z_shoulder = ms_units(units);                // male shoulder: stack height from the mouth
z_tip      = z_shoulder + ms_male_len;
r_lip_in   = cone_r_out;                     // 55: lip inner face
r_lip_out  = cone_r_out + wall;              // 57.2
tube_r     = 12.5;                           // drop tube body radius (OD 25, narrower than the set body to keep the gusset small)
tube_pr    = r_lip_in + ms_male_hi / 2 + 0.4;// tube axis distance from the bowl axis: spigot clears the lip inner face
entry_deg  = 40;                             // trough heading, degrees off the rim tangent toward the bowl centre
bend_r     = 4;                            // marble centre path radius in the scoop (floor radius = this + 8)
trough_deg = 8;                              // descent of the trough, degrees below horizontal
marble_r   = ms_marble_d_half();
chan_r     = ms_bore / 2;                    // channel cut radius, 9.25
chan_lift  = chan_r - marble_r;              // cut path sits this far above the marble centre path
z_open_top = z_tip - ms_male_keepout - 0.1;   // trough cut and block top stay below the male keep-out
trough_ext = 24;                             // trough cut continues this far past the lip inner face

function ms_marble_d_half() = MS_MARBLE_D / 2;

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
phi_e  = 270 - trough_deg;
bend_b = [bend_r * (1 + cos(phi_e)), z_shoulder + bend_r * sin(phi_e)];       // end of the bend
lt_len = (s_len - bend_b[0]) / cos(trough_deg);                               // straight trough length to E
z_e_path = bend_b[1] - lt_len * sin(trough_deg);
z_sill   = z_e_path - marble_r;              // trough floor at the lip inner face (marble rests on it)
n_bend = 10;
function bend_pt(i) = let(f = phi_e - 180) [bend_r * (1 + cos(180 + f * i / n_bend)), z_shoulder + bend_r * sin(180 + f * i / n_bend)];
function trough_pt(t) = [bend_b[0] + t * cos(trough_deg), bend_b[1] - t * sin(trough_deg)];
path_pts = concat([for (i = [0 : n_bend]) bend_pt(i)],
                  [for (t = [lt_len / 3, 2 * lt_len / 3, lt_len, lt_len + trough_ext / 2, lt_len + trough_ext]) trough_pt(t)]);

function r_cone(z) = sock_r + (z - z0) * (r_lip_out - sock_r) / cone_h;

echo(tube_axis = p_pt, tube_pr = tube_pr, s_len = s_len, heading = psi, z_sill = z_sill, z_rim = z_rim,
     sill_above_rim = z_sill - z_rim, lip_top = z_lip);
echo(support_deg = support_deg);
assert(z_sill >= z_rim - 0.01, str("trough floor ", z_sill, " is below the cone rim ", z_rim));
assert(z_shoulder >= z_lip + 2, str("tower shoulder ", z_shoulder, " must clear the lip top ", z_lip));
ms_check_units(z_shoulder, units);

// socket mouths for scripts/check_keepout.sh: [x, y, z_mouth, dir]
ms_sockets = [[0, 0, 0, -1]];
ms_males   = [[tube_x, tube_y, z_tip, 1]];

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

// plan footprint of the inlet block: the tube circle hulled with the trough patch at the lip
module block_plan() {
    hull() {
        translate(p_pt) circle(r = tube_r);
        translate([e_pt[0] + 3 * dvec[0], e_pt[1] + 3 * dvec[1]]) circle(r = chan_r + wall);
    }
}

// Support under the inlet. The inlet sits outside the lip at rim height, so a 45 degree
// face cannot reach the bowl from it (the cone is itself 45 degrees, so a 45 degree plane
// never meets it). The support is a wedge that exists only under the inlet footprint:
// its underside is the shallowest cone that runs from the outer edge of the block at the
// rim height down to the bowl cone, support_drop below the rim. Its overhang angle is
// support_deg, reported by the echo; making support_drop larger steepens it.
support_drop = 30;
r_block_out  = tube_pr + tube_r + 0.5;
z_sup_low    = z_rim - support_drop;
support_deg  = atan(support_drop / (r_block_out - r_cone(z_sup_low)));

// (r, z) profile above the rim: lip outer face out to the block edge, up to the shoulder
module upper_profile() {
    polygon([[r_lip_in + 0.05, z_rim - 0.01], [r_block_out, z_rim - 0.01],
             [r_block_out, z_shoulder], [r_lip_in + 0.05, z_shoulder]]);
}
// (r, z) profile of the wedge: bowl cone on the inside, shallow cone underneath
module support_profile() {
    polygon([[r_cone(z_sup_low) - 0.3, z_sup_low], [r_block_out, z_rim - 0.01],
             [r_cone(z_rim - 0.01) - 0.3, z_rim - 0.01]]);
}

module inlet_block() {
    // above the rim: only the inlet footprint (tube circle to the shoulder, trough patch to the open top)
    intersection() {
        rotate_extrude() upper_profile();
        union() {
            translate([0, 0, z_rim - 0.01]) linear_extrude(height = z_open_top - z_rim + 0.01) block_plan();
            translate([p_pt[0], p_pt[1], z_rim - 0.01]) cylinder(h = z_shoulder - z_rim + 0.01, r = tube_r);
        }
    }
    // below the rim: the wedge, limited to the footprint pulled radially inward onto the cone
    intersection() {
        rotate_extrude() support_profile();
        translate([0, 0, z_sup_low - 1]) linear_extrude(height = z_rim - z_sup_low + 1) hull() { block_plan(); circle(r = 1); }
    }
}

// rounded, open-topped channel: spheres swept along the marble path, plus the same
// path lifted to the shoulder so the top is open (never above the shoulder)
module trough_cut() {
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
