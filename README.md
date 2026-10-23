# marble-run-parts

Connector spec, OpenSCAD library and custom parts for the translucent tube
marble run sets sold under names like Marble Genius, plus a log of published
models that fit them.

- `docs/set-profile.md`: measured connector dimensions, print tolerances, fit log.
- `docs/compatible-models.md`: third-party models that fit (or do not), with links.
- `lib/marble_set.scad`: the connector as OpenSCAD modules. Every part includes it.
- `parts/<name>/`: our designs. First one is a mid-run vortex.
- `scripts/build.sh`: renders every part to `out/*.stl` (needs `openscad`).
- `scripts/preview.sh`: PNG previews and cut-away sections for review.

## Quick start

```sh
scripts/build.sh                  # out/vortex.stl, out/fit_coupon.stl
scripts/preview.sh parts/vortex/vortex.scad vortex.png iso
scripts/preview.sh out/vortex.stl section.png section-y=0
```

Print `out/fit_coupon.stl` first on any new printer or filament and record the
result in `docs/set-profile.md` before printing a full part.

## Designing a new part

Include the library and use its modules instead of drawing the connector:

```openscad
include <../../lib/marble_set.scad>;
difference() {
    union() { my_body(); ms_male_spigot(); }
    ms_passage(20);
}
```

Keep walls at 45 degrees or steeper and stand the part on its spigot or a flat
face, so nothing needs supports on a surface a marble touches.

## License

Designs, documentation and the OpenSCAD files (`lib/`, `parts/`, `docs/`) are
licensed under CC BY-SA 4.0 (`LICENSE`). The helper scripts in `scripts/` are
MIT (`LICENSE-MIT`).
