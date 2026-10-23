# Tube marble run set: connector profile

Reference for finding or designing parts that plug into the household tube
marble run. The set is the translucent-tube type sold under names such as
Marble Genius; published parts made for that name have fit so far.

## Orientation

As marbles and gravity see it, the male end is the TOP of a piece and the
female socket is the BOTTOM: a marble enters through the male end and leaves
through the socket into the male end of the piece below. On the official
piece the male end is inset about 1 mm into the body, with a distinct step
inside where its 18.5 bore meets the body bore. Parts are drawn in whatever
orientation prints best and the part file says which.

## Measured connector (calipers, 2026-10-23)

| Feature | Value | Note |
|---|---|---|
| Male end, across arcs | 23.60 mm | round with alternating flats |
| Male end, across flats | 22.90 mm | six shallow tangent flats about 4.5 mm wide; only the arcs touch |
| Female bore | 23.50 mm | round, constant from the lip to the step at the male insert (an earlier 23.23 reading was wrong) |
| Edge chamfers | cosmetic | official tip and mouth edges are barely broken; ours are print lead-ins |
| Male end height | 6.4 mm | gripping part, fine chamfer at the tip |
| Unit height (stacking pitch) | 34.91 mm | body of the base piece |
| Base piece overall | 41.31 mm | body plus the 6.4 mm male end |
| Wall | 2.2 mm | body, and the male end at its flats |
| Male end bore | 18.5 mm | derived: 22.9 minus two walls; the set's marble passage |
| Body outside | 27.9 mm | derived: 23.5 plus two walls |
| Socket | full body depth | 23.23 bore down to a seat ring about one wall wide, just above the male end |
| Marble | 16 mm assumed | confirm |

The friction fit comes from the male arcs being 0.1 mm over the female bore
while the flats clear it by 0.6. Copy that scheme on printed male ends rather than a
plain cylinder, so the press is light and self-centring.

## Fit log for printed parts

Slicer profile in use (OrcaSlicer, 0.4 mm nozzle, PLA, direct drive, 210 C,
1.5 mm retraction at 45 mm/s) applies xy_hole_compensation 0.15 and
xy_contour_compensation -0.05. Both are per side, so a bore prints about
0.30 wider than drawn and a spigot about 0.10 narrower. The printed sizes in
the table are estimates on that basis, and the coupon result supports it: a
spigot drawn 23.65 printing near 23.55 is a 0.05 press in the 23.5 bore, and
a socket drawn 23.35 printing near 23.65 sits on the 23.6 arcs, which is the
"perfect" fit reported.

| Part | CAD | Printed (est.) | Result |
|---|---|---|---|
| Diverter inlet, Printables 163082 | male per STL | | perfect |
| Diverter outlets, Printables 163082 | female 23.75 | ~24.05 | barely too loose on the set's male |
| Diverter paddle, same model | | | loose by design, works |
| Joyin bowl spigot, Printables 1700829, scaled 0.926 | male 23.6 round | ~23.5 | too small, do not reuse Joyin parts |
| Fit coupon v1, this repo | female 23.35 / male 23.65 arcs, 22.90 flats, both 18 long | ~23.65 / ~23.55 | socket: perfect at the top end, too tight at the plate end (elephant foot); spigot: fits very well. Lengths cut to 6.5 / 8 and mouth chamfers added in v2 |

Update this table after every fit test. The library constants in
`lib/marble_set.scad` must match the last row that passed.

## Designing a part

1. `include <marble_set.scad>` and use `ms_female_socket`, `ms_male_spigot`,
   `ms_female_bore`, `ms_passage`. Never redraw the connector.
2. Print orientation: stand the part on its male spigot or lay it on a flat
   face; keep every wall at 45 degrees or steeper so no supports touch a
   marble surface or a visible surface. Bridges up to ~20 mm are fine.
3. Print the fit coupon (`part="coupon"` in `parts/vortex/vortex.scad`, or
   `ms_fit_coupon()`) before any part over an hour.
4. 100% infill for load-bearing arms, 3 walls otherwise. Marble passages at
   least marble + 1.5 mm.
5. A female socket is plain bore for the exposed male end height plus 1 mm
   clearance (7.4 mm) below its mouth before any other feature: no seat,
   window, opening or change of diameter in that zone. Asserted on the drawn
   depth and verified geometrically by `scripts/check_keepout.sh`.
6. A male end extends at least 1 mm up into the body it belongs to, as the
   official piece does (`ms_male_overlap`, asserted). Where a socket ends
   inside a part, its floor is one wall plus that overlap thick.
7. A male end is an uninterrupted ring with a clear bore from its tip down
   through the overlap and 1 mm beyond (8.5 mm, `ms_male_keepout`). No
   window, cut or feature may touch that zone. Verified geometrically like
   the socket keep-out; parts list male tips in `ms_males`.
8. Make the body height a whole number of units (`ms_units(n)`, 34.91 mm
   each) so a custom part sits level with official pieces in the same row.
   Body means spigot shoulder to socket mouth; the male end hides inside the
   socket below and adds nothing to the stack. Only parts with no male end
   (top pieces, free-standing bases) have an unconstrained height. Socket
   depth is inside the body and does not affect the pitch.

## How the rules are enforced

Checks live in the library's drawing modules, on the numbers actually drawn:
`ms_male_spigot` asserts height, overlap and wall; `ms_female_bore` asserts
depth, keep-out and lead-in; `ms_passage` asserts marble clearance;
`ms_check_units(body_h, units)` asserts the stacking pitch. Relations between
library constants are asserted once at include time.

What a part draws around a connector cannot be seen by those asserts, so the
build also runs `scripts/check_keepout.sh`: every part lists its socket
mouths in `ms_sockets = [[x, y, z, dir], ...]` and its male tips in
`ms_males = [[x, y, z, dir], ...]`, exposes `module part()`, and the script
renders two probes per end against the part, one that must find nothing
inside the bore and one that must find the full wall ring, for the keep-out
length of that end. A non-empty probe fails the build. Rules the library
cannot check (orientation, infill, supports) are advice in this file.

## Finding published parts

- Search "Marble Genius" on Printables and Thingiverse. Confirmed series by
  Old Curmudgeon: 3-way splitter, 2-to-1 ramp, jump ramp, closed spiral,
  spacers, support cone, funnel top support (Printables 42379 to 42386).
- Look for 23.75 or 23.8 in descriptions; designers who state it fit this set.
- Ignore "Joyin compatible" (25.4 mm male), Quadrilla, Hubelino, Gravitrax,
  Hape, and anything for steel balls.
- Expect published female sockets to run loose (23.75 drawn). Scale is the
  wrong fix; edit the socket or print a sleeve.

## Files

- `lib/marble_set.scad`: connector library and fit coupon.
- `parts/vortex/vortex.scad`: mid-run vortex module, first custom part on this profile.
- Third-party STLs are not stored here; see `docs/compatible-models.md` for links.
