#!/usr/bin/env bash

# Set absolute split ratio for dwindle layout
# Usage: set-split-ratio.sh <ratio>
# Where ratio is between 0 and 1 (e.g., 0.25 for 1/4, 0.5 for 1/2)

TARGET_RATIO=$1

if [ -z "$TARGET_RATIO" ]; then
    echo "Usage: $0 <ratio>"
    exit 1
fi

# Get current window info
WINDOW_INFO=$(hyprctl activewindow -j)

# For dwindle layout, we need to reset to 0.5 first, then adjust
# Reset to center (0.5)
hyprctl dispatch splitratio exact

# Small delay to ensure the reset completes
sleep 0.05

# Now set to target ratio
# Calculate the change needed from 0.5
DELTA=$(echo "$TARGET_RATIO - 0.5" | bc -l)

# Apply the delta
hyprctl dispatch splitratio "$DELTA"
