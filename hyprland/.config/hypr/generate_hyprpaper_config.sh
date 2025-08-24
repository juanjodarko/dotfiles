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

# Create array of wallpapers first
mapfile -t wallpapers < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) 2>/dev/null)

# Process each wallpaper
for wallpaper in "${wallpapers[@]}"; do
    # Validate file is readable and not empty
    if [[ -r "$wallpaper" && -s "$wallpaper" ]]; then
        echo "preload = $wallpaper" >> "$CONFIG_FILE"
        WALLPAPER_COUNT=$((WALLPAPER_COUNT + 1))
        echo "Preloaded: $(basename "$wallpaper")"
    else
        echo "Warning: Cannot read file $wallpaper, skipping..."
    fi
done

if [[ $WALLPAPER_COUNT -eq 0 ]]; then
    echo "Warning: No wallpapers found in $WALLPAPER_DIR"
else
    echo "Found and preloaded $WALLPAPER_COUNT wallpapers"
fi

# Set wallpaper for all monitors (random selection)
DEFAULT_WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [[ -n "$DEFAULT_WALLPAPER" ]]; then
    # Set wallpaper for all monitors
    echo "wallpaper = ,$DEFAULT_WALLPAPER" >> "$CONFIG_FILE"
    echo "wallpaper = eDP-1,$DEFAULT_WALLPAPER" >> "$CONFIG_FILE"  
    echo "wallpaper = DP-1,$DEFAULT_WALLPAPER" >> "$CONFIG_FILE"
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
    killall hyprpaper 2>/dev/null || true
    sleep 1
fi

# Validate config file before starting hyprpaper
if [[ ! -s "$CONFIG_FILE" ]]; then
    echo "Error: Generated config file is empty"
    exit 1
fi

# Start hyprpaper in background
echo "Starting hyprpaper..."
nohup hyprpaper > /dev/null 2>&1 &
echo "Hyprpaper started successfully"
echo "Wallpaper configuration complete!"

