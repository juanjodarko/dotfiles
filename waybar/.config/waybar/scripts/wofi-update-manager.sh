#!/usr/bin/env bash

# Wofi-based Package Update Manager for Waybar

TERMINAL="ghostty"
UPDATE_SCRIPT="$HOME/.config/waybar/scripts/system-update.sh"
WOFI_STYLE="$HOME/.config/wofi/update-manager.css"

# Get AUR helper
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    AUR_HELPER=""
fi

# Get update counts
if command -v checkupdates &>/dev/null; then
    official_updates=$(checkupdates 2>/dev/null | wc -l || echo "0")
else
    official_updates=0
fi

if [ -n "$AUR_HELPER" ]; then
    aur_updates=$($AUR_HELPER -Qua 2>/dev/null | wc -l || echo "0")
else
    aur_updates=0
fi

if command -v flatpak &>/dev/null; then
    flatpak_updates=$(flatpak remote-ls --updates 2>/dev/null | wc -l || echo "0")
else
    flatpak_updates=0
fi

total_updates=$((official_updates + aur_updates + flatpak_updates))

# Build menu options
if [ "$total_updates" -gt 0 ]; then
    options="🔄 Update All ($total_updates total)"

    [ "$official_updates" -gt 0 ] && options="$options"$'\n'"📦 Update Official Packages Only ($official_updates)"
    [ "$aur_updates" -gt 0 ] && [ -n "$AUR_HELPER" ] && options="$options"$'\n'"🔧 Update AUR Packages Only ($aur_updates)"
    [ "$flatpak_updates" -gt 0 ] && options="$options"$'\n'"📱 Update Flatpak Only ($flatpak_updates)"

    options="$options"$'\n'"📋 View Available Updates"
else
    options="✓ System is up to date"
fi

options="$options"$'\n'"❌ Cancel"

# Show wofi menu
selected=$(echo "$options" | wofi --dmenu --normal-window \
    --style "${WOFI_STYLE}" \
    --prompt "󰞒 System Updates (Official: $official_updates | AUR: $aur_updates | Flatpak: $flatpak_updates)" \
    --width 570 --height 400 --location 0)

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Handle selection
case "$selected" in
    "🔄 Update All"*)
        if [ -n "$AUR_HELPER" ]; then
            $TERMINAL --title "󰞒  System Update - All Packages" bash -c "
                $UPDATE_SCRIPT upgrade
                sudo $AUR_HELPER -Syu && flatpak update -y
                echo ''
                read -n 1 -p 'Press any key to close...'
            "
        else
            $TERMINAL --title "󰞒  System Update - All Packages" bash -c "
                $UPDATE_SCRIPT upgrade
                sudo pacman -Syu && flatpak update -y
                echo ''
                read -n 1 -p 'Press any key to close...'
            "
        fi
        pkill -RTMIN+20 waybar
        ;;
    "📦 Update Official Packages Only"*)
        $TERMINAL --title "󰞒  System Update - Official Packages" bash -c "
            $UPDATE_SCRIPT upgrade
            sudo pacman -Syu
            echo ''
            read -n 1 -p 'Press any key to close...'
        "
        pkill -RTMIN+20 waybar
        ;;
    "🔧 Update AUR Packages Only"*)
        $TERMINAL --title "󰞒  System Update - AUR Packages" bash -c "
            $UPDATE_SCRIPT upgrade
            sudo $AUR_HELPER -Sua
            echo ''
            read -n 1 -p 'Press any key to close...'
        "
        pkill -RTMIN+20 waybar
        ;;
    "📱 Update Flatpak Only"*)
        $TERMINAL --title "󰞒  System Update - Flatpak" bash -c "
            $UPDATE_SCRIPT upgrade
            flatpak update -y
            echo ''
            read -n 1 -p 'Press any key to close...'
        "
        pkill -RTMIN+20 waybar
        ;;
    "📋 View Available Updates")
        # Build detailed list
        details=""

        if [ "$official_updates" -gt 0 ]; then
            details="<b>Official Packages ($official_updates):</b>"$'\n'
            while IFS= read -r line; do
                details="$details  • $line"$'\n'
            done < <(checkupdates 2>/dev/null | awk '{print $1 " " $2 " → " $4}')
            details="$details"$'\n'
        fi

        if [ "$aur_updates" -gt 0 ] && [ -n "$AUR_HELPER" ]; then
            details="$details<b>AUR Packages ($aur_updates):</b>"$'\n'
            while IFS= read -r line; do
                details="$details  • $line"$'\n'
            done < <($AUR_HELPER -Qua 2>/dev/null | awk '{print $1 " " $2 " → " $4}')
            details="$details"$'\n'
        fi

        if [ "$flatpak_updates" -gt 0 ]; then
            details="$details<b>Flatpak Packages ($flatpak_updates):</b>"$'\n'
            while IFS= read -r line; do
                details="$details  • $line"$'\n'
            done < <(flatpak remote-ls --updates 2>/dev/null | awk '{print $2}')
        fi

        if [ "$total_updates" -eq 0 ]; then
            details="<b>System is up to date!</b>"$'\n\n'"No updates available."
        fi

        echo "$details" | wofi --dmenu --normal-window \
            --style "${WOFI_STYLE}" \
            --prompt "📋 Available Updates (Total: $total_updates)" \
            --width 570 --height 600 --location 0
        ;;
    *)
        exit 0
        ;;
esac
