#!/usr/bin/env bash
# preview.sh <file.scad|file.stl> <out.png> [iso|top|section-x=<mm>|section-y=<mm>]
# Renders a PNG with openscad. "section-x=40" cuts away x>40 so you can see inside.
set -euo pipefail
in=$1; out=$2; view=${3:-iso}
tmp=$(mktemp --suffix=.scad)
case "$in" in *.stl) body="import(\"$(realpath "$in")\");";; *) body="include <$(realpath "$in")>;";; esac
case "$view" in
  iso)     cam="--camera=0,0,40,60,0,35,420 --projection=p"; echo "$body" > "$tmp";;
  top)     cam="--camera=0,0,40,0,0,0,420 --projection=o";   echo "$body" > "$tmp";;
  section-x=*) v=${view#section-x=}; cam="--camera=$v,0,40,90,0,90,300 --projection=o"
           echo "difference(){ $body translate([$v,-500,-500]) cube(1000); }" > "$tmp";;
  section-y=*) v=${view#section-y=}; cam="--camera=0,$v,40,90,0,0,300 --projection=o"
           echo "difference(){ $body translate([-500,$v,-500]) cube(1000); }" > "$tmp";;
  *) echo "unknown view $view" >&2; exit 2;;
esac
openscad -o "$out" $cam --imgsize=1000,900 --viewall --autocenter "$tmp" 2>/dev/null
rm -f "$tmp"; echo "$out"
