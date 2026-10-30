#!/usr/bin/env bash
# waybar custom/gpu — emit JSON state for the GPU indicator.
# Reuses the existing read layer idea (bin/.local/bin/gpu-mode-check.sh); we read the
# mode name directly so capability detection never depends on live PCI enumeration
# (that's Omarchy's #5428 bug: the toggle vanishes in Integrated because the dGPU left the bus).
#
# Refresh is signal-driven (see README): gpu-mode-monitor.sh calls `pkill -RTMIN+8 waybar`
# on a supergfxd mode change, so the icon updates live without polling.
#
# STAGED SKETCH — intended home: ~/.config/waybar/scripts/gpu-mode-status.sh
MODE="$(supergfxctl -g 2>/dev/null || echo Unknown)"

# Glyphs are Nerd Font — swap to taste.
case "$MODE" in
    Integrated)      ICON="󰰄"; CLASS="integrated"; DESC="NVIDIA off · iGPU only (best battery)";;
    Hybrid)          ICON="󰾲"; CLASS="hybrid";      DESC="NVIDIA ON · Hybrid (higher battery use) — click to turn off";;
    NvidiaNoModeset) ICON="󰾲"; CLASS="nomodeset";   DESC="NVIDIA no-modeset";;
    *)               ICON="󰢮"; CLASS="unknown";     DESC="GPU mode unknown (supergfxd?)";;
esac

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$ICON" "$DESC" "$CLASS"
