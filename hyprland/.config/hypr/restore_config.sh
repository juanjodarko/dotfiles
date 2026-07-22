#!/bin/bash

# Hyprland Configuration Restore Script
# Restores configuration from a backup

HYPR_DIR="$HOME/.config/hypr"
BACKUP_DIR="$HOME/.config/hypr/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if backup directory exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    print_status "$RED" "Error: No backup directory found at $BACKUP_DIR"
    exit 1
fi

# List available backups
BACKUPS=($(find "$BACKUP_DIR" -maxdepth 1 -name "hypr_backup_*" -type d | sort -r))

if [[ ${#BACKUPS[@]} -eq 0 ]]; then
    print_status "$RED" "Error: No backups found in $BACKUP_DIR"
    exit 1
fi

print_status "$BLUE" "Available backups:"
for i in "${!BACKUPS[@]}"; do
    backup_name=$(basename "${BACKUPS[$i]}")
    backup_date=$(echo "$backup_name" | sed 's/hypr_backup_//' | sed 's/_/ /' | sed 's/\([0-9]\{8\}\) \([0-9]\{6\}\)/\1 \2/')
    
    # Check if backup_info.txt exists
    if [[ -f "${BACKUPS[$i]}/backup_info.txt" ]]; then
        file_count=$(grep "Files Backed Up:" "${BACKUPS[$i]}/backup_info.txt" | cut -d: -f2 | tr -d ' ')
        print_status "$YELLOW" "$((i+1)). $backup_name ($file_count files)"
    else
        file_count=$(find "${BACKUPS[$i]}" -type f | wc -l)
        print_status "$YELLOW" "$((i+1)). $backup_name ($file_count files)"
    fi
done

echo ""
read -p "Select backup to restore (1-${#BACKUPS[@]}) or 'q' to quit: " choice

if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
    print_status "$YELLOW" "Restore cancelled"
    exit 0
fi

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 || "$choice" -gt ${#BACKUPS[@]} ]]; then
    print_status "$RED" "Error: Invalid selection"
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$((choice-1))]}"
print_status "$BLUE" "Selected backup: $(basename "$SELECTED_BACKUP")"

# Show backup info if available
if [[ -f "$SELECTED_BACKUP/backup_info.txt" ]]; then
    echo ""
    print_status "$BLUE" "Backup Information:"
    cat "$SELECTED_BACKUP/backup_info.txt"
    echo ""
fi

# Confirm restore
read -p "This will overwrite current configuration files. Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_status "$YELLOW" "Restore cancelled"
    exit 0
fi

# Create a backup of current config before restore
print_status "$YELLOW" "Creating backup of current configuration..."
CURRENT_BACKUP_DIR="$BACKUP_DIR/before_restore_$(date +"%Y%m%d_%H%M%S")"
mkdir -p "$CURRENT_BACKUP_DIR"

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

for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$HYPR_DIR/$file" ]]; then
        cp "$HYPR_DIR/$file" "$CURRENT_BACKUP_DIR/"
    fi
done

print_status "$GREEN" "Current config backed up to: $CURRENT_BACKUP_DIR"

# Restore files from selected backup
print_status "$YELLOW" "Restoring configuration files..."
RESTORED=0

for file in "$SELECTED_BACKUP"/*; do
    filename=$(basename "$file")
    
    # Skip backup info file and directories
    if [[ "$filename" == "backup_info.txt" || -d "$file" ]]; then
        continue
    fi
    
    # Copy file to hypr directory
    cp "$file" "$HYPR_DIR/"
    print_status "$GREEN" "✓ Restored: $filename"
    ((RESTORED++))
done

print_status "$GREEN" "Restore completed successfully!"
print_status "$GREEN" "Files restored: $RESTORED"
print_status "$YELLOW" "Note: You may need to restart Hyprland or reload the configuration"
print_status "$YELLOW" "Use 'hyprctl reload' to reload the configuration"