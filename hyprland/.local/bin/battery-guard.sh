#!/usr/bin/env bash
# battery-guard.sh — simple charge notifications

battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
level=$(awk '/percentage/ {gsub("%",""); print $2}' <<< "$battery_info")
state=$(awk '/state/ {print $2}' <<< "$battery_info")

if [[ "$state" == "charging" && "$level" -ge 80 ]]; then
  notify-send "🔋 Battery full" "Unplug to preserve battery health"
elif [[ "$state" == "discharging" && "$level" -le 40 ]]; then
  notify-send "🔌 Plug in" "Battery below 40%"
fi
