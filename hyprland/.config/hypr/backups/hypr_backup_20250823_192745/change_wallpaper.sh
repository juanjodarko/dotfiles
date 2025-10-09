#!/bin/bash

# Random Wallpaper Changer
# Selects and applies a random wallpaper from the wallpapers directory

set -euo pipefail  # Exit on error, undefined vars, pipe failures

WALLPAPER_DIR="$HOME/wallpapers"

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

# Find all wallpapers and pick one randomly
echo "Searching for wallpapers in $WALLPAPER_DIR..."
WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [[ -z "$WALLPAPER" ]]; then
    echo "Error: No readable wallpapers found in $WALLPAPER_DIR"
    echo "Please add image files (.jpg, .png, .jpeg) to the directory"
    exit 1
fi

# Validate selected wallpaper file
if [[ ! -r "$WALLPAPER" ]]; then
    echo "Error: Selected wallpaper is not readable: $WALLPAPER"
    exit 1
fi

echo "Changing wallpaper to: $(basename "$WALLPAPER")"

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

# Set wallpaper using hyprctl
if hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>/dev/null; then
    echo "Wallpaper changed successfully to: $(basename "$WALLPAPER")"
else
    echo "Error: Failed to change wallpaper"
    echo "This might happen if the wallpaper wasn't preloaded"
    echo "Try running generate_hyprpaper_config.sh first"
    exit 1
fi

