#!/usr/bin/env bash

# Set absolute split ratio for dwindle layout
# Usage: set-split-ratio.sh <ratio>
# Where ratio is between 0 and 1 (e.g., 0.25 for 1/4, 0.5 for 1/2)

TARGET_RATIO=$1

if [ -z "$TARGET_RATIO" ]; then
    echo "Usage: $0 <ratio>"
    exit 1
fi

# Dwindle's split ratio runs 0..2 with 1.0 = even, so double the 0..1 share.
RATIO=$(awk -v r="$TARGET_RATIO" 'BEGIN { print r * 2 }')

# Lua config (hyprland.lua) evaluates dispatch args as Lua; legacy syntax is the fallback.
hyprctl dispatch "hl.dsp.layout(\"splitratio $RATIO exact\")" >/dev/null 2>&1 ||
    hyprctl dispatch splitratio exact "$RATIO"
