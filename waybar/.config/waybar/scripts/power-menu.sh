#!/usr/bin/env bash

style="$HOME/.config/wofi/power-menu.css"

actions=$(echo -e "  Lock\n  Shutdown\n  Reboot\n$(printf '\u200A')  Suspend\n  Hibernate\n  Logout")

# Display logout menu
selected_option=$(echo -e "$actions" | wofi --dmenu --style "${style}" --width 180 --height 270 --location 3 --xoffset -10 --yoffset 32 --hide-scroll --no-actions)

# Perform actions based on the selected option
case "$selected_option" in
*Lock)
  hyprlock
  ;;
*Shutdown)
  systemctl poweroff
  ;;
*Reboot)
  systemctl reboot
  ;;
*Suspend)
  systemctl suspend
  ;;
*Hibernate)
  systemctl hibernate
  ;;
*Logout)
  hyprctl dispatch exit 0
  ;;
esac
