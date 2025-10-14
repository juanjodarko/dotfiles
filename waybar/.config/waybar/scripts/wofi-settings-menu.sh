#!/usr/bin/env bash

# Wofi-based Settings Menu
# Provides access to system theme and other configuration options

WOFI_STYLE="$HOME/.config/wofi/settings-menu.css"
THEME_SWITCHER="$HOME/.config/waybar/scripts/wofi-theme-switcher.sh"

# Build menu options
options="⚙️  Theme
🎨 Wallpaper (Coming Soon)
🔔 Notifications (Coming Soon)"

# Show wofi menu
selected=$(echo "$options" | wofi --dmenu --normal-window \
    --style "${WOFI_STYLE}" \
    --prompt "⚙️  Settings" \
    --width 400 --height 250 --location 0)

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Handle selection
case "$selected" in
    "⚙️  Theme")
        $THEME_SWITCHER
        ;;
    "🎨 Wallpaper (Coming Soon)")
        notify-send "Settings" "Wallpaper management coming soon!" -i preferences-desktop-wallpaper
        ;;
    "🔔 Notifications (Coming Soon)")
        notify-send "Settings" "Notification settings coming soon!" -i preferences-system-notifications
        ;;
    *)
        exit 0
        ;;
esac
