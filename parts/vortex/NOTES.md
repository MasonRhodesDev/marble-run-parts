# Vortex: iteration notes and handoff

Owner thread: the vortex print iteration. Spec and library changes (anything
under `lib/` or `docs/`) belong to the spec thread; propose them there and
keep the vortex consuming the library as is.

## Status, 2026-10-23

- v2 printed (4h16m, 43 g, no supports, 210 C, 1.5 mm retraction). Both
  connectors fit an official piece perfectly. Fit is settled; do not touch
  the connector numbers.
- v2 had the connectors on the wrong ends (socket on the inlet, spigot on the
  outlet). v3 in `vortex.scad` already flips them: male inlet on top of the
  rim tower, female outlet at the bottom. Not yet printed.

## Inlet tower defects (both FIXED in v3, 2026-10-23)

1. FIXED: the shaft is now a round bore cut above a real 45 degree plane that meets the sill at the +y edge, no flat floor. Original note: **No ramp at the bottom of the shaft.** `tower_cuts()` builds the shaft
   as a hull that includes a flat disc at `z_win`, so the floor is level and
   the marble does not leave through the window. Fix: hull the top disc with
   a disc tilted by `ramp_deg` whose low edge sits at the window sill, and
   drop the flat bottom disc. Verify with
   `scripts/preview.sh out/vortex.stl x.png section-x=<r_axis>` and confirm
   the floor slopes down toward +y.
2. FIXED: sill is set from the bowl height at the tower exit point (x = tower axis, y = tower radius), 2 mm above it; all tower cuts have the bowl shell subtracted so the wall is never cut, and the window is clipped to the tower cylinder and to above the ramp. Original note: **Window cuts through the bowl wall.** The sill `z_win` is the bowl height
   at the tower axis plus 2.5, but the bowl rises toward the lip, so on the
   +y side of the tower the cube drops below the bowl surface and holes the
   cone. Fix: clip the window to the tower cylinder and subtract the bowl
   shell from the cut, or set the sill from the bowl height at the window's
   farthest point. Verify there is no hole in the bowl from the outside in
   an iso render and that `scripts/check_keepout.sh` still passes.

## Open questions for the spec thread

- Resolved: the official female bore is 23.5 straight through. Socket CAD
  stays 23.35 (verified fit).
- Marble diameter is assumed 16. Passage is 18.5 like the set.

## Build, check, slice, print

```sh
scripts/build.sh                                   # STLs + keep-out test
~/.claude/skills/openscad-parts/scripts/preview.sh out/vortex.stl iso.png iso
~/.claude/skills/openscad-parts/scripts/slice.sh out/vortex.stl ~/Documents/marble-vortex/out-v3 nosupport
```

Upload and start through Moonraker per the `openscad-parts` skill
(`references/moonraker.md`); start only when the owner says so. v3 prints
standing on the outlet socket, mouth on the plate, so keep the brim and the
0.8 lead-in.

## Print log

| Version | Date | Time | Result |
|---|---|---|---|
| v1 | not printed | | scaled Joyin bowl instead, wrong connector, abandoned |
| v2 | 2026-10-23 | 4h16m | fits perfect both ends; inverted; no ramp; window holes the bowl |
| v3 | 2026-10-23, started 15:35 | est 4h27m | connectors flipped, 45 degree ramp, window clear of the bowl; sliced at 200 C, 2 mm retraction, slope z hop, 200 mm/s travel for stringing; watch the first marble for rubbing on the bowl wall inside the shaft |
| v3 | uploaded as marble_vortex_v3.gcode; CANCELLED 8 min in after the owner inspected the model (four inlet findings: skin across the male tip, flat ramp instead of a curve, lip at the tower/bowl junction, inlet inlaid in the marble path) | est 4h30m, 43.6 g, 76.4 mm, 0% support | flipped connectors, 45 degree ramp, sill z 46.41 (2 mm above bowl at the exit), bowl wall intact |

v3 notes: a sectioned check (x = tower axis and off axis) shows the ramp falling 45 degrees to the sill at +y and a continuous bowl wall under the window. Beyond the two fixes: `window_h` (26) now exceeds the tower above the sill, so the +y tower wall is open to the spigot (no window roof bridge). The shaft is clipped by the bowl shell, so on the outer side of the shaft the wall rises into the bore sides; unprinted, so check marble travel on the print.
| v4 | 2026-10-23 | not sliced | redesigned inlet, awaiting owner inspection in OpenSCAD |

