#!/bin/bash
#
# Backup existing dotfiles before stowing
#
# Usage:
#   ./backup.sh              # Backup all configs
#   ./backup.sh nvim         # Backup specific module
#   ./backup.sh --list       # List existing backups

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Backup directory
BACKUP_ROOT="$HOME/.dotfiles_backups"
BACKUP_DIR="$BACKUP_ROOT/backup_$(date +%Y%m%d_%H%M%S)"

# Configs to backup
CONFIGS=(
    ".config/nvim"
    ".config/hypr"
    ".config/waybar"
    ".config/rofi"
    ".config/swaync"
    ".config/tmux"
    ".config/starship.toml"
    ".config/toot"
    ".config/mise"
    ".zshrc"
    ".gitconfig"
    ".bashrc"
    ".vimrc"
)

list_backups() {
    echo -e "${BLUE}Existing backups:${NC}"
    if [ -d "$BACKUP_ROOT" ]; then
        ls -1t "$BACKUP_ROOT" | head -10
    else
        echo "No backups found"
    fi
}

backup_config() {
    local config="$1"
    local source="$HOME/$config"

    # Skip if doesn't exist or is symlink (already managed by stow)
    if [ ! -e "$source" ] || [ -L "$source" ]; then
        return 0
    fi

    local dest="$BACKUP_DIR/$config"
    mkdir -p "$(dirname "$dest")"

    echo -e "${BLUE}→${NC} Backing up: $config"
    cp -r "$source" "$dest"
}

main() {
    if [ "$1" = "--list" ]; then
        list_backups
        exit 0
    fi

    echo -e "${YELLOW}Creating backup in: $BACKUP_DIR${NC}"

    if [ -n "$1" ]; then
        # Backup specific module
        case "$1" in
            nvim)
                backup_config ".config/nvim"
                ;;
            hyprland)
                backup_config ".config/hypr"
                backup_config ".config/waybar"
                backup_config ".config/rofi"
                backup_config ".config/swaync"
                ;;
            zsh)
                backup_config ".zshrc"
                ;;
            git)
                backup_config ".gitconfig"
                ;;
            tmux)
                backup_config ".config/tmux"
                ;;
            *)
                echo -e "${YELLOW}Unknown module: $1${NC}"
                echo "Available: nvim, hyprland, zsh, git, tmux"
                exit 1
                ;;
        esac
    else
        # Backup all
        for config in "${CONFIGS[@]}"; do
            backup_config "$config"
        done
    fi

    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        echo "$BACKUP_DIR" > "$HOME/.dotfiles_last_backup"
        echo -e "${GREEN}✓${NC} Backup complete: $BACKUP_DIR"
    else
        rmdir "$BACKUP_DIR" 2>/dev/null || true
        echo -e "${YELLOW}!${NC} No configs to backup"
    fi
}

main "$@"
