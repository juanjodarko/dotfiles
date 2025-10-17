#!/usr/bin/env bash

#
# Audio Router - Interactive stream routing for PipeWire/PulseAudio
# Route individual application audio streams to different output devices
#

# Wofi config
style="$HOME/.config/wofi/audio-router.css"

# Config directory for saved routes (Phase 2)
CONFIG_DIR="$HOME/.config/audio-router"
ROUTES_FILE="$CONFIG_DIR/routes.conf"

get_device_icon() {
    local device_name=$1

    case "$device_name" in
        *bluez*|*bluetooth*|*Bluetooth*) echo "󰂯" ;;  # Bluetooth
        *usb*|*USB*) echo "󰌌" ;;                      # USB
        *Razer*|*Nari*) echo "🎮" ;;                   # Gaming headset
        *hdmi*|*HDMI*|*DisplayPort*) echo "󰍹" ;;      # Monitor/TV
        *Built-in*|*analog*|*HDA*) echo "🔊" ;;        # Built-in
        *) echo "🎧" ;;                                 # Generic audio
    esac
}

get_stream_icon() {
    local app_name=$1
    local media_name=$2

    # Check app name first (more reliable than media name)
    case "$app_name" in
        # Social/Communication apps
        *[Dd]iscord*|*vesktop*|*Vencord*) echo "" ;;   # Discord
        *[Tt]elegram*) echo "" ;;                      # Telegram
        *[Ww]hats[Aa]pp*) echo "󰖣" ;;                   # WhatsApp
        *[Ss]lack*) echo "󰒱" ;;                         # Slack

        # Music apps
        *TIDAL*|*[Tt]idal*) echo "󰎆" ;;                # Tidal (matches "TIDAL Hi-Fi", "tidal-hifi", etc)
        *[Ss]potify*) echo "" ;;                       # Spotify

        # Video conferencing
        *[Zz]oom*) echo "󰍫" ;;                         # Zoom
        *[Tt]eams*) echo "󰊻" ;;                         # Teams

        # Browsers
        Firefox*) echo "󰈹" ;;                          # Firefox
        Chromium*|Chrome*) echo "" ;;                 # Chrome

        # Media players
        *mpv*|*vlc*|*VLC*) echo "󰕧" ;;                # Video player
    esac

    # Check media name for content-based detection
    case "$media_name" in
        *YouTube*|*youtube*) echo "󰗃" ;;               # YouTube
        *Spotify*|*spotify*) echo "" ;;               # Spotify
        *TIDAL*|*Tidal*|*tidal*) echo "󰎆" ;;          # Tidal
        *Discord*|*discord*) echo "" ;;               # Discord
        *WhatsApp*|*whatsapp*) echo "󰖣" ;;            # WhatsApp
        *Telegram*|*telegram*) echo "" ;;             # Telegram
        *Music*|*music*) echo "󰝚" ;;                   # Generic music
        *Meeting*|*meet*|*Zoom*|*zoom*) echo "󰍫" ;;   # Video call
        *) echo "🎵" ;;                                # Generic fallback
    esac
}

