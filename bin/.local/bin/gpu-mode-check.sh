#!/bin/bash
# GPU Mode Detection Script for supergfxd
# Returns exit codes for systemd condition checking
#
# Exit codes:
#   0 = NVIDIA is active (Hybrid or NvidiaNoModeset mode)
#   1 = Integrated mode (NVIDIA disabled)
#   2 = Error/supergfxd not available

# Check if supergfxctl is available
if ! command -v supergfxctl &> /dev/null; then
    echo "Error: supergfxctl not found" >&2
    exit 2
fi

# Get current GPU mode
MODE=$(supergfxctl -g 2>/dev/null)

case "$MODE" in
    "Integrated")
        # NVIDIA is disabled
        exit 1
        ;;
    "Hybrid"|"NvidiaNoModeset")
        # NVIDIA is active
        exit 0
        ;;
    *)
        echo "Error: Unknown GPU mode: $MODE" >&2
        exit 2
        ;;
esac
