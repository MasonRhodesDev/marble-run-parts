#!/usr/bin/env bash
# Render every parts/*/*.scad to out/<part>.stl. Needs openscad on PATH.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p out
for f in parts/*/*.scad; do
  name=$(basename "${f%.scad}")
  echo "== $name"
  openscad -o "out/$name.stl" "$f"
done
echo "== fit coupon"
openscad -o out/fit_coupon.stl -D 'part="coupon"' parts/vortex/vortex.scad
