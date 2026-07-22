#!/bin/bash
#
# Restore dotfiles from backup
#
# Usage:
#   ./restore.sh <backup_dir>
#   ./restore.sh  # Uses last backup

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_ROOT="$HOME/.dotfiles_backups"

ask_yn() {
    local prompt="$1"
    while true; do
        read -p "$(echo -e ${BLUE}${prompt}${NC} [y/N]: )" yn
        yn=${yn:-n}
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

list_backups() {
    echo -e "${BLUE}Available backups:${NC}"
    if [ -d "$BACKUP_ROOT" ]; then
        ls -1t "$BACKUP_ROOT"
    else
        echo "No backups found"
        exit 1
    fi
}

restore_backup() {
    local backup_dir="$1"

    if [ ! -d "$backup_dir" ]; then
        echo -e "${RED}✗${NC} Backup directory not found: $backup_dir"
        exit 1
    fi

    echo -e "${YELLOW}Restoring from: $backup_dir${NC}"
    echo ""
    echo -e "${BLUE}This will:${NC}"
    echo "  1. Remove stowed symlinks"
    echo "  2. Restore backed-up configs"
    echo "  3. Your dotfiles repo will remain unchanged"
    echo ""

    if ! ask_yn "Continue with restore?"; then
        echo "Cancelled"
        exit 0
    fi

    # Find all backed up configs
    cd "$backup_dir"
    find . -type f -o -type d | while read -r item; do
        item="${item#./}"
        [ -z "$item" ] && continue

        local source="$backup_dir/$item"
        local dest="$HOME/$item"

        # Remove symlink if exists
        if [ -L "$dest" ]; then
            echo -e "${BLUE}→${NC} Removing symlink: $dest"
            rm "$dest"
        fi

        # Restore backup
        if [ -f "$source" ]; then
            mkdir -p "$(dirname "$dest")"
            echo -e "${BLUE}→${NC} Restoring: $item"
            cp "$source" "$dest"
        fi
    done

    echo -e "${GREEN}✓${NC} Restore complete"
    echo ""
    echo -e "${YELLOW}To re-deploy dotfiles:${NC}"
    echo "  cd ~/dotfiles"
    echo "  stow nvim zsh git ..."
}

main() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: $0 [backup_dir]"
        echo ""
        echo "Restore dotfiles from backup"
        echo ""
        echo "Options:"
        echo "  <backup_dir>  Path to backup directory"
        echo "  --list        List available backups"
        echo "  --help        Show this help"
        exit 0
    fi

    if [ "$1" = "--list" ]; then
        list_backups
        exit 0
    fi

    local backup_dir="$1"

    # Use last backup if not specified
    if [ -z "$backup_dir" ]; then
        if [ -f "$HOME/.dotfiles_last_backup" ]; then
            backup_dir=$(cat "$HOME/.dotfiles_last_backup")
            echo -e "${BLUE}Using last backup: $backup_dir${NC}"
        else
            echo -e "${YELLOW}No backup specified${NC}"
            echo ""
            list_backups
            echo ""
            read -p "Enter backup name: " backup_name
            backup_dir="$BACKUP_ROOT/$backup_name"
        fi
    fi

    restore_backup "$backup_dir"
}

main "$@"
