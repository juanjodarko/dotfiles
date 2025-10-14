#!/usr/bin/env bash

#
# init_supergfx.sh - Configure supergfxctl for hybrid GPU systems
# Sets up GPU switching for Intel/AMD iGPU + NVIDIA dGPU laptops
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

print_skip() {
    echo -e "${YELLOW}⊙${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "🎮 Configuring hybrid GPU management..."
echo ""

# Check if supergfxctl is installed
if ! command -v supergfxctl &> /dev/null; then
    print_skip "supergfxctl not installed, skipping configuration"
    echo "This script is only needed for hybrid GPU systems"
    exit 0
fi

print_success "Found supergfxctl"

# Check if this is actually a hybrid system
DGPU_VENDOR=$(supergfxctl --vendor 2>/dev/null || echo "")
if [[ -z "$DGPU_VENDOR" ]] || [[ "$DGPU_VENDOR" == "None" ]]; then
    print_skip "No dedicated GPU detected"
    echo "supergfxctl is installed but no hybrid GPU configuration detected"
    exit 0
fi

print_success "Detected hybrid GPU system with $DGPU_VENDOR dGPU"
echo ""

# Check for conflicting packages
print_step "Checking for conflicting GPU managers..."

CONFLICTS=()
if pacman -Qi optimus-manager &> /dev/null; then
    CONFLICTS+=("optimus-manager")
fi

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    echo ""
    print_error "Found conflicting packages:"
    for pkg in "${CONFLICTS[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    echo -e "${YELLOW}These packages conflict with supergfxctl.${NC}"
    echo ""

    read -p "$(echo -e ${BLUE}Remove conflicting packages?${NC} [Y/n]: )" response
    response=${response:-y}

    if [[ "$response" =~ ^[Yy] ]]; then
        print_step "Removing conflicting packages..."
        if sudo pacman -Rns --noconfirm "${CONFLICTS[@]}"; then
            print_success "Conflicts removed"
        else
            print_error "Failed to remove conflicts"
            exit 1
        fi
    else
        print_error "Cannot continue with conflicting packages installed"
        exit 1
    fi
    echo ""
else
    print_success "No conflicting GPU managers found"
fi

echo ""

# Configuration file
CONFIG_FILE="/etc/supergfxd.conf"

# Check if config already exists
if [ -f "$CONFIG_FILE" ]; then
    print_step "Configuration file already exists: $CONFIG_FILE"

    # Read current mode
    CURRENT_MODE=$(supergfxctl --get 2>/dev/null || echo "Unknown")
    print_success "Current GPU mode: $CURRENT_MODE"

    # Show supported modes
    SUPPORTED=$(supergfxctl --supported 2>/dev/null || echo "[]")
    echo "Supported modes: $SUPPORTED"
    echo ""

    read -p "$(echo -e ${BLUE}Update configuration with recommended defaults?${NC} [y/N]: )" response

    if [[ ! "$response" =~ ^[Yy] ]]; then
        print_skip "Keeping existing configuration"

        # Still ensure service is enabled
        print_step "Ensuring supergfxd service is enabled..."
        if sudo systemctl enable supergfxd.service &> /dev/null; then
            if sudo systemctl is-active --quiet supergfxd.service; then
                print_success "Service is already running"
            else
                sudo systemctl start supergfxd.service
                print_success "Service started"
            fi
        fi

        exit 0
    fi
fi

# Create configuration with recommended defaults
print_step "Creating supergfxctl configuration..."

# Default to Hybrid mode (best balance of performance and battery)
sudo tee "$CONFIG_FILE" > /dev/null <<'EOF'
{
  "mode": "Hybrid",
  "vfio_enable": false,
  "vfio_save": false,
  "always_reboot": false,
  "no_logind": false,
  "logout_timeout_s": 60,
  "hotplug_type": "None"
}
EOF

if [ $? -eq 0 ]; then
    print_success "Configuration created: $CONFIG_FILE"
else
    print_error "Failed to create configuration"
    exit 1
fi

echo ""

# Enable and start service
print_step "Configuring supergfxd service..."

if sudo systemctl enable supergfxd.service; then
    print_success "Service enabled (will start on boot)"
else
    print_error "Failed to enable service"
    exit 1
fi

if sudo systemctl restart supergfxd.service; then
    print_success "Service started"
else
    print_error "Failed to start service"
    exit 1
fi

echo ""

# Display status
print_step "Current GPU configuration:"
echo ""

CURRENT_MODE=$(supergfxctl --get 2>/dev/null || echo "Unknown")
SUPPORTED=$(supergfxctl --supported 2>/dev/null || echo "[]")
STATUS=$(supergfxctl --status 2>/dev/null || echo "Unknown")

echo "  Mode: $CURRENT_MODE"
echo "  Supported: $SUPPORTED"
echo "  dGPU Status: $STATUS"

echo ""
echo "✅ Hybrid GPU management configured!"
echo ""
echo "GPU Modes:"
echo "  • Integrated   - Only iGPU (best battery life)"
echo "  • Hybrid       - Both GPUs (automatic switching)"
echo "  • NvidiaNoModeset - Only dGPU (maximum performance)"
echo ""
echo "Switch modes with: supergfxctl --mode <mode>"
echo "Note: Mode changes require logout/reboot"
echo ""
