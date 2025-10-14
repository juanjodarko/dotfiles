#!/bin/bash
#
# Cleanup old dotfiles backups
# Keeps the most recent 5 backups
#
# Usage:
#   ./cleanup.sh        # Keep last 5 backups
#   ./cleanup.sh 10     # Keep last 10 backups
#   ./cleanup.sh --all  # Remove all backups

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_ROOT="$HOME/.dotfiles_backups"
KEEP_COUNT="${1:-5}"

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

cleanup_all() {
    if [ ! -d "$BACKUP_ROOT" ]; then
        echo -e "${YELLOW}!${NC} No backups directory found"
        exit 0
    fi

    local count=$(ls -1 "$BACKUP_ROOT" | wc -l)

    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}!${NC} No backups to remove"
        exit 0
    fi

    echo -e "${YELLOW}Found $count backup(s)${NC}"

    if ! ask_yn "Remove ALL backups?"; then
        echo "Cancelled"
        exit 0
    fi

    rm -rf "$BACKUP_ROOT"
    echo -e "${GREEN}✓${NC} Removed all backups"
}

cleanup_old() {
    if [ ! -d "$BACKUP_ROOT" ]; then
        echo -e "${YELLOW}!${NC} No backups directory found"
        exit 0
    fi

    local total=$(ls -1t "$BACKUP_ROOT" | wc -l)

    if [ "$total" -le "$KEEP_COUNT" ]; then
        echo -e "${GREEN}✓${NC} Only $total backup(s), nothing to clean"
        exit 0
    fi

    local to_remove=$((total - KEEP_COUNT))

    echo -e "${BLUE}Found $total backup(s)${NC}"
    echo -e "${YELLOW}Keeping newest $KEEP_COUNT backup(s)${NC}"
    echo -e "${RED}Removing $to_remove old backup(s)${NC}"
    echo ""

    # List backups to be removed
    ls -1t "$BACKUP_ROOT" | tail -n "+$((KEEP_COUNT + 1))" | while read -r backup; do
        echo "  - $backup"
    done
    echo ""

    if ! ask_yn "Continue?"; then
        echo "Cancelled"
        exit 0
    fi

    # Remove old backups
    ls -1t "$BACKUP_ROOT" | tail -n "+$((KEEP_COUNT + 1))" | while read -r backup; do
        echo -e "${BLUE}→${NC} Removing: $backup"
        rm -rf "$BACKUP_ROOT/$backup"
    done

    echo -e "${GREEN}✓${NC} Cleanup complete"
}

main() {
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: $0 [count]"
        echo ""
        echo "Cleanup old dotfiles backups"
        echo ""
        echo "Options:"
        echo "  [count]       Number of backups to keep (default: 5)"
        echo "  --all         Remove all backups"
        echo "  --help        Show this help"
        exit 0
    fi

    if [ "$1" = "--all" ]; then
        cleanup_all
    else
        cleanup_old
    fi
}

main "$@"
