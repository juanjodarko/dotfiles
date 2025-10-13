#!/usr/bin/env bash

#
# Wofi Fingerprint Manager
# GUI for managing fingerprint authentication
#

# Check if fprintd is installed (check for fprintd-list which is the main command)
if ! command -v fprintd-list &> /dev/null; then
    notify-send "Fingerprint Manager" "fprintd not installed" -i dialog-error -u critical
    exit 1
fi

# Check if device exists
if ! lsusb | grep -qiE '(finger|print|biometric|validity|synaptics|elan|goodix|chipsailing)'; then
    notify-send "Fingerprint Manager" "No fingerprint device detected" -i dialog-error -u normal
    exit 1
fi

# Main menu options
options="📋 List Enrolled Fingerprints
➕ Enroll New Fingerprint
🗑️  Delete Fingerprint
✅ Test Fingerprint
ℹ️  Device Status"

# Show menu
selected=$(echo "$options" | wofi --dmenu --normal-window \
    --prompt "🔐 Fingerprint Manager" \
    --width 400 --height 300 --location 0)

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Handle selection
case "$selected" in
    "📋 List Enrolled Fingerprints")
        # Get enrolled fingerprints
        enrolled=$(fprintd-list "$USER" 2>&1)

        if echo "$enrolled" in | grep -q "No enrolled prints"; then
            notify-send "Fingerprint Manager" "No fingerprints enrolled" -i dialog-information
        else
            # Extract finger names
            fingers=$(echo "$enrolled" | grep "finger:" | sed 's/.*finger: //' | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

            if [ -z "$fingers" ]; then
                notify-send "Fingerprint Manager" "No fingerprints enrolled" -i dialog-information
            else
                count=$(echo "$fingers" | wc -l)
                notify-send "Enrolled Fingerprints ($count)" "$fingers" -i dialog-information
            fi
        fi
        ;;

    "➕ Enroll New Fingerprint")
        # Finger selection submenu
        finger_options="👆 Right Index Finger
