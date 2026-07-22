#!/usr/bin/env bash

#
# init_power_management.sh - Configure laptop power management
# Idempotent: Safe to run multiple times
#
# Sets up intelligent suspend/resume behavior:
# - Power-aware: Only suspends on battery, stays awake when plugged in
# - Prevents spurious wake-ups from USB/PCIe devices
# - GPU mode-aware for hybrid graphics laptops
# - Smart lid handling based on power state
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Flags
VERIFY_ONLY=false
FORCE=false

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

# ============================================================================
# Hardware Detection
# ============================================================================

is_laptop() {
    local chassis_type=$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "0")
    # DMTF SMBIOS: 8=Portable, 9=Laptop, 10=Notebook, 14=Sub Notebook
    [[ "$chassis_type" =~ ^(8|9|10|14)$ ]]
}

is_razer_blade() {
    local vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "")
    local product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
    [[ "$vendor" == "Razer" ]] && [[ "$product" == "Blade" ]]
}

get_system_model() {
    local product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")
    local version=$(cat /sys/class/dmi/id/product_version 2>/dev/null || echo "")
    if [ -n "$version" ]; then
        echo "$product $version"
    else
        echo "$product"
    fi
}

has_battery() {
    [ -d /sys/class/power_supply/BAT* ] 2>/dev/null
}

# ============================================================================
# Verification Functions
# ============================================================================

verify_wake_sources() {
    print_step "Checking wake source configuration..."

    local issues=0

    if [ -f /proc/acpi/wakeup ]; then
        # Check USB wake (XHC should be disabled)
        if grep -q "^XHC.*\*enabled" /proc/acpi/wakeup 2>/dev/null; then
            print_error "USB wake still enabled (XHC)"
            issues=$((issues + 1))
        else
            print_success "USB wake disabled"
        fi

        # Check PCIe wakes (PEG0, RP13, RP06 should be disabled)
        for device in PEG0 RP13 RP06; do
            if grep -q "^$device.*\*enabled" /proc/acpi/wakeup 2>/dev/null; then
                print_skip "$device wake still enabled"
                issues=$((issues + 1))
            fi
        done

        if [ $issues -eq 0 ]; then
            print_success "PCIe wake sources disabled"
        fi
    else
        print_skip "No ACPI wakeup interface found"
    fi

    return $issues
}

verify_services() {
    print_step "Checking systemd services..."

    local issues=0

    # Check system services
    for service in disable-usb-wake disable-pcie-wake; do
        if systemctl is-enabled "$service.service" &>/dev/null; then
            if systemctl is-active "$service.service" &>/dev/null; then
                print_success "$service.service enabled and running"
            else
                print_skip "$service.service enabled but not running"
                issues=$((issues + 1))
            fi
        else
            print_skip "$service.service not enabled"
            issues=$((issues + 1))
        fi
    done

    # Check nvidia-powerd conditional
    if [ -f /etc/systemd/system/nvidia-powerd.service.d/10-conditional.conf ]; then
        print_success "NVIDIA powerd conditional configuration present"
    else
        print_skip "NVIDIA powerd conditional not configured"
    fi

    # Check logind configuration
    if [ -f /etc/systemd/logind.conf.d/10-power-aware-lid.conf ]; then
        print_success "Power-aware lid handling configured"
    else
        print_skip "Power-aware lid handling not configured"
        issues=$((issues + 1))
    fi

    return $issues
}

verify_scripts() {
    print_step "Checking power management scripts..."

    local issues=0

    for script in conditional-suspend.sh gpu-mode-check.sh gpu-mode-monitor.sh; do
        if [ -x "$HOME/.local/bin/$script" ]; then
            print_success "$script installed and executable"
        else
            print_skip "$script not found"
            issues=$((issues + 1))
        fi
    done

    return $issues
}

verify_ac_detection() {
    print_step "Checking AC power detection..."

    if [ -f /sys/class/power_supply/AC0/online ]; then
        local ac_status=$(cat /sys/class/power_supply/AC0/online)
        if [ "$ac_status" = "1" ]; then
            print_success "AC power detected (plugged in)"
        else
            print_success "Battery power detected (unplugged)"
        fi
        return 0
    else
        print_error "AC power status file not found"
        return 1
    fi
}

