#!/bin/bash

# List all wallpapers and pick one randomly
WALLPAPER=$(find ~/wallpapers/ -type f | shuf -n 1)

# set wallpaper
hyprctl hyprpaper wallpaper ",$WALLPAPER"

