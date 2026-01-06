#!/bin/bash

#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

mapfile -t pairs < <(
  xrandr -q | awk '
    function flush() {
      if (out != "" && pref != "") {
        print out "\t" pref
      }
    }

    BEGIN { out=""; pref=""; }

    # Start of a connected output block
    /^[A-Za-z0-9-]+ connected/ {
      flush()
      out = $1
      pref = ""
      next
    }

    # A mode line begins with something like 1920x1080
    out != "" && $1 ~ /^[0-9]+x[0-9]+$/ {
      # If this mode is preferred (+), record it.
      # Prefer *+ over + if we see it.
      if ($0 ~ /\*\+/) { pref = $1; next }
      if ($0 ~ /\+/ && pref == "") { pref = $1; next }
    }

    END { flush() }
  '
)

if ((${#pairs[@]} == 0)); then
  echo "No connected outputs with a preferred (+) mode found."
  exit 1
fi

for line in "${pairs[@]}"; do
  output="${line%%$'\t'*}"
  mode="${line##*$'\t'}"

  cmd=(xrandr --output "$output" --mode "$mode")

  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[DRY RUN] %q ' "${cmd[@]}"
    echo
  else
    echo "Setting $output to preferred mode $mode"
    "${cmd[@]}"
  fi
done

echo "Setting screen 2 left of screen 1"
xrandr --output Virtual-1 --primary --output Virtual-2 --left-of Virtual-1
