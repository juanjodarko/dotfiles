#!/usr/bin/env bash

# Initialize theme system with Mocha defaults
# This script creates the auto-generated symlinks and flavor file
# needed for the centralized theme system.

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
THEMES_DIR="$DOTFILES_DIR/themes"
HYPR_DIR="$DOTFILES_DIR/hyprland/.config/hypr"
DEFAULT_THEME="mocha"

echo "Initializing theme system..."

# Check if themes directory exists
if [ ! -d "$THEMES_DIR/catppuccin" ]; then
    echo "Error: Theme files not found at $THEMES_DIR/catppuccin"
    echo "Please ensure you've cloned the dotfiles repository correctly."
    exit 1
fi

# Navigate to themes directory
cd "$THEMES_DIR"

# Create symlinks
echo "Creating symlinks for $DEFAULT_THEME theme..."
ln -sf "catppuccin/${DEFAULT_THEME}.css" current.css
ln -sf "catppuccin/${DEFAULT_THEME}.rasi" current.rasi
ln -sf "catppuccin/${DEFAULT_THEME}.ghostty" current.ghostty
ln -sf "catppuccin/${DEFAULT_THEME}.tmux" current.tmux
ln -sf "catppuccin/${DEFAULT_THEME}.starship" current.starship
ln -sf "${HYPR_DIR}/${DEFAULT_THEME}.conf" current.conf

# Create flavor file
echo "Creating flavor file..."
echo "$DEFAULT_THEME" > current_flavor.txt

# Verify symlinks
echo ""
echo "Verification:"
ls -l current.css current.rasi current.ghostty current.tmux current.starship current.conf 2>/dev/null || echo "Warning: Some symlinks may not have been created"

# Check flavor file
if [ -f current_flavor.txt ]; then
    echo "Flavor file: $(cat current_flavor.txt)"
fi

echo ""
echo "✓ Theme system initialized with Catppuccin $DEFAULT_THEME defaults"
echo ""
echo "To switch themes:"
echo "  - Interactive: Alt+Space → Settings → Theme"
echo "  - Command line: Run the theme switcher script"
echo ""
