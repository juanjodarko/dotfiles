#!/bin/bash

# Monitor Change Handler for Hyprland
# Automatically detects monitor connect/disconnect events and updates wallpapers

set -euo pipefail

SCRIPT_DIR="$HOME/.config/hypr"
LOG_FILE="$HOME/.cache/hypr_monitor_handler.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Monitor change handler started"

# Validate required commands
if ! command -v hyprctl &> /dev/null; then
    log "Error: hyprctl command not found"
    exit 1
fi

if ! command -v socat &> /dev/null; then
    log "Error: socat command not found. Please install socat package."
    log "Install with: sudo pacman -S socat"
    exit 1
fi

# Get Hyprland instance signature for socket path
HYPR_INSTANCE_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance' 2>/dev/null || echo "$HYPRLAND_INSTANCE_SIGNATURE")

if [[ -z "$HYPR_INSTANCE_SIGNATURE" ]]; then
    log "Error: Could not determine Hyprland instance signature"
    exit 1
fi

SOCKET_PATH="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$HYPR_INSTANCE_SIGNATURE/.socket2.sock"

if [[ ! -S "$SOCKET_PATH" ]]; then
    log "Error: Hyprland event socket not found at $SOCKET_PATH"
    exit 1
fi

log "Listening for monitor events on $SOCKET_PATH"

# Function to regenerate wallpaper configuration
regenerate_wallpapers() {
    log "Monitor change detected, regenerating wallpaper configuration..."

    # Wait a moment for the system to stabilize
    sleep 1

    # Run the wallpaper generation script
    if [[ -x "$SCRIPT_DIR/generate_hyprpaper_config.sh" ]]; then
        if "$SCRIPT_DIR/generate_hyprpaper_config.sh" >> "$LOG_FILE" 2>&1; then
            log "Wallpaper configuration regenerated successfully"
        else
            log "Error: Failed to regenerate wallpaper configuration"
        fi
    else
        log "Error: generate_hyprpaper_config.sh not found or not executable"
    fi
}

# Function to regenerate waybar workspace configuration
regenerate_waybar() {
    log "Regenerating waybar workspace configuration..."

    # Run the waybar workspace generation script
    if [[ -x "$SCRIPT_DIR/generate_waybar_workspaces.sh" ]]; then
        if "$SCRIPT_DIR/generate_waybar_workspaces.sh" >> "$LOG_FILE" 2>&1; then
            log "Waybar configuration regenerated successfully"

            # Restart waybar to apply changes
            log "Restarting waybar..."
            if pkill -SIGUSR2 waybar 2>/dev/null; then
                log "Waybar reloaded successfully"
            else
                # If reload fails, try full restart
                log "Reload failed, attempting full restart..."
                pkill waybar 2>/dev/null || true
                sleep 0.5
                waybar >> "$LOG_FILE" 2>&1 &
                log "Waybar restarted"
            fi
        else
            log "Error: Failed to regenerate waybar configuration"
        fi
    else
        log "Error: generate_waybar_workspaces.sh not found or not executable"
    fi
}

# Function to reload Hyprland configuration
reload_hyprland() {
    log "Reloading Hyprland configuration to apply monitor changes..."

    if hyprctl reload >> "$LOG_FILE" 2>&1; then
        log "Hyprland configuration reloaded successfully"
    else
        log "Warning: Failed to reload Hyprland configuration"
    fi
}

# Listen to Hyprland events
# Events we're interested in: monitoradded, monitorremoved
socat -U UNIX-CONNECT:"$SOCKET_PATH" - | while read -r event; do
    # Parse event type (format: "EVENT>>DATA")
    event_type=$(echo "$event" | cut -d'>' -f1)

    case "$event_type" in
        monitoradded)
            monitor_name=$(echo "$event" | cut -d'>' -f3-)
            log "Monitor added: $monitor_name"
            reload_hyprland
            regenerate_wallpapers
            regenerate_waybar
            ;;
        monitorremoved)
            monitor_name=$(echo "$event" | cut -d'>' -f3-)
            log "Monitor removed: $monitor_name"
            reload_hyprland
            regenerate_wallpapers
            regenerate_waybar
            ;;
        *)
            # Ignore other events silently
            ;;
    esac
done

log "Monitor change handler stopped"