v4 design (spans commits b94c3dd, which swept in an early copy of the edit, and the commit after it).
Drop tube (OD 25, male end on top, shoulder at exactly two units) stands outside the lip with its axis 67.2 mm from the bowl axis. A rounded scoop (marble path radius 4, cut radius 9.25, hulls of spheres) turns the marble into a trough descending 8 degrees that crosses the lip at 40 degrees off the tangent. The trough floor ends flush with the lip inner face 0.5 mm above the cone rim. The scoop and trough cut stop below the male keep-out (tip minus 8.5), the drop bore is cut well past the tip, and `ms_males` is declared. Nothing of the inlet is inside r = 55 below the lip top.
Known compromise: with the shoulder fixed at two units the inlet cannot be both outside the lip and fully 45 degree supported, because the cone is itself 45 degrees, so a 45 degree face from the inlet never meets it. The wedge under the inlet (`support_drop`, `support_deg` in the file) has an underside about 30 degrees from horizontal, so the print needs a slicer check for that overhang. Options: a 3 unit body, a smaller bowl, or accept the wedge. The earlier full 45 degree skirt worked but added a large fin to the socket, which the owner rejected.
Preview speed: `$fn` is 32 in preview and 96 in render; the bowl body is wrapped in render().
| v5 | 2026-10-23 | not sliced | three units; 45 degree corbel under the inlet, scoop radius 20, trough 20 degrees; uncommitted, awaiting owner decision |

v5 design: units = 3 (shoulder 104.73). Tube OD 27.9 at 67.2 mm from the bowl axis. The block is clipped below by a 45 degree cone corbel through the lip foot, so nothing reaches the socket. Marble path bend radius 20, trough descent 20 degrees, entry 25 degrees off the tangent, floor flush with the lip inner face 4 mm above the cone rim. The channel is an open-top gutter of sphere hulls; the cone wall is protected from the cut. Checks: overhang none beyond 45 degrees, 0 open edges, marble clearance probes clear along the whole path.

v5 print started 2026-10-23 16:30 as marble_vortex_v5.gcode: est 5h00m, 47 g, 111 mm, 0% support, 200 C, 2 mm retraction, slope z hop. Owner approved from renders on the phone.

v5 first print 2026-10-23 16:12 to 21:15: the part DETACHED from the bed; the job ran to the end printing air. Cause: the slicer profile had brim_type auto_brim, which decided no brim for this part, so 111 mm stood on a 183 mm2 ring. Fix applied in the profile: brim_type outer_only, 12 mm, gap 0 (51 mm brim disc, about nine times the footprint). v5 brim reprint started 21:57 as marble_vortex_v5_brim.gcode, est 5h05m. Model unchanged.

v5 brim reprint 2026-10-23 21:57 to 2026-10-24 03:09, 5h05m: the brim held and the part stayed down, but the spool RAN OUT near the top and the job finished printing air. The runout sensor had no filament routed through it, so nothing paused. Moonraker history shows the job as completed with 16055 of 16057 mm "used", which is the extruder count, not the spool. Lesson, now in the skill's moonraker reference: before starting, confirm the sensor reads filament_detected true and compare the gcode's filament total against what is left on the spool.

2026-10-24 08:19: v5 reprint started as marble_vortex_v5_210.gcode on a fresh spool. Filament is PLA+ (not plain PLA); nozzle raised from 200 to 210, first layer 215, because the 200 C print showed unfused strands between layers on the cone. Model and brim unchanged, est 5h05m, 47.9 g. Runout sensor fixed before start: the switch is on the Z endstop header, PA7, not PA4; it reads true with filament and flips on the lever.

v5 reprint at 210 completed 2026-10-24 13:30 after 5h06m, filament present at the end (16061 mm extruded of 16057 planned), so this one is whole. One pause at 09:59 came from a phantom touch on the KlipperScreen panel pressing Pause (nobody present); resumed after two minutes, expect a small seam at about z 61. KlipperScreen now blanks after 60 s while printing. Awaiting owner test: socket fit, spigot fit, marble spin and exit, layer bonding at 210 on PLA+.
