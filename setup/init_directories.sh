#!/usr/bin/env bash

#
# init_directories.sh - Create required directories for dotfiles system
# Idempotent: Safe to run multiple times
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_skip() {
    echo -e "${YELLOW}⊙${NC} $1"
}

# Required directories
DIRECTORIES=(
    "$HOME/wallpapers"
    "$HOME/.cache/hyprpaper"
    "$HOME/.cache/hyprland"
    "$HOME/.cache/waybar"
    "$HOME/.cache/rofi"
    "$HOME/.local/bin"
    "$HOME/.local/share"
    "$HOME/.local/state"
)

echo "📁 Initializing required directories..."
echo ""

created=0
skipped=0

for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
        print_skip "Already exists: $dir"
        skipped=$((skipped + 1))
    else
        mkdir -p "$dir"
        print_success "Created: $dir"
        created=$((created + 1))
    fi
done

echo ""

WALLPAPER_DIR="$HOME/wallpapers"

# wallpaperd reads ~/.config/wallpaperd/wallpapers (per-machine link, gitignored)
if [ -d "$HOME/.config/wallpaperd" ] && [ ! -e "$HOME/.config/wallpaperd/wallpapers" ]; then
    ln -s "$WALLPAPER_DIR" "$HOME/.config/wallpaperd/wallpapers"
    print_success "Linked ~/.config/wallpaperd/wallpapers -> $WALLPAPER_DIR"
fi

# Wallpapers live on HomeNAS, not in git: pull them when the NAS is reachable
if [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    if command -v wallpapers-sync &> /dev/null && wallpapers-sync status &> /dev/null; then
        print_step "Pulling wallpapers from HomeNAS..."
        wallpapers-sync pull || print_skip "wallpapers-sync failed; run it later"
    else
        print_step "Wallpapers directory is empty"
        echo "   On the home network run: wallpapers-sync pull"
        echo "   (needs an SSH login to HomeNAS: Host homenas in ~/.ssh/config)"
        echo ""
    fi
fi

# Summary
if [ $created -gt 0 ]; then
    print_success "Created $created new directories"
fi

if [ $skipped -gt 0 ]; then
    print_skip "Skipped $skipped existing directories"
fi

if [ $created -eq 0 ] && [ $skipped -gt 0 ]; then
    echo ""
    echo -e "${GREEN}✓${NC} All required directories already exist"
fi

echo ""
echo "✅ Directory initialization complete"
