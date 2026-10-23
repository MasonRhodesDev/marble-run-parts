#!/usr/bin/env bash
# Geometric keep-out test for every part that declares ms_sockets / ms_males.
# For each connector end: (1) nothing of the part may lie inside the bore for
# the keep-out length; (2) the full wall ring must be present there (no
# windows or cuts). Fails if either rendered test volume is non-empty.
# A part with neither declaration is reported and skipped. Needs openscad.
set -uo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); fail=0
for f in parts/*/*.scad; do
  abs=$(realpath "$f")
  if ! grep -q -E '^ms_(sockets|males)' "$f"; then echo "skip  $f declares no connector ends"; continue; fi
  for kind in sockets males; do
    line=$(grep -E "^ms_$kind" "$f" | head -1) || true
    [ -z "$line" ] && continue
    n=$(echo "$line" | grep -o '\[\[.*\]\]' | tr -cd '[' | wc -c); n=$((n-1))
    if [ $kind = sockets ]; then bm=ms_keepout_bore; wm=ms_keepout_wall; else bm=ms_male_keepout_bore; wm=ms_male_keepout_wall; fi
    for ((i=0;i<n;i++)); do
      for test in bore wall; do
        cat > "$tmp/t.scad" <<SCAD
\$ms_no_render = true;
include <$abs>;
$( [ $test = bore ] && echo "intersection() { part(); $bm(ms_$kind[$i]); }" || echo "difference() { $wm(ms_$kind[$i]); part(); }" )
SCAD
        out=$(openscad -o "$tmp/t.stl" "$tmp/t.scad" 2>&1)
        if echo "$out" | grep -q 'top level object is empty'; then echo "ok    $f ${kind%s} $i $test"
        else echo "FAIL  $f ${kind%s} $i $test (keep-out violated)"; fail=1; fi
      done
    done
  done
done
rm -rf "$tmp"; exit $fail
