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
