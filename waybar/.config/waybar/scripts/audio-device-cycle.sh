#!/usr/bin/env bash

#
# Audio Device Cycle - Switch between connected audio devices
# Cycles through USB, Bluetooth, and built-in audio devices
#

get_device_icon() {
    local device_desc=$1

    case "$device_desc" in
        *bluez*|*bluetooth*|*Bluetooth*|*Solarbank*) echo "󰂯" ;;  # Bluetooth
        *usb*|*USB*|*Razer*|*Nari*) echo "🎮" ;;                   # USB/Gaming
        *Built-in*|*analog*|*HDA*|*PCH*) echo "🔊" ;;              # Built-in
        *) echo "🎧" ;;                                             # Generic
    esac
}

# Get current default sink
CURRENT_DEFAULT=$(wpctl status | sed -n '/├─ Sinks:/,/├─ Sources:/p' | grep "\*" | head -1 | awk '{print $3}' | tr -d '.')

if [ -z "$CURRENT_DEFAULT" ]; then
    notify-send "❌ Audio Device Cycle" "No default audio device found"
    exit 1
fi

# Get all available sinks (excluding redundant built-in Pro profiles)
# Extract only the audio sinks section, filter out extra Pro profiles, parse ID and description
SINKS=$(wpctl status | sed -n '/├─ Sinks:/,/├─ Sources:/p' | \
    grep -E "[0-9]+\." | grep -v "Sources:" | grep -v "Pro 3\|Pro 7\|Pro 8" | \
    sed 's/\[vol:.*\]//' | \
    awk '{
        for(i=1; i<=NF; i++) {
            if ($i ~ /^[0-9]+\.$/) {
                id = $i
                sub(/\.$/, "", id)
                # Get description - everything after the ID
                for(j=i+1; j<=NF; j++) {
                    if (desc == "") desc = $j
                    else desc = desc " " $j
                }
                print id "|" desc
                desc = ""
                break
            }
        }
    }')

# Build array of device IDs and descriptions
declare -a DEVICE_IDS
declare -a DEVICE_DESCS

while IFS='|' read -r id desc; do
    if [ -n "$id" ] && [ -n "$desc" ]; then
        DEVICE_IDS+=("$id")
        DEVICE_DESCS+=("$desc")
    fi
done <<< "$SINKS"

if [ ${#DEVICE_IDS[@]} -eq 0 ]; then
    notify-send "❌ Audio Device Cycle" "No audio devices found"
    exit 1
fi

# Find current device index
CURRENT_INDEX=-1
for i in "${!DEVICE_IDS[@]}"; do
    if [ "${DEVICE_IDS[$i]}" = "$CURRENT_DEFAULT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Get next device (cycle back to 0 if at end)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#DEVICE_IDS[@]} ))
NEXT_ID="${DEVICE_IDS[$NEXT_INDEX]}"
NEXT_DESC="${DEVICE_DESCS[$NEXT_INDEX]}"

# Switch to next device
if wpctl set-default "$NEXT_ID" 2>/dev/null; then
    ICON=$(get_device_icon "$NEXT_DESC")
    notify-send "🔊 Audio Device" "$ICON  $NEXT_DESC" --expire-time=2000
else
    notify-send "❌ Audio Device Cycle" "Failed to switch to $NEXT_DESC"
    exit 1
fi
