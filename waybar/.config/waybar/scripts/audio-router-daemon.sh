#!/usr/bin/env bash

#
# Audio Router Daemon - Auto-apply saved stream routes
# Monitors PipeWire for new audio streams and routes them based on saved preferences
#

CONFIG_DIR="$HOME/.config/audio-router"
ROUTES_FILE="$CONFIG_DIR/routes.conf"
LOG_FILE="$CONFIG_DIR/daemon.log"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_saved_route() {
    local app_name=$1

    if [ -f "$ROUTES_FILE" ]; then
        grep "^$app_name=" "$ROUTES_FILE" | cut -d'=' -f2
    fi
}

get_device_description() {
    local device_name=$1
    pactl list sinks | awk -v dev="$device_name" '
        /Name:/ { if ($2 == dev) found=1 }
        /Description:/ { if (found) { $1=""; print substr($0,2); exit } }
    '
}

get_stream_info() {
    local stream_id=$1

    pactl list sink-inputs | awk -v id="$stream_id" '
        /^Sink Input #/ {
            current_id = $3
            sub(/#/, "", current_id)
            if (current_id == id) found=1
        }
        /application.name = / {
            if (found) {
                gsub(/"/,"",$3)
                app=$3
                for(i=4;i<=NF;i++) app=app" "$i
            }
        }
        /Sink:/ {
            if (found) {
                print app "|" $2
                exit
            }
        }
    '
}

apply_saved_routes() {
    # Get all active streams
    local streams=$(pactl list sink-inputs short | awk '{print $1}')

    for stream_id in $streams; do
        local stream_info=$(get_stream_info "$stream_id")

        if [ -z "$stream_info" ]; then
            continue
        fi

        local app_name=$(echo "$stream_info" | cut -d'|' -f1)
        local current_sink=$(echo "$stream_info" | cut -d'|' -f2)

        # Check if there's a saved route for this app
        local saved_device=$(get_saved_route "$app_name")

        if [ -n "$saved_device" ] && [ "$saved_device" != "$current_sink" ]; then
            # Verify the saved device still exists
            if pactl list sinks short | grep -q "$saved_device"; then
                if pactl move-sink-input "$stream_id" "$saved_device" 2>/dev/null; then
                    local device_desc=$(get_device_description "$saved_device")
                    log_message "Auto-routed '$app_name' to $device_desc"
                    notify-send "🎵 Audio Router" "Auto-routed '$app_name'\nto $device_desc" --expire-time=2000
                else
                    log_message "Failed to route '$app_name' - stream may have ended"
                fi
            else
                log_message "Saved device for '$app_name' not found: $saved_device"
            fi
        fi
    done
}

# Initial application of saved routes
log_message "Audio Router Daemon started"
apply_saved_routes

# Monitor PipeWire events for new streams
pactl subscribe | grep --line-buffered "sink-input" | while read -r event; do
    # Wait a moment for stream to fully initialize
    sleep 0.5

    # Only process new streams
    if echo "$event" | grep -q "new"; then
        apply_saved_routes
    fi
done
