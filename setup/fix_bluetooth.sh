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

# Auto-enable Bluetooth controllers on boot
AutoEnable = true

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
# Use Enhanced Retransmission Mode for better audio quality
SessionMode = ertm
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
echo "✅ Bluetooth configuration fixed!"
echo ""
echo "Changes made:"
echo "  • Enabled experimental features (better codecs: LDAC, aptX, AAC)"
echo "  • Enabled FastConnectable (faster connections)"
echo "  • Enabled auto-reconnect on link loss"
echo "  • Enabled ERTM mode (better audio quality)"
echo "  • Configured resume delay for suspend/wake"
echo ""
echo "Next steps:"
echo "  1. Put your headphones in pairing mode"
echo "  2. Connect via: bluetoothctl connect 6C:D3:EE:0A:F1:1E"
echo "  3. Or use your Bluetooth GUI"
echo ""
echo "The headphones should now connect more reliably!"
echo ""
