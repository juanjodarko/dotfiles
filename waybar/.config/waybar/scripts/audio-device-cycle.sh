#!/usr/bin/env bash

#
# Audio Device Cycle - Switch between connected audio devices
# Cycles through USB, Bluetooth, built-in analog, and HDMI audio devices
# HDMI support: toggles PCH card profile between analog and hdmi-stereo
#

PCH_CARD="alsa_card.pci-0000_00_1f.3"
PROFILE_ANALOG="output:analog-stereo+input:analog-stereo"
PROFILE_HDMI="output:hdmi-stereo+input:analog-stereo"
HDMI_MARKER="__HDMI__"

get_device_icon() {
    local device_desc=$1

    case "$device_desc" in
        *HDMI*|*Float*|*hdmi*) echo "🖥️" ;;                           # HDMI monitor
        *bluez*|*bluetooth*|*Bluetooth*|*Solarbank*) echo "󰂯" ;;  # Bluetooth
        *usb*|*USB*|*Razer*|*Nari*) echo "🎮" ;;                   # USB/Gaming
        *Built-in*|*analog*|*HDA*|*PCH*) echo "🔊" ;;              # Built-in
        *) echo "🎧" ;;                                             # Generic
    esac
}

# Check if HDMI port is available (monitor connected) on the PCH card
hdmi_available() {
    pactl list cards 2>/dev/null | \
        awk -v card="$PCH_CARD" '
            /Name:/ { found = ($2 == card) }
            found && /hdmi-output-0/ && /available/ && !/not available/ { print "yes"; exit }
        '
}

# Get the current active profile on the PCH card
get_pch_profile() {
    pactl list cards 2>/dev/null | \
        awk -v card="$PCH_CARD" '
            /Name:/ { found = ($2 == card) }
            found && /Active Profile:/ { sub(/.*Active Profile: /, ""); print; exit }
        '
}

# Get current default sink
CURRENT_DEFAULT=$(wpctl status | sed -n '/├─ Sinks:/,/├─ Sources:/p' | grep "\*" | head -1 | awk '{print $3}' | tr -d '.')

if [ -z "$CURRENT_DEFAULT" ]; then
    notify-send "❌ Audio Device Cycle" "No default audio device found"
    exit 1
fi

# Get all available sinks (excluding redundant built-in Pro profiles)
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

# If HDMI is available and we're currently on analog profile, add HDMI as a virtual entry
CURRENT_PROFILE=$(get_pch_profile)
HDMI_IS_AVAILABLE=$(hdmi_available)

if [ "$HDMI_IS_AVAILABLE" = "yes" ]; then
    # Check if the current sinks already include an HDMI sink (profile is already HDMI)
    # If not, append a virtual HDMI entry after the existing sinks
    HAS_HDMI_SINK=false
    for desc in "${DEVICE_DESCS[@]}"; do
        case "$desc" in
            *HDMI*|*hdmi*) HAS_HDMI_SINK=true; break ;;
        esac
    done

    if [ "$HAS_HDMI_SINK" = "false" ]; then
        # Add virtual HDMI entry — the marker ID tells us to switch profile
        DEVICE_IDS+=("$HDMI_MARKER")
        DEVICE_DESCS+=("Float2 Pro HDMI")
    fi
fi

if [ ${#DEVICE_IDS[@]} -eq 0 ]; then
    notify-send "❌ Audio Device Cycle" "No audio devices found"
    exit 1
fi

# Check if we're currently on the HDMI profile (to detect "current = HDMI" for cycling)
CURRENT_ON_HDMI=false
if [[ "$CURRENT_PROFILE" == *hdmi-stereo* ]]; then
    CURRENT_ON_HDMI=true
fi

# Find current device index
CURRENT_INDEX=-1
if [ "$CURRENT_ON_HDMI" = "true" ]; then
    # If we're on HDMI profile, current position is the HDMI entry (real or virtual)
    for i in "${!DEVICE_IDS[@]}"; do
        if [ "${DEVICE_IDS[$i]}" = "$HDMI_MARKER" ]; then
            CURRENT_INDEX=$i
            break
        fi
        # Also match actual HDMI sinks by description
        case "${DEVICE_DESCS[$i]}" in
            *HDMI*|*hdmi*) CURRENT_INDEX=$i; break ;;
        esac
    done
fi

# If not found via HDMI match, find by sink ID
if [ "$CURRENT_INDEX" -eq -1 ]; then
    for i in "${!DEVICE_IDS[@]}"; do
        if [ "${DEVICE_IDS[$i]}" = "$CURRENT_DEFAULT" ]; then
            CURRENT_INDEX=$i
            break
        fi
    done
fi

# Get next device (cycle back to 0 if at end)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#DEVICE_IDS[@]} ))
NEXT_ID="${DEVICE_IDS[$NEXT_INDEX]}"
NEXT_DESC="${DEVICE_DESCS[$NEXT_INDEX]}"

# Handle the switch
if [ "$NEXT_ID" = "$HDMI_MARKER" ]; then
    # Switch PCH card to HDMI profile
    if pactl set-card-profile "$PCH_CARD" "$PROFILE_HDMI" 2>/dev/null; then
        # Wait briefly for the new sink to appear
        sleep 0.3
        # Find the new HDMI sink and set it as default
        HDMI_SINK=$(wpctl status | sed -n '/├─ Sinks:/,/├─ Sources:/p' | \
            grep -iE "HDMI|hdmi" | head -1 | \
            awk '{ for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.$/) { sub(/\.$/, "", $i); print $i; break } }')
        if [ -n "$HDMI_SINK" ]; then
            wpctl set-default "$HDMI_SINK" 2>/dev/null
        fi
        ICON=$(get_device_icon "$NEXT_DESC")
        notify-send "🔊 Audio Device" "$ICON  $NEXT_DESC" --expire-time=2000
    else
        notify-send "❌ Audio Device Cycle" "Failed to switch to HDMI profile"
        exit 1
    fi
else
    # If we were on HDMI and cycling to a non-HDMI PCH sink, switch profile back to analog
    if [ "$CURRENT_ON_HDMI" = "true" ]; then
        pactl set-card-profile "$PCH_CARD" "$PROFILE_ANALOG" 2>/dev/null
        sleep 0.3
        # Re-discover the analog sink ID since it may have changed after profile switch
        NEW_ANALOG_SINK=$(wpctl status | sed -n '/├─ Sinks:/,/├─ Sources:/p' | \
            grep -iE "Built-in|Razer Blade|analog|PCH" | grep -v "HDMI" | head -1 | \
            awk '{ for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.$/) { sub(/\.$/, "", $i); print $i; break } }')
        if [ -n "$NEW_ANALOG_SINK" ]; then
            NEXT_ID="$NEW_ANALOG_SINK"
        fi
    fi

    if wpctl set-default "$NEXT_ID" 2>/dev/null; then
        ICON=$(get_device_icon "$NEXT_DESC")
        notify-send "🔊 Audio Device" "$ICON  $NEXT_DESC" --expire-time=2000
    else
        notify-send "❌ Audio Device Cycle" "Failed to switch to $NEXT_DESC"
        exit 1
    fi
fi
