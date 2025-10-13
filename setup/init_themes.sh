#!/usr/bin/env bash

# Initialize theme system with Mocha defaults
# This script creates the auto-generated symlinks and flavor file
# needed for the centralized theme system.

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
THEMES_DIR="$DOTFILES_DIR/themes"
THEMES_CONFIG_DIR="$THEMES_DIR/.config/themes"
HOME_CONFIG_THEMES="$HOME/.config/themes"
DEFAULT_THEME="mocha"

echo "Initializing theme system..."
echo ""

# Check current state
NEEDS_RESTRUCTURE=false
NEEDS_STOW=false
ALREADY_STOWED=false

# Check if already stowed (symlink exists and points to correct location)
if [ -L "$HOME_CONFIG_THEMES" ]; then
    target=$(readlink "$HOME_CONFIG_THEMES")
    if [[ "$target" == *"dotfiles/themes/.config/themes"* ]]; then
        ALREADY_STOWED=true
        echo "✓ Themes already stowed at $HOME_CONFIG_THEMES"
    fi
fi

# Check if needs restructuring (old structure exists)
if [ -d "$THEMES_DIR/catppuccin" ] && [ ! -d "$THEMES_CONFIG_DIR" ]; then
    NEEDS_RESTRUCTURE=true
    echo "→ Old structure detected, needs restructuring"
fi

# Check if already restructured but not stowed
if [ -d "$THEMES_CONFIG_DIR/catppuccin" ] && [ ! -L "$HOME_CONFIG_THEMES" ]; then
    NEEDS_STOW=true
    echo "→ Already restructured, needs stowing"
fi

# Perform restructuring if needed
if [ "$NEEDS_RESTRUCTURE" = true ]; then
    echo ""
    echo "Restructuring themes directory for stow compatibility..."

    # Remove any existing ~/.config/themes to avoid conflicts
    if [ -e "$HOME_CONFIG_THEMES" ] || [ -L "$HOME_CONFIG_THEMES" ]; then
        echo "→ Removing existing $HOME_CONFIG_THEMES"
        rm -rf "$HOME_CONFIG_THEMES"
    fi

    # Create proper stow structure
    mkdir -p "$THEMES_CONFIG_DIR"

    # Move everything to .config/themes/
    echo "→ Moving themes files to .config/themes/"
    if [ -d "$THEMES_DIR/catppuccin" ]; then
        mv "$THEMES_DIR/catppuccin" "$THEMES_CONFIG_DIR/"
    fi

    # Move any existing current.* files
    for file in current.conf current.css current.rasi current.ghostty current.tmux current.starship current_flavor.txt README.md; do
        if [ -e "$THEMES_DIR/$file" ] || [ -L "$THEMES_DIR/$file" ]; then
            mv "$THEMES_DIR/$file" "$THEMES_CONFIG_DIR/" 2>/dev/null || true
        fi
    done

    echo "✓ Themes directory restructured"
    NEEDS_STOW=true
fi

# Verify themes directory exists
if [ ! -d "$THEMES_CONFIG_DIR/catppuccin" ]; then
    echo ""
    echo "Error: Theme files not found at $THEMES_CONFIG_DIR/catppuccin"
    echo "Please ensure you've cloned the dotfiles repository correctly."
    exit 1
fi

# Navigate to themes config directory
cd "$THEMES_CONFIG_DIR"

# Create or update symlinks with relative paths for stow compatibility
if [ ! -L "current.css" ] || [ "$NEEDS_RESTRUCTURE" = true ]; then
    echo ""
    echo "Creating theme symlinks for $DEFAULT_THEME..."
    ln -sf "catppuccin/${DEFAULT_THEME}.css" current.css
    ln -sf "catppuccin/${DEFAULT_THEME}.rasi" current.rasi
    ln -sf "catppuccin/${DEFAULT_THEME}.ghostty" current.ghostty
    ln -sf "catppuccin/${DEFAULT_THEME}.tmux" current.tmux
    ln -sf "catppuccin/${DEFAULT_THEME}.starship" current.starship
    # Use relative path to hyprland config (3 levels up: .config/themes -> . -> dotfiles)
    ln -sf "../../../hyprland/.config/hypr/${DEFAULT_THEME}.conf" current.conf

    # Create flavor file
    echo "$DEFAULT_THEME" > current_flavor.txt
    echo "✓ Symlinks created"
fi

# Create symlink if needed (stow alternative)
if [ "$NEEDS_STOW" = true ] || [ ! -L "$HOME_CONFIG_THEMES" ]; then
    echo ""
    echo "Creating symlink ~/.config/themes..."
    ln -sf "$THEMES_CONFIG_DIR" "$HOME_CONFIG_THEMES"
    echo "✓ Symlink created: ~/.config/themes -> $THEMES_CONFIG_DIR"
fi

# Verify symlinks
echo ""
echo "Verification:"
ls -l "$THEMES_CONFIG_DIR"/current.{css,rasi,ghostty,tmux,starship,conf} 2>/dev/null || echo "Warning: Some symlinks may not have been created"

# Check flavor file
if [ -f "$THEMES_CONFIG_DIR/current_flavor.txt" ]; then
    echo "Flavor file: $(cat $THEMES_CONFIG_DIR/current_flavor.txt)"
fi

echo ""
echo "✓ Theme system initialized with Catppuccin $DEFAULT_THEME defaults"
echo ""

if [ -L "$HOME_CONFIG_THEMES" ]; then
    echo "Themes are configured and working!"
    echo ""
    echo "To switch themes:"
    echo "  - Interactive: Alt+Space → Settings → Theme"
    echo "  - Command line: Run the theme switcher script"
else
    echo "Warning: Theme symlink was not created properly"
    echo "Manually run: ln -sf ~/dotfiles/themes/.config/themes ~/.config/themes"
fi
echo ""
