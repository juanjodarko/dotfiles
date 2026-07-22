#!/usr/bin/env bash

# Author: Jesse Mirabel (@sejjy)
# GitHub: https://github.com/sejjy/mechabar

# Wofi config
style="$HOME/.config/wofi/wifi-menu.css"

options=$(
  echo "󰖩  Manual Entry"
  echo "󰒓  Manage Networks"
  echo "󰖪  Disable Wi-Fi"
)
option_disabled="󰖩  Enable Wi-Fi"

# Prompt for password
get_password() {
  wofi --dmenu --password --normal-window --style "${style}" --prompt "🔐 Enter password" --width 570 --height 140 --location 0
}

# Get priority for a connection
get_priority() {
  local ssid="$1"
  nmcli -t -f connection.autoconnect-priority connection show "$ssid" 2>/dev/null | cut -d: -f2
}

# Set priority for a connection
set_priority() {
  local ssid="$1"
  local priority="$2"
  nmcli connection modify "$ssid" connection.autoconnect-priority "$priority" 2>/dev/null
}

# Get priority icon
get_priority_icon() {
  local priority="$1"
  if [ "$priority" -ge 10 ]; then
    echo "󰓎"  # flame icon for high priority
  elif [ "$priority" -ge 5 ]; then
    echo "󰐃"  # pin icon for medium priority
  elif [ "$priority" -ge 2 ]; then
    echo "󰐄"  # pin-outline icon for low priority
  else
    echo ""  # no icon for default priority
  fi
}

# Prompt to set priority for newly connected network
prompt_new_network_priority() {
  local network_name="$1"

  # Ask if user wants to set priority
  priority_options=$(cat <<EOF
󰓎  High Priority (10)
󰐃  Medium Priority (5)
󰐄  Low Priority (2)
󰚑  Skip
EOF
)

  selected_priority=$(echo "$priority_options" | wofi --dmenu --normal-window --style "${style}" --prompt "Set priority for \"$network_name\"?" --width 570 --height 250 --location 0)

  if [ -z "$selected_priority" ] || [[ "$selected_priority" == *"Skip"* ]]; then
    return
  fi

  # Determine priority value
  case "$selected_priority" in
    *"High Priority"*)
      new_priority=10
      ;;
    *"Medium Priority"*)
      new_priority=5
      ;;
    *"Low Priority"*)
      new_priority=2
      ;;
    *)
      return
      ;;
  esac

  # Set the priority
  if set_priority "$network_name" "$new_priority"; then
    priority_icon=$(get_priority_icon "$new_priority")
    notify-send "󰒓 Priority Set" "\"$network_name\" priority set to $new_priority $priority_icon"
  fi
}

