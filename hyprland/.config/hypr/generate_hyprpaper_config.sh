#!/bin/bash

# Hyprpaper Configuration Generator
# Scans wallpaper directory and creates hyprpaper.conf with all found images

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Path to hyprpaper config
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
WALLPAPER_DIR="$HOME/wallpapers"

# Validation: Check if wallpaper directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: Wallpaper directory $WALLPAPER_DIR does not exist"
    echo "Please create the directory or check the path"
    exit 1
fi

# Validation: Check if we can write to config file location
if [[ ! -w "$(dirname "$CONFIG_FILE")" ]]; then
    echo "Error: Cannot write to config directory $(dirname "$CONFIG_FILE")"
    exit 1
fi

# Start fresh
echo "# Auto-generated hyprpaper config" > "$CONFIG_FILE" || {
    echo "Error: Cannot write to config file $CONFIG_FILE"
    exit 1
}

# Loop through wallpapers and preload them
WALLPAPER_COUNT=0
echo "Scanning for wallpapers in $WALLPAPER_DIR..."

while IFS= read -r -d '' wallpaper; do
    # Validate file is readable
    if [[ -r "$wallpaper" ]]; then
        echo "preload = $wallpaper" >> "$CONFIG_FILE"
        ((WALLPAPER_COUNT++))
    else
        echo "Warning: Cannot read file $wallpaper, skipping..."
    fi
done < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -print0)

if [[ $WALLPAPER_COUNT -eq 0 ]]; then
    echo "Warning: No wallpapers found in $WALLPAPER_DIR"
else
    echo "Found and preloaded $WALLPAPER_COUNT wallpapers"
fi

# Set a default wallpaper (random selection)
DEFAULT_WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [[ -n "$DEFAULT_WALLPAPER" ]]; then
    echo "wallpaper = ,$DEFAULT_WALLPAPER" >> "$CONFIG_FILE"
    echo "Set default wallpaper: $(basename "$DEFAULT_WALLPAPER")"
else
    echo "Error: No wallpapers found to set as default"
    exit 1
fi

# Restart hyprpaper to apply changes
echo "Restarting hyprpaper..."

# Check if hyprpaper is running and kill it gracefully
if pgrep hyprpaper > /dev/null; then
    echo "Stopping existing hyprpaper process..."
    killall hyprpaper
    sleep 2
    
    # Force kill if still running
    if pgrep hyprpaper > /dev/null; then
        echo "Force killing hyprpaper..."
        killall -9 hyprpaper
        sleep 1
    fi
fi

# Validate config file before starting hyprpaper
if [[ ! -s "$CONFIG_FILE" ]]; then
    echo "Error: Generated config file is empty"
    exit 1
fi

# Start hyprpaper
echo "Starting hyprpaper..."
hyprpaper > /dev/null 2>&1 &
HYPRPAPER_PID=$!

# Give hyprpaper a moment to start
sleep 2

# Verify hyprpaper started successfully
if kill -0 $HYPRPAPER_PID 2>/dev/null; then
    echo "Hyprpaper started successfully (PID: $HYPRPAPER_PID)"
else
    echo "Error: Failed to start hyprpaper"
    echo "Check hyprpaper logs for details"
    exit 1
fi

