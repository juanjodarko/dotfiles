#!/usr/bin/env bash

#
# setup.sh - Master setup orchestrator for dotfiles
# Idempotent: Safe to run multiple times, only installs missing components
#
# Usage:
#   ./setup.sh                 # Run all setup steps
#   ./setup.sh --verify-only   # Only run verification
#   ./setup.sh --skip-verify   # Skip final verification
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SETUP_DIR")"

# Flags
VERIFY_ONLY=false
SKIP_VERIFY=false

print_header() {
    echo ""
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  ${CYAN}$1${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}→${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}!${NC} ${1}"
}

ask_yn() {
    local prompt="$1"
    local default="${2:-y}"

    while true; do
        if [ "$default" = "y" ]; then
            read -p "$(echo -e ${CYAN}${prompt}${NC} [Y/n]: )" yn
            yn=${yn:-y}
        else
            read -p "$(echo -e ${CYAN}${prompt}${NC} [y/N]: )" yn
            yn=${yn:-n}
        fi

        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

run_script() {
    local script="$1"
    local description="$2"
    local optional="${3:-false}"

    if [ ! -f "$SETUP_DIR/$script" ]; then
        print_warning "Script not found: $script"
        return 1
    fi

    print_step "$description"
    echo ""

    if "$SETUP_DIR/$script"; then
        print_success "$description complete"
        return 0
    else
        if [ "$optional" = "true" ]; then
            print_warning "$description had warnings (continuing)"
            return 0
        else
            echo ""
            print_warning "$description failed"
            if ask_yn "Continue anyway?" "y"; then
                return 0
            else
                exit 1
            fi
        fi
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --verify-only   Only run verification checks"
    echo "  --skip-verify   Skip final verification"
    echo "  --help          Show this help message"
    echo ""
    echo "This script runs all dotfiles initialization steps:"
    echo "  1. Check and install missing packages"
    echo "  2. Initialize required directories"
    echo "  3. Initialize theme system"
    echo "  4. Install plugins (Tmux, Neovim)"
    echo "  5. Setup systemd services"
    echo "  6. Install mise tools"
    echo "  7. Verify installation"
    echo ""
    echo "All steps are idempotent - safe to run multiple times."
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verify-only)
            VERIFY_ONLY=true
            shift
            ;;
        --skip-verify)
            SKIP_VERIFY=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_header "Dotfiles Setup System"

    echo "Dotfiles directory: $DOTFILES_DIR"
    echo "Setup directory: $SETUP_DIR"
    echo ""

    # If verify-only mode, run verification and exit
    if [ "$VERIFY_ONLY" = true ]; then
        run_script "verify.sh" "Running verification checks"
        exit $?
    fi

    print_step "Starting idempotent setup process..."
    echo "This will only install missing components."
    echo ""

    if ! ask_yn "Continue with setup?" "y"; then
        echo "Setup cancelled"
        exit 0
    fi

    # Step 1: Check and install missing packages
    print_header "Step 1/6: System Packages"
    if command -v pacman &> /dev/null; then
        run_script "init_packages.sh" "Checking and installing missing packages" "true"

        # Configure hybrid GPU if supergfxctl was installed
        if command -v supergfxctl &> /dev/null; then
            echo ""
            run_script "init_supergfx.sh" "Configuring hybrid GPU management" "true"
        fi

        # Configure fingerprint if fprintd was installed and device detected
        if command -v fprintd-list &> /dev/null && lsusb | grep -qiE '(finger|print|biometric|validity|synaptics|elan|goodix|chipsailing)'; then
            echo ""
            run_script "init_fingerprint.sh" "Configuring fingerprint authentication" "true"
        fi

        # Configure audio profiles if WirePlumber is installed
        if command -v wpctl &> /dev/null; then
            echo ""
            run_script "init_audio_profiles.sh" "Configuring audio profile management" "true"
        fi

        # Configure laptop power management if on a laptop
        chassis_type=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "0")
        if [[ "$chassis_type" =~ ^(8|9|10|14)$ ]]; then
            echo ""
            run_script "init_power_management.sh" "Configuring laptop power management" "true"
        fi
    else
        print_warning "pacman not found, skipping package installation"
    fi
    echo ""

    # Step 2: Initialize directories
    print_header "Step 2/6: Directories"
    run_script "init_directories.sh" "Initializing required directories" "true"
    echo ""

    # Step 3: Initialize themes
    print_header "Step 3/6: Theme System"
    run_script "init_themes.sh" "Initializing theme system" "true"
    echo ""

    # Step 4: Install plugins
    print_header "Step 4/6: Plugins"
    run_script "init_plugins.sh" "Installing plugins (Tmux, Neovim)" "true"
    echo ""

    # Step 5: Setup services
    print_header "Step 5/6: Services"
    if command -v systemctl &> /dev/null; then
        run_script "init_services.sh" "Setting up systemd services" "true"
    else
        print_warning "systemctl not found, skipping service setup"
    fi
    echo ""

    # Step 6: Install mise tools
    print_header "Step 6/6: Mise Tools"
    if command -v mise &> /dev/null; then
        run_script "init_mise.sh" "Installing mise tools" "true"
    else
        print_warning "mise not found, skipping tool installation"
    fi
    echo ""

    # Final verification
    if [ "$SKIP_VERIFY" = false ]; then
        print_header "Verification"
        run_script "verify.sh" "Verifying installation" "true"
    fi

    # Success summary
    print_header "Setup Complete!"

    echo -e "${GREEN}✅ All setup steps completed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Open Neovim to finish plugin installation"
    echo "  3. In Tmux, press Prefix + I to install plugins"
    echo "  4. Check theme system: Alt+Space → Settings → Theme"
    echo ""
    echo "To verify installation at any time:"
    echo "  $SETUP_DIR/verify.sh"
    echo ""
    echo "To update or fix missing components:"
    echo "  $SETUP_DIR/setup.sh"
    echo ""
}

# Run main function
main "$@"
