#!/bin/bash

# Hyprpaper Configuration Generator
# Scans wallpaper directory and creates hyprpaper.conf with all found images

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Wait for Hyprland to be fully ready (important for startup)
sleep 2

# Path to hyprpaper config
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
WALLPAPER_DIR="$HOME/wallpapers"
WALLPAPER_CACHE="$HOME/.cache/current_wallpaper"

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

# Detect connected monitors dynamically using hyprctl
echo "Detecting connected monitors..."
if ! command -v hyprctl &> /dev/null; then
    echo "Error: hyprctl command not found"
    exit 1
fi

# Get list of connected monitors (extract monitor names from JSON)
mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')

if [[ ${#monitors[@]} -eq 0 ]]; then
    echo "Warning: No monitors detected"
    # Fallback to a single default wallpaper
    DEFAULT_WALLPAPER=$(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    if [[ -n "$DEFAULT_WALLPAPER" ]]; then
        echo "wallpaper = ,$DEFAULT_WALLPAPER" >> "$CONFIG_FILE"
        ln -sf "$DEFAULT_WALLPAPER" "$WALLPAPER_CACHE"
    fi
else
    echo "Found ${#monitors[@]} monitor(s): ${monitors[*]}"

    # Select different random wallpapers for each monitor
    # Get shuffled list of all wallpapers
    mapfile -t shuffled_wallpapers < <(find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf)

    if [[ ${#shuffled_wallpapers[@]} -eq 0 ]]; then
        echo "Error: No wallpapers found to set"
        exit 1
    fi

    # Assign a unique wallpaper to each monitor
    wallpaper_index=0
    PRIMARY_WALLPAPER=""

    for monitor in "${monitors[@]}"; do
        # Get wallpaper for this monitor (cycle through if we have more monitors than wallpapers)
        wallpaper="${shuffled_wallpapers[$((wallpaper_index % ${#shuffled_wallpapers[@]}))]}"

        echo "wallpaper = $monitor,$wallpaper" >> "$CONFIG_FILE"
        echo "Set $monitor: $(basename "$wallpaper")"

        # Save first wallpaper as primary for lock screen
        if [[ -z "$PRIMARY_WALLPAPER" ]]; then
            PRIMARY_WALLPAPER="$wallpaper"
        fi

        wallpaper_index=$((wallpaper_index + 1))
    done

    # Also set a default wallpaper for any future monitors
    echo "wallpaper = ,${shuffled_wallpapers[0]}" >> "$CONFIG_FILE"

    # Create symlink to primary wallpaper for hyprlock
    if [[ -n "$PRIMARY_WALLPAPER" ]]; then
        ln -sf "$PRIMARY_WALLPAPER" "$WALLPAPER_CACHE"
        echo "Updated wallpaper symlink for lock screen"
    fi
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

# Start hyprpaper in background with logging
echo "Starting hyprpaper..."
LOG_FILE="$HOME/.cache/hyprpaper.log"
hyprpaper >> "$LOG_FILE" 2>&1 &
echo "Hyprpaper started (logs: $LOG_FILE)"
echo "Wallpaper configuration complete!"

