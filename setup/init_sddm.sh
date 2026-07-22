#!/usr/bin/env bash

#
# init_sddm.sh - Configure SDDM login screen with Catppuccin theme
# Idempotent: Safe to run multiple times
#
# This script:
# - Disables auto-login for security
# - Installs Catppuccin SDDM themes matching system theme
# - Synchronizes SDDM theme with system theme
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
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
    echo -e "${CYAN}ℹ${NC} $1"
}

ask_yn() {
    local prompt="$1"
    local default="${2:-n}"

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

echo "🎨 SDDM Login Screen Configuration"
echo ""

# ============================================================================
# Check Prerequisites
# ============================================================================

print_step "Checking prerequisites..."

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    print_error "SDDM not installed"
    echo "This script requires SDDM display manager"
    exit 1
fi

# Check if SDDM is the active display manager
if ! systemctl is-enabled display-manager.service 2>&1 | grep -q sddm; then
    print_skip "SDDM not active display manager"
    echo "Current display manager: $(systemctl is-enabled display-manager.service 2>&1 || echo 'unknown')"
    if ! ask_yn "Continue anyway?" "n"; then
        exit 0
    fi
fi

print_success "SDDM is installed and active"
echo ""

# ============================================================================
# Detect Current Theme
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
THEME_FLAVOR_FILE="$HOME/.config/themes/current_flavor.txt"

print_step "Detecting current theme..."

if [ -f "$THEME_FLAVOR_FILE" ]; then
    CURRENT_FLAVOR=$(cat "$THEME_FLAVOR_FILE")
    print_success "Current theme: $CURRENT_FLAVOR"
else
    CURRENT_FLAVOR="macchiato"
    print_skip "No theme file found, using default: $CURRENT_FLAVOR"
fi

echo ""

# ============================================================================
# Install Catppuccin SDDM Themes
# ============================================================================

print_step "Checking Catppuccin SDDM themes..."

# Map flavor names to package names
declare -A THEME_PACKAGES=(
    ["mocha"]="catppuccin-sddm-theme-mocha"
    ["latte"]="catppuccin-sddm-theme-latte"
    ["frappe"]="catppuccin-sddm-theme-frappe"
    ["macchiato"]="catppuccin-sddm-theme-macchiato"
)

# Check which themes are installed
INSTALLED_THEMES=()
MISSING_THEMES=()

for flavor in "${!THEME_PACKAGES[@]}"; do
    pkg="${THEME_PACKAGES[$flavor]}"
    if yay -Q "$pkg" &>/dev/null || pacman -Q "$pkg" &>/dev/null; then
        INSTALLED_THEMES+=("$flavor")
    else
        MISSING_THEMES+=("$flavor")
    fi
done

if [ ${#INSTALLED_THEMES[@]} -gt 0 ]; then
    print_success "Installed themes: ${INSTALLED_THEMES[*]}"
fi

if [ ${#MISSING_THEMES[@]} -gt 0 ]; then
    echo ""
    print_info "Missing themes: ${MISSING_THEMES[*]}"
    echo ""
    echo "To match your system theme switcher, install all 4 Catppuccin flavors:"
    echo "  • mocha (dark)"
    echo "  • macchiato (dark)"
    echo "  • frappe (dark)"
    echo "  • latte (light)"
    echo ""

    if ask_yn "Install all 4 Catppuccin SDDM themes?" "y"; then
        print_step "Installing Catppuccin SDDM themes..."

        packages_to_install=()
        for flavor in "${MISSING_THEMES[@]}"; do
            packages_to_install+=("${THEME_PACKAGES[$flavor]}")
        done

        if yay -S --needed --noconfirm "${packages_to_install[@]}"; then
            print_success "Themes installed successfully"
        else
            print_error "Failed to install themes"
            echo "Try manually: yay -S ${packages_to_install[*]}"
            exit 1
        fi
    else
        # Just install current flavor theme
        current_pkg="${THEME_PACKAGES[$CURRENT_FLAVOR]}"
        if ! yay -Q "$current_pkg" &>/dev/null && ! pacman -Q "$current_pkg" &>/dev/null; then
            print_step "Installing theme for current flavor ($CURRENT_FLAVOR)..."

            if yay -S --needed --noconfirm "$current_pkg"; then
                print_success "Theme installed"
            else
                print_error "Failed to install $current_pkg"
                exit 1
            fi
        fi
    fi
fi

echo ""

# ============================================================================
# Deploy SDDM Configuration
# ============================================================================

print_step "Configuring SDDM..."

CONFIG_SRC="$DOTFILES_DIR/setup/system-configs/sddm.conf.d/theme.conf"
CONFIG_DEST="/etc/sddm.conf.d/theme.conf"
OLD_CONFIG="/etc/sddm.conf.d/99-theme.conf"

# Default accent color
ACCENT="mauve"

# Full theme name with accent color
THEME_NAME="catppuccin-$CURRENT_FLAVOR-$ACCENT"

if [ ! -f "$CONFIG_SRC" ]; then
    print_error "Config template not found: $CONFIG_SRC"
    exit 1
fi

# Remove old config file if it exists (migration from old setup)
if [ -f "$OLD_CONFIG" ]; then
    print_step "Removing old config file..."
    sudo rm -f "$OLD_CONFIG"
    print_success "Old config removed"
fi

# Check if config already exists and matches current theme
if [ -f "$CONFIG_DEST" ]; then
    if grep -q "Current=catppuccin-$CURRENT_FLAVOR-" "$CONFIG_DEST" 2>/dev/null; then
        print_skip "SDDM already configured with $CURRENT_FLAVOR theme"
    else
        print_step "Updating SDDM theme to match current flavor..."
        # Update the theme in existing config with full name including accent
        sudo sed -i "s|^Current=.*|Current=$THEME_NAME|" "$CONFIG_DEST"
        print_success "Theme updated to $THEME_NAME"
    fi

    # Ensure permissions are correct (must be readable by sddm user)
    sudo chmod 644 "$CONFIG_DEST"

    # Check if auto-login is disabled
    if grep -q "^User=\s*$" "$CONFIG_DEST" 2>/dev/null || ! grep -q "^User=" "$CONFIG_DEST" 2>/dev/null; then
        print_skip "Auto-login already disabled"
    else
        print_step "Disabling auto-login..."
        sudo sed -i 's/^User=.*/User=/' "$CONFIG_DEST"
        print_success "Auto-login disabled"
    fi
else
    print_step "Creating SDDM configuration..."

    # Create temporary file with current theme (with accent color)
    temp_config=$(mktemp)
    cp "$CONFIG_SRC" "$temp_config"
    sed -i "s|^Current=.*|Current=$THEME_NAME|" "$temp_config"

    # Copy to system location
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$temp_config" "$CONFIG_DEST"
    sudo chmod 644 "$CONFIG_DEST"  # Must be readable by sddm user
    rm "$temp_config"

    print_success "SDDM configured with $THEME_NAME theme"
fi

echo ""

# ============================================================================
# Install Automatic Theme Switching Components
# ============================================================================

print_step "Setting up automatic theme switching..."

HELPER_SCRIPT_SRC="$DOTFILES_DIR/setup/system-configs/usr/local/bin/update-sddm-theme"
HELPER_SCRIPT_DEST="/usr/local/bin/update-sddm-theme"
POLKIT_RULE_SRC="$DOTFILES_DIR/setup/system-configs/etc/polkit-1/rules.d/50-sddm-theme.rules"
POLKIT_RULE_DEST="/etc/polkit-1/rules.d/50-sddm-theme.rules"

# Check if components already installed
if [ -f "$HELPER_SCRIPT_DEST" ] && [ -f "$POLKIT_RULE_DEST" ]; then
    print_skip "Automatic theme switching already configured"
else
    echo ""
    print_info "This enables automatic SDDM theme switching via the theme switcher"
    print_info "When you change themes (Alt+Space → Theme), SDDM will update automatically"
    echo ""

    if ask_yn "Install automatic theme switching?" "y"; then
        # Install helper script
        if [ -f "$HELPER_SCRIPT_SRC" ]; then
            print_step "Installing SDDM theme update helper..."
            sudo cp "$HELPER_SCRIPT_SRC" "$HELPER_SCRIPT_DEST"
            sudo chmod +x "$HELPER_SCRIPT_DEST"
            print_success "Helper script installed: $HELPER_SCRIPT_DEST"
        else
            print_error "Helper script not found: $HELPER_SCRIPT_SRC"
        fi

        # Install polkit rule
        if [ -f "$POLKIT_RULE_SRC" ]; then
            print_step "Installing polkit rule for passwordless theme switching..."
            sudo mkdir -p /etc/polkit-1/rules.d
            sudo cp "$POLKIT_RULE_SRC" "$POLKIT_RULE_DEST"
            print_success "Polkit rule installed: $POLKIT_RULE_DEST"

            # Restart polkit to apply rule
            print_step "Restarting polkit service..."
            if sudo systemctl restart polkit.service 2>/dev/null; then
                print_success "Polkit service restarted"
            else
                print_skip "Could not restart polkit (may require reboot)"
            fi
        else
            print_error "Polkit rule not found: $POLKIT_RULE_SRC"
        fi

        echo ""
        print_success "Automatic theme switching configured!"
        print_info "SDDM theme will now update when you change system theme"
    else
        print_skip "Skipped automatic theme switching"
        print_info "You can manually update SDDM theme in: $CONFIG_DEST"
    fi
fi

echo ""

# ============================================================================
# Verify Configuration
# ============================================================================

print_step "Verifying configuration..."

# Check theme directories exist (themes now include accent color variants)
theme_count=$(ls -d /usr/share/sddm/themes/catppuccin-$CURRENT_FLAVOR-* 2>/dev/null | wc -l)
if [ "$theme_count" -gt 0 ]; then
    print_success "Found $theme_count theme variant(s) for $CURRENT_FLAVOR"
    # Show first variant as example
    first_variant=$(ls -d /usr/share/sddm/themes/catppuccin-$CURRENT_FLAVOR-* 2>/dev/null | head -1 | xargs basename)
    echo "  Example: $first_variant"
else
    print_error "No theme variants found for: catppuccin-$CURRENT_FLAVOR-*"
    echo "Theme may not be installed correctly"
fi

# Check SDDM config is valid (with timeout to prevent hanging)
if timeout 3 sudo sddm --test-mode --config /etc/sddm.conf &>/dev/null; then
    print_success "SDDM configuration is valid"
else
    print_skip "SDDM test mode not available (this is normal)"
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

echo "═══════════════════════════════════════════════════════"
echo "  ✅ SDDM Login Screen Configured!"
echo "═══════════════════════════════════════════════════════"
echo ""
print_info "Configuration:"
echo "  • Theme: Catppuccin $CURRENT_FLAVOR"
echo "  • Auto-login: Disabled (secure login required)"
echo "  • Config: $CONFIG_DEST"
echo ""
print_info "Next steps:"
echo "  1. Restart your system to see the new login screen"
echo "  2. Or test with: sudo systemctl restart sddm.service"
echo "     (WARNING: This will log you out immediately!)"
echo ""
print_info "Theme switching:"
if [ -f "$HELPER_SCRIPT_DEST" ] && [ -f "$POLKIT_RULE_DEST" ]; then
    echo "  ✓ Automatic: Use Alt+Space → Settings → Theme"
    echo "    SDDM theme updates automatically with system theme!"
else
    echo "  • Use Alt+Space → Settings → Theme to change theme"
    echo "  • SDDM theme must be manually updated in $CONFIG_DEST"
    echo "  • Change 'Current=catppuccin-<flavor>' to match system theme"
fi
echo ""
print_info "Installed themes:"
for flavor in mocha latte frappe macchiato; do
    pkg="${THEME_PACKAGES[$flavor]}"
    if yay -Q "$pkg" &>/dev/null || pacman -Q "$pkg" &>/dev/null; then
        echo "  ✓ $flavor"
    else
        echo "  ✗ $flavor (not installed)"
    fi
done
echo ""
