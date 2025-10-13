#!/usr/bin/env bash

#
# init_fingerprint.sh - Complete fingerprint setup (all-in-one)
# Detects CS9711, builds driver locally, configures PAM, sets permissions, enrolls
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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "🔐 Complete Fingerprint Setup"
echo ""

# ============================================================================
# STEP 1: Check if fprintd is installed
# ============================================================================
print_step "Checking fprintd installation..."
if ! command -v fprintd-list &> /dev/null; then
    print_error "fprintd not installed"
    echo "Installing fprintd..."
    sudo pacman -S --needed fprintd
    print_success "fprintd installed"
else
    print_success "fprintd is installed"
fi

echo ""

# ============================================================================
# STEP 2: Detect fingerprint device
# ============================================================================
print_step "Detecting fingerprint devices..."

DEVICE_INFO=$(lsusb | grep -iE '(finger|print|biometric|validity|synaptics|elan|goodix|chipsailing)' || true)

if [ -z "$DEVICE_INFO" ]; then
    print_skip "No fingerprint device detected"
    echo "Supported devices: CS9711, Goodix, Synaptics, Validity, Elan"
    exit 0
fi

echo ""
echo "Detected fingerprint device:"
echo "  $DEVICE_INFO"
echo ""

IS_CS9711=false
if echo "$DEVICE_INFO" | grep -q "2541:0236\|CS9711"; then
    IS_CS9711=true
    print_success "Detected Chipsailing CS9711"
fi

# ============================================================================
# STEP 3: Check if device is recognized by fprintd
# ============================================================================
print_step "Testing device recognition..."

sudo systemctl restart fprintd.service
sleep 2

if fprintd-list "$USER" &>/dev/null; then
    DEVICE_SUPPORTED=true
    print_success "Device is recognized by fprintd"
else
    DEVICE_SUPPORTED=false
    print_warning "Device not recognized by current libfprint"
fi

echo ""

# ============================================================================
# STEP 4: Build CS9711 driver if needed
# ============================================================================
if [ "$IS_CS9711" = true ] && [ "$DEVICE_SUPPORTED" = false ]; then
    print_step "CS9711 requires special driver - building locally..."
    echo ""

    BUILD_DIR="$HOME/tmp/libfprint-cs9711-build"

    # Install build dependencies
    print_step "Installing build dependencies..."
    sudo pacman -S --needed base-devel git meson ninja gtk-doc gobject-introspection \
        glib2 glib2-devel libgusb libgudev pixman openssl python-cairo python-gobject

    echo ""

    # Create build directory
    print_step "Creating build directory..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    # Clone repository
    print_step "Cloning libfprint-cs9711 repository..."
    if [ ! -d "libfprint-cs9711" ]; then
        git clone https://github.com/someone5678/libfprint.git libfprint-cs9711
    fi
    cd libfprint-cs9711

    # Checkout CS9711 branch
    git checkout cs9711 2>/dev/null || git checkout main || true

    echo ""
    print_step "Building driver..."

    # Use system Python (not mise)
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '.local/share/mise' | tr '\n' ':' | sed 's/:$//')

    # Clean and rebuild
    rm -rf build
    if meson setup build \
        --prefix=/usr \
        --libexecdir=lib \
        --buildtype=release \
        -Dudev_rules=enabled \
        -Dudev_rules_dir=/usr/lib/udev/rules.d \
        -Dgtk-examples=false \
        -Ddoc=false; then

        cd build
        if ninja; then
            print_success "Build successful"
            echo ""
            print_step "Installing driver..."
            sudo ninja install
            print_success "Driver installed"

            # Reload udev
            sudo udevadm control --reload-rules
            sudo udevadm trigger

            print_success "Driver loaded"
            echo ""
        else
            print_error "Build failed"
            exit 1
        fi
    else
        print_error "Configuration failed"
        exit 1
    fi

    # Restart fprintd
    print_step "Restarting fprintd..."
    sudo systemctl restart fprintd.service
    sleep 2
    print_success "Device should now be recognized"
    echo ""
fi

# ============================================================================
# STEP 5: Setup polkit permissions
# ============================================================================
print_step "Checking polkit permissions..."

POLKIT_RULE="/etc/polkit-1/rules.d/50-fprintd.rules"

if [ ! -f "$POLKIT_RULE" ]; then
    print_step "Creating polkit rule for fprintd..."

    sudo tee "$POLKIT_RULE" > /dev/null <<'EOF'
