#!/bin/bash

# Hyprland Configuration Backup Script
# Creates timestamped backups of all Hyprland configuration files

HYPR_DIR="$HOME/.config/hypr"
BACKUP_DIR="$HOME/.config/hypr/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/hypr_backup_$TIMESTAMP"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if hypr directory exists
if [[ ! -d "$HYPR_DIR" ]]; then
    print_status "$RED" "Error: Hyprland config directory not found at $HYPR_DIR"
    exit 1
fi

# Create backup directory if it doesn't exist
if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    print_status "$GREEN" "Created backup directory: $BACKUP_DIR"
fi

# Create timestamped backup directory
mkdir -p "$BACKUP_PATH"

# List of files to backup
CONFIG_FILES=(
    "hyprland.conf"
    "hyprpaper.conf"
    "hyprlock.conf"
    "hypridle.conf"
    "mocha.conf"
    "generate_hyprpaper_config.sh"
    "change_wallpaper.sh"
    "CLAUDE.md"
)

print_status "$YELLOW" "Creating backup at: $BACKUP_PATH"

# Backup each configuration file
BACKED_UP=0
for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$HYPR_DIR/$file" ]]; then
        cp "$HYPR_DIR/$file" "$BACKUP_PATH/"
        print_status "$GREEN" "✓ Backed up: $file"
        ((BACKED_UP++))
    else
        print_status "$YELLOW" "⚠ Skipped (not found): $file"
    fi
done

# Create backup info file
cat > "$BACKUP_PATH/backup_info.txt" << EOF
Hyprland Configuration Backup
=============================
Backup Date: $(date)
Backup Path: $BACKUP_PATH
Files Backed Up: $BACKED_UP
System: $(uname -a)
Hyprland Version: $(hyprctl version | head -n1 2>/dev/null || echo "Unable to determine")

Files in this backup:
$(ls -la "$BACKUP_PATH" | grep -v "^total")
EOF

print_status "$GREEN" "Backup completed successfully!"
print_status "$GREEN" "Location: $BACKUP_PATH"
print_status "$GREEN" "Files backed up: $BACKED_UP"

# Clean up old backups (keep last 10)
OLD_BACKUPS=$(find "$BACKUP_DIR" -maxdepth 1 -name "hypr_backup_*" -type d | sort -r | tail -n +11)
if [[ -n "$OLD_BACKUPS" ]]; then
    print_status "$YELLOW" "Cleaning up old backups..."
    echo "$OLD_BACKUPS" | while read -r old_backup; do
        rm -rf "$old_backup"
        print_status "$YELLOW" "Removed: $(basename "$old_backup")"
    done
fi

print_status "$GREEN" "Backup process complete!"