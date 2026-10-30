#!/usr/bin/env bash
# waybar custom/gpu on-click — offer the one relevant switch, hand off to gpu-mode-set.
# The menu selection IS the confirmation, so we call the backend with --no-confirm.
#
# STAGED SKETCH — intended home: ~/.config/waybar/scripts/gpu-mode-menu.sh
MODE="$(supergfxctl -g 2>/dev/null || echo Unknown)"
MENU=${GPU_MENU:-wofi --dmenu -p "GPU"}     # override: GPU_MENU="rofi -dmenu -p GPU" (or vicinae later)

case "$MODE" in
    Integrated)               opts="Enable NVIDIA (Hybrid) — reboots to apply";;
    Hybrid|NvidiaNoModeset)   opts="Disable NVIDIA (Integrated) — reboots to apply";;
    *)                        opts=$'Enable NVIDIA (Hybrid) — reboots to apply\nDisable NVIDIA (Integrated) — reboots to apply';;
esac

sel="$(printf '%b' "$opts" | $MENU 2>/dev/null || true)"
case "$sel" in
    Enable*)  gpu-mode-set Hybrid     --no-confirm;;
    Disable*) gpu-mode-set Integrated --no-confirm;;
    *)        exit 0;;
esac
