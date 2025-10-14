#!/bin/bash

# Waybar Workspace Configuration Generator
# Dynamically generates workspace configuration for waybar based on connected monitors

set -euo pipefail

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_CONFIG_BACKUP="$HOME/.config/waybar/config.jsonc.bak"
WORKSPACES_PER_MONITOR=10

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "Generating waybar workspace configuration..."

# Validate required commands
if ! command -v hyprctl &> /dev/null; then
    log "Error: hyprctl command not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    log "Error: jq command not found"
    exit 1
fi

# Check if waybar config exists
if [[ ! -f "$WAYBAR_CONFIG" ]]; then
    log "Error: Waybar config not found at $WAYBAR_CONFIG"
    exit 1
fi

# Detect connected monitors
mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name' | sort)

if [[ ${#monitors[@]} -eq 0 ]]; then
    log "Warning: No monitors detected"
    exit 0
fi

log "Found ${#monitors[@]} monitor(s): ${monitors[*]}"

# Create backup
cp "$WAYBAR_CONFIG" "$WAYBAR_CONFIG_BACKUP"

# For split-monitor-workspaces, the dynamic approach works best
# We just ensure the config has active-only: false and show-special: false
log "Using dynamic workspace display (shows only active workspaces per monitor)"

temp_config=$(mktemp)

# Use Python to update the waybar config with the simple dynamic settings
python3 << 'EOF'
import re
import sys

config_file = sys.argv[1]
temp_file = sys.argv[2]

# Read the config file
with open(config_file, 'r') as f:
    content = f.read()

# Find the hyprland/workspaces section and ensure it has the right settings
# Remove persistent-workspaces if it exists and add active-only
pattern = r'("hyprland/workspaces"\s*:\s*\{[^}]*\})'

def replace_workspace_config(match):
    workspace_section = match.group(1)

    # Remove persistent-workspaces line if present
    workspace_section = re.sub(r',?\s*"persistent-workspaces"\s*:\s*\{[^}]*\}', '', workspace_section)
    # Remove all-outputs line if present
    workspace_section = re.sub(r',?\s*"all-outputs"\s*:\s*[^,\n]*', '', workspace_section)
    # Remove active-only if present (we'll add it back)
    workspace_section = re.sub(r',?\s*"active-only"\s*:\s*[^,\n]*', '', workspace_section)
    # Remove show-special if present (we'll add it back)
    workspace_section = re.sub(r',?\s*"show-special"\s*:\s*[^,\n]*', '', workspace_section)

    # Add the dynamic settings before the closing brace
    workspace_section = workspace_section.rstrip()
    if workspace_section.endswith('}'):
        # Insert before the closing brace
        workspace_section = workspace_section[:-1].rstrip()
        if not workspace_section.endswith(','):
            workspace_section += ','
        workspace_section += '\n    "active-only": false,\n    "show-special": false\n  }'

    return workspace_section

new_content = re.sub(pattern, replace_workspace_config, content, flags=re.DOTALL)

# Write to temp file
with open(temp_file, 'w') as f:
    f.write(new_content)
EOF

python3 - "$WAYBAR_CONFIG" "$temp_config"

# Verify the file was created and has content
if [[ -s "$temp_config" ]]; then
    mv "$temp_config" "$WAYBAR_CONFIG"
    log "Waybar workspace configuration updated successfully (dynamic mode)"
else
    log "Error: Failed to generate config, restoring backup"
    mv "$WAYBAR_CONFIG_BACKUP" "$WAYBAR_CONFIG"
    rm -f "$temp_config"
    exit 1
fi

log "Waybar configuration complete"
