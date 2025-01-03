#!/bin/bash

# Path to hyprpaper config
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Start fresh
echo "# Auto-generated hyprpaper config" > "$CONFIG_FILE"

# Loop through wallpapers and preload them
find ~/wallpapers/ -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | while read -r wallpaper; do
    echo "preload = $wallpaper" >> "$CONFIG_FILE"
done

# Set a default wallpaper (the first one found)
DEFAULT_WALLPAPER=$(find ~/wallpapers/ -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [[ -n "$DEFAULT_WALLPAPER" ]]; then
    echo "wallpaper = ,$DEFAULT_WALLPAPER" >> "$CONFIG_FILE"
fi

# Restart hyprpaper to apply changes
killall hyprpaper
hyprpaper &