# Show priority management menu
show_priority_menu() {
  # Get all saved WiFi connections
  local wifi_connections=$(nmcli -t -f NAME,TYPE connection show | grep ":802-11-wireless$" | cut -d: -f1)

  if [ -z "$wifi_connections" ]; then
    notify-send "󰖪 No Saved Networks" "No WiFi networks found to manage."
    return
  fi

  # Build list with priorities using a separator
  local network_list=""
  declare -A network_map
  local index=0

  while IFS= read -r network; do
    priority=$(get_priority "$network")
    priority_icon=$(get_priority_icon "$priority")

    # Store mapping of display text to actual network name
    if [[ -n "$priority_icon" ]]; then
      display_text="[$priority] $priority_icon $network"
    else
      display_text="[$priority] $network"
    fi

    network_list+="$display_text"$'\n'
    network_map["$display_text"]="$network"
    ((index++))
  done <<< "$wifi_connections"

  # Show network selection menu
  selected_network=$(echo -e "$network_list" | wofi --dmenu --normal-window --style "${style}" --prompt "󰒓  Select Network to Modify" --width 570 --height 500 --location 0)

  if [ -z "$selected_network" ]; then
    return
  fi

  # Get actual network name from map
  network_name="${network_map[$selected_network]}"

  # Fallback: if map lookup failed, try to extract from display text
  if [ -z "$network_name" ]; then
    # Try to find matching network by checking if display text contains the network name
    while IFS= read -r network; do
      if [[ "$selected_network" == *"$network"* ]]; then
        network_name="$network"
        break
      fi
    done <<< "$wifi_connections"
  fi

  if [ -z "$network_name" ]; then
    notify-send "󰚑 Error" "Could not determine network name."
    return
  fi

  # Show priority options
  priority_options=$(cat <<EOF
󰓎  High Priority (10)
󰐃  Medium Priority (5)
󰐄  Low Priority (2)
󰚑  No Priority (0)
󰎠  Custom...
󰗨  Delete Network
EOF
)

  selected_priority=$(echo "$priority_options" | wofi --dmenu --normal-window --style "${style}" --prompt "󰒓  Manage \"$network_name\"" --width 570 --height 350 --location 0)

  if [ -z "$selected_priority" ]; then
    return
  fi

  # Determine action
  case "$selected_priority" in
    *"Delete Network"*)
      # Show confirmation dialog
      confirm_options=$(cat <<EOF
󰗨  Yes, Delete
󰜺  Cancel
EOF
)
      confirmation=$(echo "$confirm_options" | wofi --dmenu --normal-window --style "${style}" --prompt "󰗨  Delete \"$network_name\"? This cannot be undone." --width 570 --height 180 --location 0)

      if [[ "$confirmation" == *"Yes, Delete"* ]]; then
        # Delete the network
        if nmcli connection delete "$network_name" 2>/dev/null; then
          notify-send "󰗨 Network Deleted" "\"$network_name\" has been removed."
        else
          notify-send "󰚑 Error" "Failed to delete \"$network_name\"."
        fi
      fi
      ;;
    *"High Priority"*)
      new_priority=10
      ;;
    *"Medium Priority"*)
      new_priority=5
      ;;
    *"Low Priority"*)
      new_priority=2
      ;;
    *"No Priority"*)
      new_priority=0
      ;;
    *"Custom"*)
      new_priority=$(wofi --dmenu --normal-window --style "${style}" --prompt "󰎠  Enter Priority (0-100)" --width 570 --height 140 --location 0)
      # Validate input
      if ! [[ "$new_priority" =~ ^[0-9]+$ ]] || [ "$new_priority" -lt 0 ] || [ "$new_priority" -gt 100 ]; then
        notify-send "󰚑 Invalid Priority" "Priority must be a number between 0 and 100."
        return
      fi
      ;;
    *)
      return
      ;;
  esac

  # Set the priority (only if not deleting)
  if [[ "$selected_priority" != *"Delete Network"* ]] && [ -n "$new_priority" ]; then
    if set_priority "$network_name" "$new_priority"; then
      priority_icon=$(get_priority_icon "$new_priority")
      notify-send "󰒓 Priority Updated" "\"$network_name\" priority set to $new_priority $priority_icon"
    else
      notify-send "󰚑 Error" "Failed to update priority for \"$network_name\"."
    fi
  fi
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
          # Get priority and icon for saved networks
          priority=$(get_priority "$ssid")
          priority_icon=$(get_priority_icon "$priority")
          # Mark trusted networks with a star and priority icon
          if [[ -n "$priority_icon" ]]; then
            echo "$line ⭐ $priority_icon"
          else
            echo "$line ⭐"
          fi
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
  *"Manage Networks"*)
    show_priority_menu
    ;;
  *"Manual Entry"*)
    # Prompt for SSID
    manual_ssid=$(wofi --dmenu --normal-window --style "${style}" --prompt "󰖩  Enter SSID" --width 570 --height 140 --location 0)

    # Exit if no option is selected
    if [ -z "$manual_ssid" ]; then
      exit
    fi

    wifi_password=$(get_password)

    notify-send "󰤨 Connecting..." "Attempting to connect to \"$manual_ssid\""

    if [ -z "$wifi_password" ]; then
      connection_result=$(nmcli device wifi connect "$manual_ssid" 2>&1)
    else
      connection_result=$(nmcli device wifi connect "$manual_ssid" password "$wifi_password" 2>&1)
    fi

    if echo "$connection_result" | grep -q "successfully"; then
      notify-send "󰤨 Wi-Fi Connected" "Successfully connected to \"$manual_ssid\"."
      # Prompt to set priority for new network
      prompt_new_network_priority "$manual_ssid"
    else
      notify-send "󰤭 Connection Failed" "Could not connect to \"$manual_ssid\". Check SSID and password."
    fi
    ;;
  *)
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    if echo "$saved_connections" | grep -qw "$selected_ssid"; then
      notify-send "󰤨 Connecting..." "Attempting to connect to \"$selected_ssid\""
      if nmcli connection up id "$selected_ssid" 2>&1 | grep -q "successfully"; then
        notify-send "󰤨 Wi-Fi Connected" "Successfully connected to \"$selected_ssid\"."
      else
        notify-send "󰤭 Connection Failed" "Could not connect to \"$selected_ssid\"."
      fi
    else
      # Handle secure network connection
      if [[ "$selected_option" =~ ^"󰤪" ]]; then
        wifi_password=$(get_password)
      fi

      notify-send "󰤨 Connecting..." "Attempting to connect to \"$selected_ssid\""
      if nmcli device wifi connect "$selected_ssid" password "$wifi_password" 2>&1 | grep -q "successfully"; then
        notify-send "󰤨 Wi-Fi Connected" "Successfully connected to \"$selected_ssid\"."
        # Prompt to set priority for new network
        prompt_new_network_priority "$selected_ssid"
      else
        notify-send "󰤭 Connection Failed" "Could not connect to \"$selected_ssid\". Check password and try again."
      fi
    fi
    ;;
  esac
done
