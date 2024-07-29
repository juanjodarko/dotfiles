#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config
for m in $(polybar --list-monitors | cut -d":" -f1); do
    case $m in
        DP-1|DP-1-1)
            MONITOR=$m polybar --reload sidebar &
            ;;
        *)
            MONITOR=$m polybar --reload juanjo &
            ;;
    esac
done

echo "Polybar launched..."