👈 Left Index Finger
👍 Right Thumb
👍 Left Thumb
✋ Right Middle Finger
✋ Left Middle Finger
✋ Right Ring Finger
✋ Left Ring Finger
✋ Right Little Finger
✋ Left Little Finger"

        finger_selected=$(echo "$finger_options" | wofi --dmenu --normal-window \
            --prompt "Select Finger to Enroll" \
            --width 350 --height 400 --location 0)

        [ -z "$finger_selected" ] && exit 0

        # Map selection to fprintd finger name
        case "$finger_selected" in
            *"Right Index"*) FINGER="right-index-finger" ;;
            *"Left Index"*) FINGER="left-index-finger" ;;
            *"Right Thumb"*) FINGER="right-thumb" ;;
            *"Left Thumb"*) FINGER="left-thumb" ;;
            *"Right Middle"*) FINGER="right-middle-finger" ;;
            *"Left Middle"*) FINGER="left-middle-finger" ;;
            *"Right Ring"*) FINGER="right-ring-finger" ;;
            *"Left Ring"*) FINGER="left-ring-finger" ;;
            *"Right Little"*) FINGER="right-little-finger" ;;
            *"Left Little"*) FINGER="left-little-finger" ;;
            *) exit 1 ;;
        esac

        # Launch terminal for enrollment (needs interactive input)
        notify-send "Fingerprint Enrollment" "Starting enrollment for $FINGER\nPlease scan your finger in the terminal" -i dialog-information

        # Launch in ghostty if available, otherwise try common terminals
        if command -v ghostty &> /dev/null; then
            ghostty --title="Fingerprint Enrollment" -- bash -c "
                echo '🔐 Fingerprint Enrollment'
                echo ''
                echo 'Enrolling: $FINGER'
                echo 'Please scan your finger multiple times when prompted.'
                echo ''
                fprintd-enroll -f '$FINGER' '$USER'
                result=\$?
                echo ''
                if [ \$result -eq 0 ]; then
                    echo '✓ Enrollment successful!'
                    notify-send 'Fingerprint Manager' 'Fingerprint enrolled successfully!' -i dialog-information
                else
                    echo '✗ Enrollment failed'
                    notify-send 'Fingerprint Manager' 'Enrollment failed' -i dialog-error
                fi
                echo ''
                echo 'Press Enter to close...'
                read
            "
        elif command -v kitty &> /dev/null; then
            kitty --title="Fingerprint Enrollment" -- bash -c "
                fprintd-enroll -f '$FINGER' '$USER' && \
                notify-send 'Fingerprint Manager' 'Fingerprint enrolled successfully!' -i dialog-information || \
                notify-send 'Fingerprint Manager' 'Enrollment failed' -i dialog-error
                read -p 'Press Enter to close...'
            "
        elif command -v alacritty &> /dev/null; then
            alacritty --title="Fingerprint Enrollment" -e bash -c "
                fprintd-enroll -f '$FINGER' '$USER' && \
                notify-send 'Fingerprint Manager' 'Fingerprint enrolled successfully!' -i dialog-information || \
                notify-send 'Fingerprint Manager' 'Enrollment failed' -i dialog-error
                read -p 'Press Enter to close...'
            "
        else
            notify-send "Fingerprint Manager" "No supported terminal found (ghostty, kitty, alacritty)" -i dialog-error
        fi
        ;;

    "🗑️  Delete Fingerprint")
        # Get list of enrolled fingerprints
        enrolled=$(fprintd-list "$USER" 2>&1 | grep "finger:" | sed 's/.*finger: //')

        if [ -z "$enrolled" ]; then
            notify-send "Fingerprint Manager" "No fingerprints enrolled" -i dialog-information
            exit 0
        fi

        # Format for display
        finger_list=$(echo "$enrolled" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

        # Show selection menu
        finger_to_delete=$(echo "$finger_list" | wofi --dmenu --normal-window \
            --prompt "Select Fingerprint to Delete" \
            --width 350 --height 300 --location 0)

        [ -z "$finger_to_delete" ] && exit 0

        # Convert back to fprintd format
        finger_name=$(echo "$finger_to_delete" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

        # Confirm deletion
        confirm=$(echo -e "Yes\nNo" | wofi --dmenu --normal-window \
            --prompt "Delete $finger_to_delete?" \
            --width 300 --height 150 --location 0)

        if [ "$confirm" = "Yes" ]; then
            if fprintd-delete "$USER" -f "$finger_name" 2>/dev/null; then
                notify-send "Fingerprint Manager" "Deleted: $finger_to_delete" -i user-trash
            else
                notify-send "Fingerprint Manager" "Failed to delete fingerprint" -i dialog-error
            fi
        fi
        ;;

    "✅ Test Fingerprint")
        notify-send "Fingerprint Test" "Please scan your finger" -i dialog-information

        # Run verification in background and notify result
        (
            if fprintd-verify "$USER" &>/dev/null; then
                notify-send "Fingerprint Test" "✓ Verification successful!" -i dialog-information
            else
                notify-send "Fingerprint Test" "✗ Verification failed" -i dialog-error
            fi
        ) &
        ;;

    "ℹ️  Device Status")
        # Gather status information
        device=$(lsusb | grep -iE '(finger|print|biometric|validity|synaptics|elan|goodix|chipsailing)' | sed 's/Bus.*: //')
        service_status=$(systemctl is-active fprintd.service 2>/dev/null || echo "inactive")
        pam_status=$(grep -q "pam_fprintd.so" /etc/pam.d/system-auth && echo "Enabled" || echo "Disabled")
        enrolled_count=$(fprintd-list "$USER" 2>/dev/null | grep -c "finger:" || echo "0")

        status_text="Device: ${device:-Not detected}
Service: $service_status
PAM Auth: $pam_status
Enrolled: $enrolled_count fingerprint(s)"

        notify-send "Fingerprint Status" "$status_text" -i dialog-information -t 10000
        ;;
esac

exit 0