list_active_streams() {
    # Get all active audio streams with app name and media title
    pactl list sink-inputs | awk '
        /^Sink Input #/ {
            # Print previous entry if we have one
            if (id && app) {
                if (media && media != app) {
                    print id "|" app "|" media
                } else {
                    print id "|" app "|"
                }
            }
            # Start new entry
            id = $3
            sub(/#/, "", id)
            app = ""
            media = ""
        }
        /application.name = / {
            gsub(/"/,"",$3)
            app=$3
            for(i=4;i<=NF;i++) app=app" "$i
        }
        /media.name = / {
            gsub(/"/,"",$3)
            media=$3
            for(i=4;i<=NF;i++) media=media" "$i
        }
        END {
            # Print last entry
            if (id && app) {
                if (media && media != app) {
                    print id "|" app "|" media
                } else {
                    print id "|" app "|"
                }
            }
        }
    '
}

list_output_devices() {
    # Get all available output devices (sinks)
    pactl list sinks short | awk '{print $2 "|" $1}'
}

get_device_description() {
    local device_name=$1
    pactl list sinks | awk -v dev="$device_name" '
        /Name:/ { if ($2 == dev) found=1 }
        /Description:/ { if (found) { $1=""; print substr($0,2); exit } }
    '
}

get_stream_sink() {
    local stream_id=$1
    pactl list sink-inputs | awk -v id="$stream_id" '
        /^Sink Input #/ { if ($3 == "#"id) found=1 }
        /Sink:/ { if (found) { print $2; exit } }
    '
}

# Persistence functions
load_saved_routes() {
    # Load saved routes from config file
    if [ -f "$ROUTES_FILE" ]; then
        cat "$ROUTES_FILE"
    fi
}

save_route() {
    local app_name=$1
    local device_name=$2

    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Remove any existing route for this app
    if [ -f "$ROUTES_FILE" ]; then
        sed -i "/^$app_name=/d" "$ROUTES_FILE"
    fi

    # Save new route
    echo "$app_name=$device_name" >> "$ROUTES_FILE"
}

get_saved_route() {
    local app_name=$1

    if [ -f "$ROUTES_FILE" ]; then
        grep "^$app_name=" "$ROUTES_FILE" | cut -d'=' -f2
    fi
}

delete_route() {
    local app_name=$1

    if [ -f "$ROUTES_FILE" ]; then
        sed -i "/^$app_name=/d" "$ROUTES_FILE"
    fi
}

list_saved_routes() {
    if [ -f "$ROUTES_FILE" ]; then
        while IFS='=' read -r app device; do
            device_desc=$(get_device_description "$device")
            if [ -n "$device_desc" ]; then
                icon=$(get_device_icon "$device_desc")
                echo "  $app  $icon $device_desc"
            fi
        done < "$ROUTES_FILE"
    fi
}

while true; do
    # Get active streams
    streams_raw=$(list_active_streams)

    if [ -z "$streams_raw" ]; then
        # No active audio streams
        notify-send "🔇 Audio Router" "No active audio streams found.\nPlay some audio and try again."
        exit 0
    fi

    # Format streams for wofi display
    stream_options=""
    declare -A stream_map

    while IFS='|' read -r id app media; do
        icon=$(get_stream_icon "$app" "$media")

        # Get current device for this stream
        current_sink=$(get_stream_sink "$id")
        current_device=$(get_device_description "$current_sink")
        device_icon=$(get_device_icon "$current_device")

        if [ -n "$media" ]; then
            display="$icon  $app - $media  $device_icon $current_device"
        else
            display="$icon  $app  $device_icon $current_device"
        fi

        stream_options+="$display\n"
        stream_map["$display"]="$id"
    done <<< "$streams_raw"

    # Add control options
    stream_options+="󰆼  Manage Saved Routes\n"
    stream_options+="󰜺  Refresh\n"
    stream_options+="󰩈  Exit"

    # Show stream selection menu
    selected_stream=$(echo -e "$stream_options" | wofi --dmenu --normal-window \
        --style "${style}" \
        --prompt "🎵  Select Audio Stream" \
        --width 800 --height 500 --location 0)

    # Exit if nothing selected
    if [ -z "$selected_stream" ]; then
        exit 0
    fi

    # Handle control options
    case "$selected_stream" in
        *"Manage Saved Routes"*)
            # Show saved routes management
            saved_routes=$(list_saved_routes)

            if [ -z "$saved_routes" ]; then
                notify-send "🎵 Audio Router" "No saved routes configured yet.\n\nRoute a stream and choose 'Save Route' to create one."
                continue
            fi

            manage_options="$saved_routes\n󰜺  Back"

            selected_route=$(echo -e "$manage_options" | wofi --dmenu --normal-window \
                --style "${style}" \
                --prompt "🗑️  Select Route to Delete" \
                --width 600 --height 400 --location 0)

            if [ -n "$selected_route" ] && [[ "$selected_route" != *"Back"* ]]; then
                # Extract app name
                route_app=$(echo "$selected_route" | sed -E 's/^[^[:space:]]*[[:space:]]+([^[:space:]]+).*/\1/')

                if [ -n "$route_app" ]; then
                    delete_route "$route_app"
                    notify-send "🗑️ Audio Router" "Deleted saved route for '$route_app'"
                fi
            fi
            continue
            ;;
        *"Refresh"*)
            continue
            ;;
        *"Exit"*)
            exit 0
            ;;
    esac

    # Get stream ID
    stream_id="${stream_map[$selected_stream]}"

    if [ -z "$stream_id" ]; then
        notify-send "❌ Audio Router" "Failed to identify stream"
        continue
    fi

    # Get available output devices
    devices_raw=$(list_output_devices)
    device_options=""
    declare -A device_map

    while IFS='|' read -r device_name device_id; do
        description=$(get_device_description "$device_name")
        icon=$(get_device_icon "$description")

        display="$icon  $description"
        device_options+="$display\n"
        device_map["$display"]="$device_name"
    done <<< "$devices_raw"

    # Add cancel option
    device_options+="󰜺  Back"

    # Show device selection menu
    selected_device=$(echo -e "$device_options" | wofi --dmenu --normal-window \
        --style "${style}" \
        --prompt "🔊  Route To Device" \
        --width 600 --height 400 --location 0)

    # Exit if nothing selected or back
    if [ -z "$selected_device" ] || [[ "$selected_device" == *"Back"* ]]; then
        continue
    fi

    # Get device name
    device_name="${device_map[$selected_device]}"

    if [ -z "$device_name" ]; then
        notify-send "❌ Audio Router" "Failed to identify device"
        continue
    fi

    # Move the stream to the selected device
    if pactl move-sink-input "$stream_id" "$device_name" 2>/dev/null; then
        # Extract app name for notification
        app_name=$(echo "$selected_stream" | sed -E 's/^[^ ]*  ([^-]+).*/\1/' | xargs)
        device_desc=$(echo "$selected_device" | sed 's/^[^ ]*  //')

        notify-send "✅ Audio Router" "Routed '$app_name' to\n$device_desc"

        # Ask if user wants to save this route
        save_options="💾  Save this route (auto-apply in future)\n󰜺  No, just this time"

        save_choice=$(echo -e "$save_options" | wofi --dmenu --normal-window \
            --style "${style}" \
            --prompt "💾  Save Route for '$app_name'?" \
            --width 500 --height 200 --location 0)

        if [[ "$save_choice" == *"Save this route"* ]]; then
            save_route "$app_name" "$device_name"
            notify-send "💾 Audio Router" "Saved route for '$app_name'\n\nWill auto-apply when daemon is running."
        fi
    else
        notify-send "❌ Audio Router" "Failed to route stream\nStream may have ended"
        sleep 1
    fi

    # Continue loop to allow multiple routings
done
