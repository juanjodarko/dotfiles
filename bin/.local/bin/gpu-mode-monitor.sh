#!/bin/bash
# GPU Mode Monitor - Watches for supergfxd mode changes via D-Bus
# and logs them for troubleshooting

LOG_FILE="${XDG_RUNTIME_DIR:-/tmp}/gpu-mode-monitor.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

get_gpu_mode() {
    supergfxctl -g 2>/dev/null || echo "Unknown"
}

log_message "GPU Mode Monitor started"
log_message "Initial GPU mode: $(get_gpu_mode)"

# Monitor D-Bus for NotifyGfx signals from supergfxd
dbus-monitor --system "type='signal',interface='org.supergfxctl.Daemon'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "NotifyGfx"; then
        NEW_MODE=$(get_gpu_mode)
        log_message "GPU mode changed to: $NEW_MODE"

        # Send notification to user
        if command -v notify-send &> /dev/null; then
            notify-send "GPU Mode Changed" "New mode: $NEW_MODE" -u low
        fi

        # Here you can add additional actions based on mode change
        # For example, restart certain services, adjust power settings, etc.
    fi
done
