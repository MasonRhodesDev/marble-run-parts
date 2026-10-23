#!/usr/bin/env bash
# Geometric keep-out test for every part that declares ms_sockets.
# For each socket: (1) nothing of the part may lie inside the bore for the
# keep-out depth; (2) the full wall ring must be present there (no windows).
# Fails if either rendered test volume is non-empty. Needs openscad on PATH.
set -uo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); fail=0
for f in parts/*/*.scad; do
  grep -q '^ms_sockets' "$f" || continue
  abs=$(realpath "$f"); n=$(grep -o '\[\[.*\]\]' "$f" | head -1 | tr -cd '[' | wc -c); n=$((n-1))
  for ((i=0;i<n;i++)); do
    for test in bore wall; do
      cat > "$tmp/t.scad" <<SCAD
\$ms_no_render = true;
include <$abs>;
$( [ $test = bore ] && echo "intersection() { part(); ms_keepout_bore(ms_sockets[$i]); }" || echo "difference() { ms_keepout_wall(ms_sockets[$i]); part(); }" )
SCAD
      out=$(openscad -o "$tmp/t.stl" "$tmp/t.scad" 2>&1)
      if echo "$out" | grep -q 'top level object is empty'; then echo "ok    $f socket $i $test"
      else echo "FAIL  $f socket $i $test (keep-out violated)"; fail=1; fi
    done
  done
done
rm -rf "$tmp"; exit $fail
