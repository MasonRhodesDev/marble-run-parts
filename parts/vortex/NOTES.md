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

## Known defects in the inlet tower (fix before printing v3)

1. **No ramp at the bottom of the shaft.** `tower_cuts()` builds the shaft
   as a hull that includes a flat disc at `z_win`, so the floor is level and
   the marble does not leave through the window. Fix: hull the top disc with
   a disc tilted by `ramp_deg` whose low edge sits at the window sill, and
   drop the flat bottom disc. Verify with
   `scripts/preview.sh out/vortex.stl x.png section-x=<r_axis>` and confirm
   the floor slopes down toward +y.
2. **Window cuts through the bowl wall.** The sill `z_win` is the bowl height
   at the tower axis plus 2.5, but the bowl rises toward the lip, so on the
   +y side of the tower the cube drops below the bowl surface and holes the
   cone. Fix: clip the window to the tower cylinder and subtract the bowl
   shell from the cut, or set the sill from the bowl height at the window's
   farthest point. Verify there is no hole in the bowl from the outside in
   an iso render and that `scripts/check_keepout.sh` still passes.

## Open questions for the spec thread

- Official female bore read 23.23 at the mouth and 23.5 deeper in. If that is
  a gripping band with relief, sockets should copy it. Until answered, the
  socket stays plain 23.35.
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
