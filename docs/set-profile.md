# Tube marble run set: connector profile

Reference for finding or designing parts that plug into the household tube
marble run. The set is the translucent-tube type sold under names such as
Marble Genius; published parts made for that name have fit so far.

## Measured connector (calipers, 2026-10-23)

| Feature | Value | Note |
|---|---|---|
| Male end, across arcs | 23.60 mm | round with alternating flats |
| Male end, across flats | 22.90 mm | six-ish flats, only the arcs touch |
| Female mouth bore | 23.23 mm | round |
| Engagement length | ~18 mm | |
| Marble | 16 mm assumed | confirm |

The friction fit comes from the male arcs being 0.37 mm over the female bore
while the flats clear it. Copy that scheme on printed male ends rather than a
plain cylinder, so the press is light and self-centring.

## Fit log for printed parts

Slicer profile in use applies +0.15 mm to holes and -0.05 mm to contours
(OrcaSlicer, 0.4 mm nozzle, PLA). All CAD numbers below are pre-compensation.

| Part | CAD | Printed (est.) | Result |
|---|---|---|---|
| Diverter inlet, Printables 163082 | male per STL | | perfect |
| Diverter outlets, Printables 163082 | female 23.75 | ~23.9 | barely too loose on the set's male |
| Diverter paddle, same model | | | pending |
| Joyin bowl spigot, Printables 1700829, scaled 0.926 | male 23.6 round | ~23.5 | too small, do not reuse Joyin parts |
| Fit coupon v1, this repo | female 23.35 / male 23.65 arcs, 22.90 flats | ~23.5 / ~23.55 | printing |

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
