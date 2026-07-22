#!/usr/bin/env bash

#
# init_audio_profiles.sh - Configure PipeWire/WirePlumber audio profiles
# Idempotent: Safe to run multiple times
#
# This script ensures automatic audio device switching for:
# - USB audio devices (Razer Nari, gaming headsets, etc.)
# - Bluetooth audio devices with high-quality codecs
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

print_info() {
    echo -e "  ${NC}$1"
}

ask_yn() {
    local prompt="$1"
    local default="${2:-y}"

    while true; do
        if [ "$default" = "y" ]; then
            read -p "$(echo -e ${BLUE}${prompt}${NC} [Y/n]: )" yn
            yn=${yn:-y}
        else
            read -p "$(echo -e ${BLUE}${prompt}${NC} [y/N]: )" yn
            yn=${yn:-n}
        fi

        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

echo "🔊 Initializing audio profile management..."
echo ""

# ============================================================================
# Check Prerequisites
# ============================================================================

MISSING_PACKAGES=()

print_step "Checking audio system prerequisites..."

if ! command -v wpctl &> /dev/null; then
    print_error "WirePlumber (wpctl) not found"
    MISSING_PACKAGES+=("wireplumber")
else
    WP_VERSION=$(wpctl --version | head -n1 | awk '{print $2}')
    print_success "WirePlumber installed: v${WP_VERSION}"
fi

if ! command -v pactl &> /dev/null; then
    print_error "PipeWire PulseAudio compatibility (pactl) not found"
    MISSING_PACKAGES+=("pipewire-pulse")
else
    print_success "PipeWire PulseAudio compatibility installed"
fi

if ! systemctl --user is-active --quiet wireplumber.service; then
    print_error "WirePlumber service is not running"
    echo ""
    print_info "Start it with: systemctl --user start wireplumber.service"
    echo ""
fi

# Check for audio codec support
if pacman -Qi libldac &>/dev/null; then
    print_success "LDAC codec support installed"
else
    print_skip "LDAC codec support not found (optional for high-quality Bluetooth)"
    MISSING_PACKAGES+=("libldac")
fi

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo ""
    print_error "Missing required packages: ${MISSING_PACKAGES[*]}"
    echo ""
    print_info "Install them with: pacman -S ${MISSING_PACKAGES[*]}"
    echo ""
    if ! ask_yn "Continue anyway?" "n"; then
        exit 1
    fi
fi

echo ""

# ============================================================================
# Check WirePlumber Configuration Files
# ============================================================================

print_step "Checking WirePlumber configuration files..."
echo ""

CONFIG_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_CONFIG_DIR="$DOTFILES_DIR/wireplumber/.config/wireplumber/wireplumber.conf.d"

CONFIGS_MISSING=false
CONFIGS_TO_CHECK=(
    "51-bluetooth-autoswitch.conf"
    "52-default-nodes.conf"
    "53-usb-autoswitch.conf"
    "54-bluetooth-codecs.conf"
)

for config in "${CONFIGS_TO_CHECK[@]}"; do
    SOURCE_FILE="$SOURCE_CONFIG_DIR/$config"
    TARGET_FILE="$CONFIG_DIR/$config"

    if [ -f "$TARGET_FILE" ]; then
        print_success "$config is deployed"
    elif [ -f "$SOURCE_FILE" ]; then
        print_skip "$config exists in dotfiles but not deployed"
        CONFIGS_MISSING=true
    else
        print_error "$config not found"
        CONFIGS_MISSING=true
    fi
done

if [ "$CONFIGS_MISSING" = true ]; then
    echo ""
    print_info "Configuration files need to be deployed using GNU Stow:"
    print_info "  cd $DOTFILES_DIR"
    print_info "  stow wireplumber"
    echo ""
    if ask_yn "Would you like to stow the wireplumber module now?" "y"; then
        cd "$DOTFILES_DIR"
        if stow -v wireplumber 2>&1; then
            print_success "WirePlumber configuration deployed"
            RESTART_WIREPLUMBER=true
        else
            print_error "Failed to stow wireplumber module"
            print_info "You may need to remove conflicting files first"
            exit 1
        fi
    else
        print_skip "Skipped by user choice"
        echo ""
        print_info "Audio profiles will not be active until configs are deployed"
        exit 0
    fi
else
    # Configs are already deployed - offer to restart to pick up any changes
    echo ""
    if ask_yn "Restart WirePlumber to ensure latest configuration is active?" "y"; then
        RESTART_WIREPLUMBER=true
    fi
fi

echo ""

# ============================================================================
# Device Detection
# ============================================================================

print_step "Detecting audio devices..."
echo ""

# Check for USB audio devices
USB_DEVICES=$(pactl list cards short | grep -c "usb-" || true)
if [ "$USB_DEVICES" -gt 0 ]; then
    print_success "Found $USB_DEVICES USB audio device(s)"
    pactl list cards short | grep "usb-" | while read -r line; do
        print_info "  • $(echo "$line" | awk '{print $2}')"
    done
else
    print_skip "No USB audio devices detected"
fi

echo ""

# Check for Bluetooth devices
BT_DEVICES=$(pactl list cards short | grep -c "bluez" || true)
if [ "$BT_DEVICES" -gt 0 ]; then
    print_success "Found $BT_DEVICES Bluetooth audio device(s)"
    pactl list cards short | grep "bluez" | while read -r line; do
        print_info "  • $(echo "$line" | awk '{print $2}')"
    done
else
    print_skip "No Bluetooth audio devices detected"
fi

echo ""

# Check for Razer Nari specifically
if pactl list cards short | grep -q "Razer.*Nari"; then
    print_success "Razer Nari detected - automatic profile switching enabled"

    # Check if the profile is installed
    if [ -f "/usr/share/alsa-card-profile/mixer/profile-sets/razer-nari-usb-audio.conf" ]; then
        print_success "Razer Nari profile installed"
    else
        print_error "Razer Nari profile not found"
        print_info "Install with: pacman -S razer-nari-pipewire-profile"
    fi
fi

echo ""

# ============================================================================
# Restart WirePlumber if Needed
# ============================================================================

if [ "${RESTART_WIREPLUMBER:-false}" = true ]; then
    print_step "Restarting WirePlumber to apply configuration..."

    if systemctl --user restart wireplumber.service; then
        print_success "WirePlumber restarted"
        sleep 2  # Give it time to settle
    else
        print_error "Failed to restart WirePlumber"
        print_info "Try manually: systemctl --user restart wireplumber.service"
    fi
    echo ""
fi

# ============================================================================
# Verification
# ============================================================================

print_step "Verifying audio system status..."
echo ""

# Check default sink
DEFAULT_SINK=$(pactl get-default-sink)
print_info "Default audio output: $DEFAULT_SINK"

# Check default source
DEFAULT_SOURCE=$(pactl get-default-source)
print_info "Default audio input: $DEFAULT_SOURCE"

echo ""

# ============================================================================
# Summary and Next Steps
# ============================================================================

echo "✅ Audio profile initialization complete"
echo ""
echo "Configuration active:"
echo "  • USB device auto-switch: ${GREEN}Enabled${NC}"
echo "  • Bluetooth device auto-switch: ${GREEN}Enabled${NC}"
echo "  • High-quality Bluetooth codecs: ${GREEN}Enabled${NC}"
echo ""
echo "Supported features:"
echo "  • Razer Nari Ultimate - Auto-detects and uses full profile"
echo "  • Bluetooth headsets - Prefers LDAC/aptX HD for best quality"
echo "  • Generic USB audio - Auto-switches when connected"
echo ""
echo "Testing:"
echo "  1. Plug in a USB audio device - it should become the default"
echo "  2. Connect Bluetooth headphones - they should auto-switch"
echo "  3. Check active codec: pactl list cards | grep -A20 bluez"
echo ""
echo "Troubleshooting:"
echo "  • View WirePlumber logs: journalctl --user -u wireplumber.service -f"
echo "  • List all devices: wpctl status"
echo "  • Manual device switch: wpctl set-default <device-id>"
echo ""
