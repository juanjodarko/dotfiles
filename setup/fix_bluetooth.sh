#!/usr/bin/env bash

#
# fix_bluetooth.sh - Fix Bluetooth configuration for better headphone support
# Enables experimental features, better codecs, and auto-reconnect
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "🔵 Fixing Bluetooth Configuration..."
echo ""

# Backup existing configuration
print_step "Creating backup of current configuration..."
sudo cp /etc/bluetooth/main.conf /etc/bluetooth/main.conf.backup.$(date +%Y%m%d-%H%M%S)
print_success "Backup created"

echo ""
print_step "Writing optimized Bluetooth configuration..."

# Write new configuration
sudo tee /etc/bluetooth/main.conf > /dev/null <<'EOF'
[General]
# Enable experimental features for better codec support (LDAC, aptX, AAC, etc.)
Experimental = true

# Enable fast connectable mode for quicker connections
FastConnectable = true

# Keep devices cached for better reconnection
TemporaryTimeout = 30

[Policy]
# Auto-reconnect audio devices after link loss
ReconnectAttempts = 7
ReconnectIntervals = 1,2,4,8,16,32,64

# Reconnect audio devices after suspend/resume
ResumeDelay = 2

# Auto-reconnect these service UUIDs on link loss (Audio Source, Headset, A/V Remote)
ReconnectUUIDs = 00001112-0000-1000-8000-00805f9b34fb,0000111f-0000-1000-8000-00805f9b34fb,0000110a-0000-1000-8000-00805f9b34fb,0000110b-0000-1000-8000-00805f9b34fb

[GATT]
# Always cache attributes for better interoperability
Cache = always

[AVDTP]
# Use basic mode for better compatibility with Bluetooth speakers
# ERTM can cause "Permission denied" errors with many devices
SessionMode = basic
EOF

print_success "Configuration written"

echo ""
print_step "Restarting Bluetooth service..."
sudo systemctl restart bluetooth.service

sleep 2

if systemctl is-active --quiet bluetooth.service; then
    print_success "Bluetooth service restarted successfully"
else
    print_error "Bluetooth service failed to restart"
    exit 1
fi

echo ""
print_step "Deploying udev rule to disable USB autosuspend..."

# Find the dotfiles directory (assuming script is in setup/ subdirectory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
UDEV_RULE_SOURCE="$DOTFILES_DIR/udev/etc/udev/rules.d/50-bluetooth-usb-disable-autosuspend.rules"

if [ -f "$UDEV_RULE_SOURCE" ]; then
    sudo cp "$UDEV_RULE_SOURCE" /etc/udev/rules.d/
    print_success "Udev rule deployed"

    print_step "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger --action=add --subsystem-match=usb
    print_success "Udev rules reloaded"
else
    print_error "Udev rule not found at: $UDEV_RULE_SOURCE"
    echo "         Skipping udev rule deployment"
fi

echo ""
print_step "Deploying and enabling systemd service..."

SYSTEMD_SERVICE_SOURCE="$DOTFILES_DIR/systemd/.config/systemd/system/bluetooth-disable-usb-autosuspend.service"

if [ -f "$SYSTEMD_SERVICE_SOURCE" ]; then
    # Copy to system directory
    sudo cp "$SYSTEMD_SERVICE_SOURCE" /etc/systemd/system/

    # Reload systemd daemon
    sudo systemctl daemon-reload

    # Enable and start the service
    sudo systemctl enable bluetooth-disable-usb-autosuspend.service
    sudo systemctl start bluetooth-disable-usb-autosuspend.service

    if systemctl is-active --quiet bluetooth-disable-usb-autosuspend.service; then
        print_success "Systemd service enabled and started"
    else
        print_error "Systemd service failed to start"
        echo "         Check with: sudo systemctl status bluetooth-disable-usb-autosuspend.service"
    fi
else
    print_error "Systemd service not found at: $SYSTEMD_SERVICE_SOURCE"
    echo "         Skipping systemd service deployment"
fi

echo ""
print_step "Verifying USB autosuspend is disabled for Bluetooth..."

# Check if any Bluetooth USB devices have autosuspend disabled
BT_USB_FOUND=false
for device in /sys/bus/usb/devices/*/; do
    if [ -f "$device/power/control" ]; then
        if [ -f "$device/driver" ] && readlink "$device/driver" 2>/dev/null | grep -q btusb; then
            BT_USB_FOUND=true
            CONTROL_VALUE=$(cat "$device/power/control" 2>/dev/null || echo "unknown")
            DEVICE_NAME=$(basename "$device")
            if [ "$CONTROL_VALUE" = "on" ]; then
                print_success "Bluetooth USB device $DEVICE_NAME: autosuspend disabled (control=$CONTROL_VALUE)"
            else
                print_error "Bluetooth USB device $DEVICE_NAME: autosuspend still enabled (control=$CONTROL_VALUE)"
            fi
        fi
    fi
done

if [ "$BT_USB_FOUND" = false ]; then
    echo "         No Bluetooth USB devices found (this is normal for some systems)"
    echo "         The udev rules will apply when Bluetooth devices are detected"
fi

echo ""
echo "✅ Bluetooth configuration fixed!"
echo ""
echo "Changes made:"
echo "  • Enabled experimental features (better codecs: LDAC, aptX, AAC)"
echo "  • Enabled FastConnectable (faster connections)"
echo "  • Enabled auto-reconnect on link loss"
echo "  • Using basic AVDTP mode (better compatibility, fixes Permission denied errors)"
echo "  • Configured resume delay for suspend/wake"
echo "  • Disabled USB autosuspend for Bluetooth controllers (prevents random disconnects)"
echo "  • Deployed udev rules and systemd service for power management"
echo ""
echo "Next steps:"
echo "  1. Put your headphones in pairing mode"
echo "  2. Connect via: bluetoothctl connect <MAC_ADDRESS>"
echo "  3. Or use your Bluetooth GUI"
echo ""
echo "The headphones should now connect more reliably without random disconnections!"
echo ""
