#!/bin/bash

# Random Wallpaper Changer
# Selects and applies a random wallpaper from the wallpapers directory

set -euo pipefail  # Exit on error, undefined vars, pipe failures

WALLPAPER_DIR="$HOME/wallpapers"
WALLPAPER_CACHE="$HOME/.cache/current_wallpaper"

# Validation: Check if wallpaper directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    echo "Please create the directory and add wallpapers"
    exit 1
fi

# Validation: Check if hyprctl is available
if ! command -v hyprctl &> /dev/null; then
    echo "Error: hyprctl command not found"
    echo "Make sure Hyprland is installed and running"
    exit 1
fi

# Find all available wallpapers
echo "Searching for wallpapers in $WALLPAPER_DIR..."
mapfile -t wallpapers < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \))

if [[ ${#wallpapers[@]} -eq 0 ]]; then
    echo "Error: No readable wallpapers found in $WALLPAPER_DIR"
    echo "Please add image files (.jpg, .png, .jpeg) to the directory"
    exit 1
fi

# Detect connected monitors
echo "Detecting connected monitors..."
mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')

if [[ ${#monitors[@]} -eq 0 ]]; then
    echo "Error: No monitors detected"
    exit 1
fi

echo "Found ${#monitors[@]} monitor(s): ${monitors[*]}"

# Validate hyprpaper is running
if ! pgrep hyprpaper > /dev/null; then
    echo "Warning: hyprpaper is not running, attempting to start it..."
    hyprpaper > /dev/null 2>&1 &
    sleep 2

    if ! pgrep hyprpaper > /dev/null; then
        echo "Error: Could not start hyprpaper"
        exit 1
    fi
fi

# Select different random wallpapers for each monitor
# Shuffle wallpapers first
mapfile -t shuffled < <(printf '%s\n' "${wallpapers[@]}" | shuf)

wallpaper_index=0
PRIMARY_WALLPAPER=""
all_successful=true

for monitor in "${monitors[@]}"; do
    # Get wallpaper for this monitor (cycle through if we have more monitors than wallpapers)
    wallpaper="${shuffled[$((wallpaper_index % ${#shuffled[@]}))]}"

    # Validate selected wallpaper file
    if [[ ! -r "$wallpaper" ]]; then
        echo "Warning: Selected wallpaper is not readable: $wallpaper, skipping..."
        wallpaper_index=$((wallpaper_index + 1))
        continue
    fi

    echo "Setting $monitor: $(basename "$wallpaper")"

    # Set wallpaper using hyprctl reload (handles preload/unload automatically)
    if hyprctl hyprpaper reload "$monitor,$wallpaper" 2>/dev/null; then
        echo "  ✓ Successfully changed wallpaper for $monitor"

        # Save first wallpaper as primary for lock screen
        if [[ -z "$PRIMARY_WALLPAPER" ]]; then
            PRIMARY_WALLPAPER="$wallpaper"
        fi
    else
        echo "  ✗ Failed to change wallpaper for $monitor"
        echo "    Trying fallback method..."
        # Fallback: try preload + wallpaper method
        hyprctl hyprpaper preload "$wallpaper" 2>/dev/null || true
        if hyprctl hyprpaper wallpaper "$monitor,$wallpaper" 2>/dev/null; then
            echo "  ✓ Fallback succeeded for $monitor"
            if [[ -z "$PRIMARY_WALLPAPER" ]]; then
                PRIMARY_WALLPAPER="$wallpaper"
            fi
        else
            echo "  ✗ Fallback also failed for $monitor"
            all_successful=false
        fi
    fi

    wallpaper_index=$((wallpaper_index + 1))
done

# Update symlink to primary wallpaper for hyprlock
if [[ -n "$PRIMARY_WALLPAPER" ]]; then
    ln -sf "$PRIMARY_WALLPAPER" "$WALLPAPER_CACHE"
    echo "Updated wallpaper symlink for lock screen"
fi

if [[ "$all_successful" = true ]]; then
    echo "All wallpapers changed successfully!"
else
    echo "Some wallpapers failed to change. Try running generate_hyprpaper_config.sh first"
    exit 1
fi