verify_bluetooth_power() {
    print_step "Checking Bluetooth USB autosuspend configuration..."

    local issues=0

    # Check udev rule
    if [ -f /etc/udev/rules.d/50-bluetooth-usb-disable-autosuspend.rules ]; then
        print_success "Bluetooth USB autosuspend udev rule present"
    else
        print_skip "Bluetooth USB autosuspend udev rule not found"
        issues=$((issues + 1))
    fi

    # Check systemd service
    if systemctl is-enabled bluetooth-disable-usb-autosuspend.service &>/dev/null; then
        if systemctl is-active bluetooth-disable-usb-autosuspend.service &>/dev/null; then
            print_success "Bluetooth power management service enabled and running"
        else
            print_skip "Bluetooth power management service enabled but not running"
            issues=$((issues + 1))
        fi
    else
        print_skip "Bluetooth power management service not enabled"
        issues=$((issues + 1))
    fi

    # Check actual USB devices
    local bt_usb_found=false
    for device in /sys/bus/usb/devices/*/; do
        if [ -f "$device/power/control" ]; then
            if [ -f "$device/driver" ] && readlink "$device/driver" 2>/dev/null | grep -q btusb; then
                bt_usb_found=true
                local control_value=$(cat "$device/power/control" 2>/dev/null || echo "unknown")
                if [ "$control_value" = "on" ]; then
                    print_success "Bluetooth USB autosuspend disabled (control=$control_value)"
                else
                    print_error "Bluetooth USB autosuspend still enabled (control=$control_value)"
                    issues=$((issues + 1))
                fi
                break
            fi
        fi
    done

    if [ "$bt_usb_found" = false ]; then
        print_skip "No Bluetooth USB devices detected (rules will apply when detected)"
    fi

    return $issues
}

run_verification() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Power Management Verification"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    local total_issues=0

    verify_scripts
    total_issues=$((total_issues + $?))
    echo ""

    verify_services
    total_issues=$((total_issues + $?))
    echo ""

    verify_wake_sources
    total_issues=$((total_issues + $?))
    echo ""

    verify_ac_detection
    total_issues=$((total_issues + $?))
    echo ""

    verify_bluetooth_power
    total_issues=$((total_issues + $?))
    echo ""

    if [ $total_issues -eq 0 ]; then
        print_success "All power management components configured correctly!"
        return 0
    else
        print_skip "Found $total_issues issue(s) - run setup to fix"
        return 1
    fi
}

# ============================================================================
# Deployment Functions
# ============================================================================

deploy_scripts() {
    print_step "Deploying power management scripts..."

    # Check if bin module is stowed
    if [ -L "$HOME/.local/bin/conditional-suspend.sh" ]; then
        print_skip "Scripts already deployed via stow"
        return 0
    fi

    if [ ! -d "$DOTFILES_DIR/bin" ]; then
        print_error "bin module not found in dotfiles"
        return 1
    fi

    echo ""
    if ask_yn "Deploy scripts via 'stow bin'?" "y"; then
        cd "$DOTFILES_DIR"
        if stow -v bin 2>&1 | grep -q "LINK"; then
            print_success "Scripts deployed"
        else
            print_skip "Scripts may already be linked"
        fi

        # Ensure executable
        for script in conditional-suspend.sh gpu-mode-check.sh gpu-mode-monitor.sh; do
            if [ -f "$DOTFILES_DIR/bin/.local/bin/$script" ]; then
                chmod +x "$DOTFILES_DIR/bin/.local/bin/$script"
            fi
        done
    else
        print_skip "Skipped by user choice"
        return 1
    fi
}

deploy_system_services() {
    print_step "Deploying system services (requires sudo)..."

    # Check if already deployed
    local already_deployed=true
    for service in disable-usb-wake disable-pcie-wake; do
        if ! systemctl list-unit-files | grep -q "$service.service"; then
            already_deployed=false
            break
        fi
    done

    if [ "$already_deployed" = true ] && [ "$FORCE" != true ]; then
        print_skip "System services already deployed"
        return 0
    fi

    echo ""
    print_info "This will install services to /etc/systemd/system/"
    print_info "Services: disable-usb-wake, disable-pcie-wake, nvidia-powerd conditional"
    echo ""

    if ! ask_yn "Deploy system services?" "y"; then
        print_skip "Skipped by user choice"
        return 0
    fi

    # Create directories
    sudo mkdir -p /etc/systemd/system/nvidia-powerd.service.d

    # Copy service files
    if [ -f "$DOTFILES_DIR/systemd/.config/systemd/system/disable-usb-wake.service" ]; then
        sudo cp "$DOTFILES_DIR/systemd/.config/systemd/system/disable-usb-wake.service" \
            /etc/systemd/system/
        print_success "Copied disable-usb-wake.service"
    fi

    if [ -f "$DOTFILES_DIR/systemd/.config/systemd/system/disable-pcie-wake.service" ]; then
        sudo cp "$DOTFILES_DIR/systemd/.config/systemd/system/disable-pcie-wake.service" \
            /etc/systemd/system/
        print_success "Copied disable-pcie-wake.service"
    fi

    if [ -f "$DOTFILES_DIR/systemd/.config/systemd/system/nvidia-powerd.service.d/10-conditional.conf" ]; then
        sudo cp "$DOTFILES_DIR/systemd/.config/systemd/system/nvidia-powerd.service.d/10-conditional.conf" \
            /etc/systemd/system/nvidia-powerd.service.d/
        print_success "Copied nvidia-powerd conditional config"
    fi

    # Reload daemon
    sudo systemctl daemon-reload

    # Enable and start services
    for service in disable-usb-wake disable-pcie-wake; do
        if ! systemctl is-enabled "$service.service" &>/dev/null; then
            sudo systemctl enable "$service.service"
            print_success "Enabled $service.service"
        fi

        if ! systemctl is-active "$service.service" &>/dev/null; then
            sudo systemctl start "$service.service"
            print_success "Started $service.service"
        fi
    done
}

deploy_logind_config() {
    print_step "Deploying power-aware lid handling (requires sudo)..."

    local config_dest="/etc/systemd/logind.conf.d/10-power-aware-lid.conf"
    local config_src="$DOTFILES_DIR/systemd/.config/systemd/logind.conf.d/10-power-aware-lid.conf"

    # Check if already deployed
    if [ -f "$config_dest" ] && [ "$FORCE" != true ]; then
        print_skip "Lid handling already configured"
        return 0
    fi

    if [ ! -f "$config_src" ]; then
        print_error "Source config not found: $config_src"
        return 1
    fi

    echo ""
    print_info "This configures lid close behavior:"
    print_info "  • On battery: suspend immediately"
    print_info "  • On AC power: lock screen only"
    print_info "  • When docked: ignore"
    echo ""

    if ! ask_yn "Deploy lid handling configuration?" "y"; then
        print_skip "Skipped by user choice"
        return 0
    fi

    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo cp "$config_src" "$config_dest"
    print_success "Lid handling configured"

    echo ""
    print_step "Restarting systemd-logind..."
    sudo systemctl restart systemd-logind.service
    print_success "systemd-logind restarted"

    print_info "You may need to log out and back in for full effect"
}

deploy_hypridle() {
    print_step "Deploying hypridle configuration..."

    # Check if hypridle config is already present
    if [ -f "$HOME/.config/hypr/hypridle.conf" ]; then
        if grep -q "conditional-suspend.sh" "$HOME/.config/hypr/hypridle.conf"; then
            print_skip "Hypridle already configured with conditional suspend"
            return 0
        fi
    fi

    if [ ! -d "$DOTFILES_DIR/hyprland" ]; then
        print_skip "Hyprland module not found (not needed on this system?)"
        return 0
    fi

    echo ""
    if ask_yn "Deploy updated hypridle configuration via 'stow hyprland'?" "y"; then
        cd "$DOTFILES_DIR"
        if stow hyprland 2>&1; then
            print_success "Hypridle configuration deployed"

            # Restart hypridle if running
            if pgrep -x hypridle >/dev/null; then
                echo ""
                if ask_yn "Restart hypridle to apply changes?" "y"; then
                    killall hypridle 2>/dev/null || true
                    sleep 1
                    hypridle &>/dev/null &
                    print_success "Hypridle restarted"
                fi
            fi
        else
            print_skip "Failed to stow hyprland module"
            return 1
        fi
    else
        print_skip "Skipped by user choice"
    fi
}

deploy_user_services() {
    print_step "Checking user services..."

    local service="gpu-mode-monitor.service"
    local service_path="$HOME/.config/systemd/user/$service"

    # Deploy service file if needed
    if [ ! -f "$service_path" ]; then
        if [ -f "$DOTFILES_DIR/systemd/.config/systemd/user/$service" ]; then
            mkdir -p "$HOME/.config/systemd/user"
            cp "$DOTFILES_DIR/systemd/.config/systemd/user/$service" "$service_path"
            systemctl --user daemon-reload
            print_success "GPU mode monitor service file deployed"
        else
            print_skip "GPU mode monitor service not found (optional)"
            return 0
        fi
    fi

    # Check if already enabled
    if systemctl --user is-enabled "$service" &>/dev/null; then
        print_skip "GPU mode monitor already enabled"
        return 0
    fi

    # Check if supergfxctl is available
    if ! command -v supergfxctl &>/dev/null; then
        print_skip "GPU mode monitor skipped (no hybrid graphics)"
        return 0
    fi

    echo ""
    print_info "GPU mode monitor tracks GPU mode changes (Integrated/Hybrid/NVIDIA)"
    print_info "This is optional and mainly useful for debugging"
    echo ""

    if ask_yn "Enable GPU mode monitor?" "n"; then
        systemctl --user enable "$service"
        systemctl --user start "$service"
        print_success "GPU mode monitor enabled and started"
        print_info "Logs: \$XDG_RUNTIME_DIR/gpu-mode-monitor.log"
    else
        print_skip "Skipped by user choice"
    fi
}

deploy_bluetooth_power_management() {
    print_step "Deploying Bluetooth power management (requires sudo)..."

    # Check if already deployed
    local already_deployed=true
    if [ ! -f /etc/udev/rules.d/50-bluetooth-usb-disable-autosuspend.rules ]; then
        already_deployed=false
    fi
    if ! systemctl list-unit-files | grep -q "bluetooth-disable-usb-autosuspend.service"; then
        already_deployed=false
    fi

    if [ "$already_deployed" = true ] && [ "$FORCE" != true ]; then
        print_skip "Bluetooth power management already deployed"
        return 0
    fi

    echo ""
    print_info "This prevents random Bluetooth disconnections caused by USB autosuspend"
    print_info "Will deploy:"
    print_info "  • Udev rule to disable USB autosuspend for Bluetooth controllers"
    print_info "  • Systemd service to enforce power management settings"
    echo ""

    if ! ask_yn "Deploy Bluetooth power management?" "y"; then
        print_skip "Skipped by user choice"
        return 0
    fi

    # Deploy udev rule
    local udev_rule_src="$DOTFILES_DIR/udev/etc/udev/rules.d/50-bluetooth-usb-disable-autosuspend.rules"
    if [ -f "$udev_rule_src" ]; then
        sudo cp "$udev_rule_src" /etc/udev/rules.d/
        print_success "Udev rule deployed"

        # Reload udev rules
        sudo udevadm control --reload-rules
        sudo udevadm trigger --action=add --subsystem-match=usb
        print_success "Udev rules reloaded"
    else
        print_error "Udev rule not found: $udev_rule_src"
    fi

    # Deploy systemd service
    local service_src="$DOTFILES_DIR/systemd/.config/systemd/system/bluetooth-disable-usb-autosuspend.service"
    if [ -f "$service_src" ]; then
        sudo cp "$service_src" /etc/systemd/system/
        sudo systemctl daemon-reload
        print_success "Systemd service deployed"

        # Enable and start service
        sudo systemctl enable bluetooth-disable-usb-autosuspend.service
        sudo systemctl start bluetooth-disable-usb-autosuspend.service

        if systemctl is-active --quiet bluetooth-disable-usb-autosuspend.service; then
            print_success "Bluetooth power management service enabled and started"
        else
            print_error "Service failed to start"
            print_info "Check: sudo systemctl status bluetooth-disable-usb-autosuspend.service"
        fi
    else
        print_error "Service file not found: $service_src"
    fi
}

# ============================================================================
# Main Function
# ============================================================================

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Configure intelligent laptop power management for battery and AC operation"
    echo ""
    echo "Options:"
    echo "  --verify-only   Only run verification checks"
    echo "  --force         Force re-deployment of all components"
    echo "  --help          Show this help message"
    echo ""
    echo "Features:"
    echo "  • Power-aware suspend: only suspends on battery"
    echo "  • Prevents spurious wake-ups from USB/PCIe devices"
    echo "  • Smart lid handling based on power state"
    echo "  • GPU mode awareness for hybrid graphics"
    echo "  • Bluetooth power management: prevents random disconnections"
    echo ""
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verify-only)
                VERIFY_ONLY=true
                shift
                ;;
            --force)
                FORCE=true
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

    echo "⚡ Laptop Power Management Setup"
    echo ""

    # Verify this is a laptop
    if ! is_laptop && ! has_battery; then
        print_error "This does not appear to be a laptop"
        print_info "No laptop chassis type or battery detected"
        exit 1
    fi

    # Display system info
    local model=$(get_system_model)
    if is_razer_blade; then
        print_success "Detected Razer Blade: $model"
    else
        print_success "Detected laptop: $model"
    fi
    echo ""

    # If verify-only mode, run verification and exit
    if [ "$VERIFY_ONLY" = true ]; then
        run_verification
        exit $?
    fi

    # Check for required tools
    if ! command -v systemctl &>/dev/null; then
        print_error "systemctl not found - systemd required"
        exit 1
    fi

    if ! command -v stow &>/dev/null; then
        print_error "GNU Stow not found - required for deployment"
        print_info "Install with: sudo pacman -S stow"
        exit 1
    fi

    # Run deployment steps
    echo "This will configure power management for laptop use:"
    echo "  • Scripts for conditional suspend based on AC/battery"
    echo "  • System services to prevent spurious wake-ups"
    echo "  • Power-aware lid handling"
    echo "  • Updated hypridle configuration"
    echo "  • Bluetooth power management (prevents random disconnections)"
    echo ""

    if ! ask_yn "Continue with setup?" "y"; then
        echo "Setup cancelled"
        exit 0
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Step 1: Scripts"
    echo "═══════════════════════════════════════════════════════"
    deploy_scripts

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Step 2: System Services"
    echo "═══════════════════════════════════════════════════════"
    deploy_system_services

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Step 3: Bluetooth Power Management"
    echo "═══════════════════════════════════════════════════════"
    deploy_bluetooth_power_management

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Step 4: Lid Handling"
    echo "═══════════════════════════════════════════════════════"
    deploy_logind_config

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Step 5: Hypridle Configuration"
    echo "═══════════════════════════════════════════════════════"
    deploy_hypridle

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Step 6: Optional Services"
    echo "═══════════════════════════════════════════════════════"
    deploy_user_services

    # Final verification
    echo ""
    run_verification

    # Success summary
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  ✅ Power Management Setup Complete!"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    print_info "Behavior configured:"
    echo "  • Idle 20min on battery → suspend"
    echo "  • Idle 20min on AC → stay awake (lock screen)"
    echo "  • Close lid on battery → suspend"
    echo "  • Close lid on AC → lock screen only"
    echo "  • Bluetooth USB autosuspend disabled (prevents random disconnections)"
    echo ""
    print_info "Test with:"
    echo "  ~/.local/bin/conditional-suspend.sh"
    echo "  cat /sys/class/power_supply/AC0/online  # 1=AC, 0=battery"
    echo ""
    print_info "Check Bluetooth power management:"
    echo "  cat /sys/bus/usb/devices/*/power/control | grep -v auto"
    echo "  systemctl status bluetooth-disable-usb-autosuspend.service"
    echo ""
    print_info "Verify at any time:"
    echo "  $0 --verify-only"
    echo ""
}

# Run main function
main "$@"
