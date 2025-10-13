#!/usr/bin/env bash

#
# verify.sh - Verify dotfiles installation and configuration health
# Checks: commands, configs, stow links, themes, plugins, services
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA} $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

check_cmd() {
    local cmd="$1"
    local name="${2:-$cmd}"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n1 | cut -d' ' -f1-3 || echo "")
        print_success "$name: $(command -v $cmd) $version"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        print_error "$name not found"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

check_file() {
    local file="$1"
    local name="${2:-$file}"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -e "$file" ]; then
        if [ -L "$file" ]; then
            local target=$(readlink "$file")
            print_success "$name → $target"
        else
            print_success "$name exists"
        fi
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        print_warning "$name not found"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
        return 1
    fi
}

check_dir() {
    local dir="$1"
    local name="${2:-$dir}"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ -d "$dir" ]; then
        local count=$(ls -A "$dir" 2>/dev/null | wc -l)
        print_success "$name ($count items)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        print_warning "$name not found"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
        return 1
    fi
}

echo ""
print_header "🔍 Dotfiles Health Check"
echo ""

# ============================================================================
# Core Tools
# ============================================================================

print_header "Core Tools"
echo ""

check_cmd stow "GNU Stow"
check_cmd git "Git"
check_cmd zsh "ZSH"
check_cmd nvim "Neovim"
check_cmd tmux "Tmux"

echo ""

# ============================================================================
# Shell Tools
# ============================================================================

print_header "Shell Tools"
echo ""

check_cmd starship "Starship Prompt"
check_cmd fzf "FZF"
check_cmd rg "Ripgrep"
check_cmd fd "fd"
check_cmd bat "bat"
check_cmd eza "eza"
check_cmd zoxide "zoxide"
check_cmd mise "mise"

echo ""

# ============================================================================
# Hyprland Desktop (if installed)
# ============================================================================

if command -v Hyprland &> /dev/null || command -v hyprland &> /dev/null; then
    print_header "Hyprland Desktop"
    echo ""

    check_cmd Hyprland "Hyprland" || check_cmd hyprland "Hyprland"
    check_cmd waybar "Waybar"
    check_cmd rofi "Rofi"
    check_cmd wofi "Wofi"
    check_cmd swaync "SwayNC"
    check_cmd hyprlock "Hyprlock"
    check_cmd hypridle "Hypridle"
    check_cmd hyprpaper "Hyprpaper"

    echo ""
fi

# ============================================================================
# Configuration Files
# ============================================================================

print_header "Configuration Files"
echo ""

check_file "$HOME/.zshrc" "ZSH config"
check_file "$HOME/.config/nvim/init.lua" "Neovim config"
check_file "$HOME/.config/tmux/tmux.conf" "Tmux config"
check_file "$HOME/.config/starship.toml" "Starship config"
check_file "$HOME/.gitconfig" "Git config"

if [ -d "$HOME/.config/hypr" ]; then
    check_file "$HOME/.config/hypr/hyprland.conf" "Hyprland config"
    check_file "$HOME/.config/waybar/config.jsonc" "Waybar config"
fi

echo ""

# ============================================================================
# Theme System
# ============================================================================

print_header "Theme System"
echo ""

check_file "$HOME/.config/themes/current.css" "Current CSS theme"
check_file "$HOME/.config/themes/current.rasi" "Current Rofi theme"
check_file "$HOME/.config/themes/current.ghostty" "Current Ghostty theme"
check_file "$HOME/.config/themes/current.tmux" "Current Tmux theme"
check_file "$HOME/.config/themes/current.starship" "Current Starship theme"
check_file "$HOME/.config/themes/current_flavor.txt" "Current flavor"

if [ -f "$HOME/.config/themes/current_flavor.txt" ]; then
    FLAVOR=$(cat "$HOME/.config/themes/current_flavor.txt" 2>/dev/null | tr -d '\n')
    print_info "Active theme: $FLAVOR"
fi

echo ""

# ============================================================================
# Plugins & Tools
# ============================================================================

print_header "Plugins & Tools"
echo ""

check_dir "$HOME/.config/tmux/plugins/tpm" "Tmux Plugin Manager"
check_dir "$HOME/.local/share/nvim/lazy" "Neovim plugins"
check_dir "$HOME/.local/share/nvim/mason" "Mason (LSP servers)"

if command -v mise &> /dev/null; then
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    MISE_TOOLS=$(mise ls --current 2>/dev/null | wc -l || echo "0")
    if [ "$MISE_TOOLS" -gt 0 ]; then
        print_success "Mise tools installed: $MISE_TOOLS"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_warning "No mise tools installed"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
fi

echo ""

# ============================================================================
# Services
# ============================================================================

if command -v systemctl &> /dev/null; then
    print_header "Systemd Services"
    echo ""

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if systemctl --user is-active mastodon-notifications.service &>/dev/null; then
        print_success "Mastodon notifications: active"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif systemctl --user is-enabled mastodon-notifications.service &>/dev/null; then
        print_warning "Mastodon notifications: enabled but not running"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    else
        print_info "Mastodon notifications: not enabled"
        TOTAL_CHECKS=$((TOTAL_CHECKS - 1))
    fi

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if systemctl --user is-active battery-guard.service &>/dev/null; then
        print_success "Battery guard: active"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif systemctl --user is-enabled battery-guard.service &>/dev/null; then
        print_warning "Battery guard: enabled but not running"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    else
        print_info "Battery guard: not enabled"
        TOTAL_CHECKS=$((TOTAL_CHECKS - 1))
    fi

    echo ""
fi

# ============================================================================
# Neovim Health
# ============================================================================

if command -v nvim &> /dev/null && [ -f "$HOME/.config/nvim/init.lua" ]; then
    print_header "Neovim Health"
    echo ""

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if nvim --version | grep -q "NVIM v0\.[0-9]"; then
        NVIM_VERSION=$(nvim --version | head -n1)
        print_success "$NVIM_VERSION"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_error "Neovim version check failed"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    # Check if Neovim config is valid
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if nvim --headless +qa 2>/dev/null; then
        print_success "Neovim config loads without errors"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        print_error "Neovim config has errors"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi

    echo ""
fi

# ============================================================================
# Summary
# ============================================================================

print_header "Summary"
echo ""

PASS_RATE=0
if [ $TOTAL_CHECKS -gt 0 ]; then
    PASS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
fi

echo "Total checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed:${NC}       $PASSED_CHECKS"
if [ $WARNING_CHECKS -gt 0 ]; then
    echo -e "${YELLOW}Warnings:${NC}     $WARNING_CHECKS"
fi
if [ $FAILED_CHECKS -gt 0 ]; then
    echo -e "${RED}Failed:${NC}       $FAILED_CHECKS"
fi
echo ""

if [ $FAILED_CHECKS -eq 0 ] && [ $WARNING_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! ($PASS_RATE%)${NC}"
    echo ""
    exit 0
elif [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Some optional components missing ($PASS_RATE%)${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some critical components missing ($PASS_RATE%)${NC}"
    echo ""
    echo "Run setup scripts to fix issues:"
    echo "  ./setup/setup.sh"
    echo ""
    exit 1
fi