// Allow users in wheel group to enroll and verify fingerprints
polkit.addRule(function (action, subject) {
    if (action.id == "net.reactivated.fprint.device.enroll" ||
        action.id == "net.reactivated.fprint.device.verify") {
        if (subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    }
});

// Allow users to manage their own fingerprints
polkit.addRule(function (action, subject) {
    if (action.id == "net.reactivated.fprint.device.enroll" ||
        action.id == "net.reactivated.fprint.device.verify") {
        if (subject.user == action.lookup("user")) {
            return polkit.Result.YES;
        }
    }
});
EOF

    print_success "Polkit rule created"

    # Restart polkit
    sudo systemctl restart polkit.service
    sudo systemctl restart fprintd.service
    sleep 1
    print_success "Services restarted"
else
    print_success "Polkit permissions already configured"
fi

echo ""

# ============================================================================
# STEP 6: Enable and start fprintd service
# ============================================================================
print_step "Configuring fprintd service..."

if systemctl is-enabled --quiet fprintd.service 2>/dev/null; then
    print_success "Service already enabled"
else
    sudo systemctl enable fprintd.service
    print_success "Service enabled"
fi

if systemctl is-active --quiet fprintd.service; then
    print_success "Service is running"
else
    sudo systemctl start fprintd.service
    print_success "Service started"
fi

echo ""

# ============================================================================
# STEP 7: Configure PAM
# ============================================================================
print_step "Configuring PAM authentication..."

PAM_FILE="/etc/pam.d/system-auth"
PAM_LINE="auth       sufficient  pam_fprintd.so"

if grep -q "pam_fprintd.so" "$PAM_FILE"; then
    print_success "PAM already configured for fingerprint"
else
    echo ""
    echo "This will add fingerprint authentication to system-auth."
    echo "It will try fingerprint first, then fall back to password."
    echo ""
    read -p "$(echo -e ${BLUE}Configure PAM for fingerprint auth?${NC} [Y/n]: )" response
    response=${response:-y}

    if [[ "$response" =~ ^[Yy] ]]; then
        # Create backup
        sudo cp "$PAM_FILE" "$PAM_FILE.backup.$(date +%Y%m%d-%H%M%S)"
        print_success "Created backup: $PAM_FILE.backup.*"

        # Add pam_fprintd.so after pam_faillock preauth
        sudo sed -i '/^auth.*pam_faillock\.so.*preauth/a auth       sufficient  pam_fprintd.so' "$PAM_FILE"

        if grep -q "pam_fprintd.so" "$PAM_FILE"; then
            print_success "PAM configured successfully"
        else
            print_error "Failed to configure PAM"
            exit 1
        fi
    else
        print_skip "PAM configuration skipped"
    fi
fi

echo ""

# ============================================================================
# STEP 8: Check for enrolled fingerprints
# ============================================================================
print_step "Checking for enrolled fingerprints..."

ENROLLED_COUNT=$(fprintd-list "$USER" 2>/dev/null | grep -c "finger:" || echo "0")

if [ "$ENROLLED_COUNT" -gt 0 ]; then
    print_success "Found $ENROLLED_COUNT enrolled fingerprint(s)"
    echo ""
    fprintd-list "$USER" 2>/dev/null | grep "finger:" | sed 's/^/  /'
else
    print_step "No fingerprints enrolled yet"
    echo ""
    echo "Would you like to enroll a fingerprint now?"
    echo ""
    read -p "$(echo -e ${BLUE}Enroll fingerprint?${NC} [Y/n]: )" response
    response=${response:-y}

    if [[ "$response" =~ ^[Yy] ]]; then
        echo ""
        echo "Available fingers:"
        echo "  1) Right index finger (recommended)"
        echo "  2) Left index finger"
        echo "  3) Right thumb"
        echo "  4) Left thumb"
        echo "  5) Right middle finger"
        echo "  6) Left middle finger"
        echo ""
        read -p "$(echo -e ${BLUE}Select finger [1-6]:${NC} ) " finger_choice

        case "$finger_choice" in
            1) FINGER="right-index-finger" ;;
            2) FINGER="left-index-finger" ;;
            3) FINGER="right-thumb" ;;
            4) FINGER="left-thumb" ;;
            5) FINGER="right-middle-finger" ;;
            6) FINGER="left-middle-finger" ;;
            *) FINGER="right-index-finger" ;;
        esac

        echo ""
        print_step "Enrolling $FINGER..."
        echo ""
        echo "Please scan your finger multiple times when prompted."
        echo "Scan from different angles for better recognition."
        echo ""

        if fprintd-enroll -f "$FINGER" "$USER"; then
            echo ""
            print_success "Fingerprint enrolled successfully!"
        else
            echo ""
            print_error "Enrollment failed"
            echo "You can try again later with: fprintd-enroll"
        fi
    fi
fi

echo ""
echo "✅ Fingerprint setup complete!"
echo ""
echo "Usage:"
echo "  • Use fingerprint for sudo, login, and hyprlock"
echo "  • Password fallback is always available"
echo "  • Manage fingerprints via waybar fingerprint icon"
echo ""
echo "Commands:"
echo "  fprintd-enroll           - Enroll new fingerprint"
echo "  fprintd-list $USER       - List enrolled fingerprints"
echo "  fprintd-delete $USER     - Delete fingerprint"
echo "  fprintd-verify           - Test fingerprint"
echo ""
