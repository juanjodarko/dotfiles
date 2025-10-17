#!/usr/bin/env bash

# Author: Jesse Mirabel (@sejjy)
# GitHub: https://github.com/sejjy/mechabar

# Wofi config
style="$HOME/.config/wofi/bluetooth-menu.css"

get_device_icon() {
  local device_mac=$1
  device_info=$(bluetoothctl info "$device_mac")
  device_icon=$(echo "$device_info" | grep "Icon:" | awk '{print $2}')

  case "$device_icon" in
  "audio-headphones" | "audio-headset") echo "󰋋 " ;; # Headphones
  "video-display" | "computer") echo "󰍹 " ;;         # Monitor
  "audio-input-microphone") echo "󰍬 " ;;             # Microphone
  "input-keyboard") echo "󰌌 " ;;                     # Keyboard
  "audio-speakers") echo "󰓃 " ;;                     # Speakers
  "input-mouse") echo "󰍽 " ;;                        # Mouse
  "phone") echo "󰏲 " ;;                              # Phone
  *)
    echo "󰂱 " # Default
    ;;
  esac
}

while true; do
  # Get list of paired devices with connection status
  bluetooth_devices=$(bluetoothctl devices | while read -r line; do
    device_mac=$(echo "$line" | awk '{print $2}')
    device_name=$(echo "$line" | awk '{$1=$2=""; print substr($0, 3)}')
    icon=$(get_device_icon "$device_mac")

    # Check connection status
    connection_status=$(bluetoothctl info "$device_mac" | grep "Connected:" | awk '{print $2}')
    if [[ "$connection_status" == "yes" ]]; then
      echo "$icon $device_name 󰂄"  # Add connected indicator
    else
      echo "$icon $device_name"
    fi
  done)

  options=$(
    echo "󰐇  Scan for devices"
    echo "󰂲  Disable Bluetooth"
    echo "$bluetooth_devices"
  )
  option="󰂯  Enable Bluetooth"

  # Get Bluetooth status
  bluetooth_status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

  if [[ "$bluetooth_status" == "yes" ]]; then
    selected_option=$(echo -e "$options" | wofi --dmenu --normal-window --style "${style}" --prompt "󰂯  Select Device" --width 570 --height 400 --location 0)
  else
    selected_option=$(echo -e "$option" | wofi --dmenu --normal-window --style "${style}" --prompt "󰂲  Bluetooth Disabled" --width 570 --height 140 --location 0)
  fi

  # Exit if no option is selected
  if [ -z "$selected_option" ]; then
    exit
  fi

  # Actions based on selected option
  case "$selected_option" in
  *"Enable Bluetooth"*)
    notify-send "󰂯 Bluetooth" "Enabling Bluetooth..."
    rfkill unblock bluetooth
    bluetoothctl power on
    sleep 1
    ;;
  *"Disable Bluetooth"*)
    notify-send "󰂲 Bluetooth" "Bluetooth Disabled"
    rfkill block bluetooth
    bluetoothctl power off
    sleep 1
    ;;
  *"Scan for devices"*)
    notify-send "󰐇 Bluetooth" "Opening Bluetooth Manager\nPress '?' to show help."
    ghostty --title='󰂱  Bluetooth TUI' -e bluetui # Launch bluetui
    ;;
  *)
    # Extract device name (remove icon and connection indicator)
    device_name="${selected_option#* }"
    device_name="${device_name% 󰂄}"  # Remove connected indicator if present
    device_name="${device_name## }"

    if [[ -n "$device_name" ]]; then
      # Get MAC address
      device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')

      # Check if already connected
      connection_status=$(bluetoothctl info "$device_mac" | grep "Connected:" | awk '{print $2}')

      if [[ "$connection_status" == "yes" ]]; then
        # Disconnect if already connected
        notify-send "󰂲 Bluetooth" "Disconnecting from \"$device_name\"..."
        bluetoothctl disconnect "$device_mac"
        sleep 1
      else
        # Trust and pair device
        bluetoothctl trust "$device_mac" >/dev/null 2>&1
        bluetoothctl pair "$device_mac" >/dev/null 2>&1

        # Connect to device
        notify-send "󰂯 Bluetooth" "Connecting to \"$device_name\"..."
        bluetoothctl connect "$device_mac" &
        sleep 3
        connection_status=$(bluetoothctl info "$device_mac" | grep "Connected:" | awk '{print $2}')

        if [[ "$connection_status" == "yes" ]]; then
          notify-send "󰂄 Bluetooth Connected" "Successfully connected to \"$device_name\"."
        else
          notify-send "󰂲 Bluetooth Failed" "Failed to connect to \"$device_name\"."
        fi
      fi
    fi
    ;;
  esac
done
