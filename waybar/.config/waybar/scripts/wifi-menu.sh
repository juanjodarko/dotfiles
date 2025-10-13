#!/usr/bin/env bash

# Author: Jesse Mirabel (@sejjy)
# GitHub: https://github.com/sejjy/mechabar

# Wofi config
style="$HOME/.config/wofi/wifi-menu.css"

options=$(
  echo "󰖩  Manual Entry"
  echo "󰖪  Disable Wi-Fi"
)
option_disabled="󰖩  Enable Wi-Fi"

# Prompt for password
get_password() {
  wofi --dmenu --password --normal-window --style "${style}" --prompt "🔐 Enter password" --width 570 --height 140 --location 0
}

while true; do
  wifi_list() {
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    nmcli --fields "SECURITY,SSID,CHAN,SIGNAL" device wifi list |
      tail -n +2 |               # Skip header line
      sed 's/  */ /g' |          # Multiple spaces to single space
      awk '{
        # Parse fields
        security = $1
        signal = $NF
        # SSID is everything between security and last two fields (chan and signal)
        ssid = ""
        for(i=2; i<NF-1; i++) {
          ssid = ssid (i==2?"":" ") $i
        }
        chan = $(NF-1)

        # Determine frequency band from channel
        freq = ""
        chan_num = chan + 0  # Convert to number
        if (chan_num >= 1 && chan_num <= 14) {
          freq = "2.4GHz"
        } else if (chan_num >= 36) {
          freq = "5GHz"
        }

        # Add security icon
        if (security ~ /WPA/) {
          icon = "󰤪"
        } else if (security == "--") {
          icon = "󰤨"
        } else {
          icon = "󰤪"
        }

        # Format output: icon SSID (freq) signal%
        printf "%s %s (%s) %s%%\n", icon, ssid, freq, signal
      }' |
      while read -r line; do
        # Extract SSID (between icon and frequency marker)
        ssid=$(echo "$line" | sed -E 's/^[^ ]+ ([^(]+) \(.*/\1/' | xargs)
        # Check if this is a saved/trusted network (only if ssid is not empty)
        if [[ -n "$ssid" ]] && echo "$saved_connections" | grep -qxF "$ssid"; then
          # Mark trusted networks with a star
          echo "$line ⭐"
        else
          echo "$line"
        fi
      done
  }

  # Get Wi-Fi status
  wifi_status=$(nmcli -fields WIFI g)

  case "$wifi_status" in
  *"enabled"*)
    selected_option=$(echo "$options"$'\n'"$(wifi_list)" |
      wofi --dmenu --normal-window --style "${style}" --prompt "󰤨  Select Network" --width 570 --height 500 --location 0)
    ;;
  *"disabled"*)
    selected_option=$(echo "$option_disabled" |
      wofi --dmenu --normal-window --style "${style}" --prompt "󰤭  Wi-Fi Disabled" --width 570 --height 140 --location 0)
    ;;
  esac

  # Extract selected SSID (remove icon, frequency, signal, and star)
  # Format: "󰤪 SSID (5GHz) 85% ⭐" -> "SSID"
  selected_ssid=$(echo "$selected_option" | sed -E 's/^[^ ]+ ([^(]+) \(.*/\1/' | xargs)
  selected_ssid="${selected_ssid% ⭐}"  # Remove star if present

  # Actions based on selected option
  case "$selected_option" in
  "")
    exit
    ;;
  *"Enable Wi-Fi"*)
    notify-send "󰤨 Scanning for networks..."
    nmcli radio wifi on
    nmcli device wifi rescan
    sleep 3
    ;;
  *"Disable Wi-Fi"*)
    notify-send "󰤭 Wi-Fi Disabled"
    nmcli radio wifi off
    sleep 1
    ;;
  *"Manual Entry"*)
    # Prompt for SSID
    manual_ssid=$(wofi --dmenu --normal-window --style "${style}" --prompt "󰖩  Enter SSID" --width 570 --height 140 --location 0)

    # Exit if no option is selected
    if [ -z "$manual_ssid" ]; then
      exit
    fi

    wifi_password=$(get_password)

    if [ -z "$wifi_password" ]; then
      nmcli device wifi connect "$manual_ssid"
    else
      nmcli dev wifi con "$manual_ssid" password "$wifi_password"
    fi

    nmcli device wifi connect "$manual_ssid" password "$wifi_password" | grep "successfully" && notify-send "󰤨 Wi-Fi Connected" "Successfully connected to \"$manual_ssid\"."
    ;;
  *)
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    if echo "$saved_connections" | grep -qw "$selected_ssid"; then
      nmcli connection up id "$selected_ssid" | grep "successfully" && notify-send "󰤨 Wi-Fi Connected" "Successfully connected to \"$selected_ssid\"."
    else
      # Handle secure network connection
      if [[ "$selected_option" =~ ^"󰤪" ]]; then
        wifi_password=$(get_password)
      fi

      nmcli device wifi connect "$selected_ssid" password "$wifi_password" | grep "successfully" && notify-send "󰤨 Wi-Fi Connected" "Successfully connected to \"$selected_ssid\"."
    fi
    ;;
  esac
done
