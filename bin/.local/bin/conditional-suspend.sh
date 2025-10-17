#!/bin/bash
# Conditional Suspend Script
# Only suspends the system when running on battery power
# When plugged into AC power, skip suspend to allow continuous operation

# Configuration
AC_POWER_FILE="/sys/class/power_supply/AC0/online"
LOG_FILE="${XDG_RUNTIME_DIR:-/tmp}/conditional-suspend.log"

# Allow forcing suspend even on AC power via environment variable
FORCE_SUSPEND="${FORCE_SUSPEND_ON_AC:-0}"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if AC power status file exists
if [ ! -f "$AC_POWER_FILE" ]; then
    log_message "ERROR: AC power status file not found at $AC_POWER_FILE"
    log_message "Suspending anyway as fallback behavior"
    systemctl suspend
    exit $?
fi

# Read AC power status
# 1 = AC power connected (plugged in)
# 0 = On battery power
AC_STATUS=$(cat "$AC_POWER_FILE" 2>/dev/null)

# Check if we're forcing suspend
if [ "$FORCE_SUSPEND" = "1" ]; then
    log_message "FORCE_SUSPEND_ON_AC=1, suspending regardless of power state"
    systemctl suspend
    exit $?
fi

# Conditional suspend logic
if [ "$AC_STATUS" = "0" ]; then
    # On battery - suspend to save power
    log_message "On battery power - suspending system"
    systemctl suspend
    exit $?
else
    # On AC power - skip suspend
    log_message "On AC power - skipping suspend"

    # Optional: Send notification to user
    if command -v notify-send &> /dev/null; then
        notify-send "Suspend Skipped" \
            "System not suspended because AC power is connected" \
            -u low \
            -i battery-ac-adapter
    fi

    exit 0
fi
