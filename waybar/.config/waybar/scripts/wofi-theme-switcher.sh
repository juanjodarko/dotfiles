#!/usr/bin/env bash
# Wofi theme switcher — a thin frontend over the headless `theme-set` backend
# (bin/.local/bin/theme-set), which owns the symlink swap + app reloads. Vicinae's
# "Switch Theme" command and any future DockShell control call the same backend,
# so the switch logic lives in exactly one place.

WOFI_STYLE="$HOME/.config/wofi/theme-switcher.css"

command -v theme-set >/dev/null 2>&1 || { notify-send "Theme" "theme-set not found on PATH"; exit 1; }
current=$(theme-set)

label() { case "$1" in mocha) echo "Mocha (Dark)";; latte) echo "Latte (Light)";; frappe) echo "Frappé (Dark)";; macchiato) echo "Macchiato (Dark)";; esac; }

options=""
for f in mocha latte frappe macchiato; do
  [ "$f" = "$current" ] && options+="● " || options+="○ "
  options+="$(label "$f")"$'\n'
done
options=${options%$'\n'}

selected=$(printf '%s' "$options" | wofi --dmenu --normal-window \
  --style "$WOFI_STYLE" \
  --prompt "🎨 Select Theme (Current: ${current^})" \
  --width 450 --height 280 --location 0)
[ -z "$selected" ] && exit 0

name=$(printf '%s' "$selected" | sed 's/^[●○] //' | awk '{print $1}')
case "$name" in
  Mocha)     flavor=mocha ;;
  Latte)     flavor=latte ;;
  Frappé)    flavor=frappe ;;
  Macchiato) flavor=macchiato ;;
  *) exit 1 ;;
esac

if [ "$flavor" = "$current" ]; then
  notify-send "Theme" "Already using ${flavor^}" -i preferences-desktop-theme
  exit 0
fi

exec theme-set "$flavor"
