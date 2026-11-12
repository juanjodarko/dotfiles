#!/usr/bin/env bash

#
# init_plugins.sh - Auto-install plugins for Neovim and Tmux
# Idempotent: Safe to run multiple times
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

echo "🔌 Initializing plugin systems..."
echo ""

# Clone with retries; never aborts the script (set -e), so one network blip
# can't skip the plugin sections after it.
git_clone() {
    local i
    for i in 1 2 3; do
        git clone -q "$@" && return 0
        sleep $((i * 3))
    done
    return 1
}

# ============================================================================
# Tmux Plugin Manager (TPM)
# ============================================================================

print_step "Checking Tmux Plugin Manager (TPM)..."

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
    print_skip "TPM already installed at $TPM_DIR"
else
    print_step "Installing TPM..."
    if git_clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
        print_success "TPM installed successfully"
        echo "   Run 'tmux' and press Prefix + I to install plugins"
    else
        print_error "Failed to clone TPM (re-run setup later)"
    fi
fi

echo ""

# ============================================================================
# Neovim Plugins (Lazy.nvim)
# ============================================================================

print_step "Checking Neovim plugins..."

NVIM_DATA_DIR="$HOME/.local/share/nvim/lazy"
NVIM_CONFIG="$HOME/.config/nvim"

if [ ! -d "$NVIM_CONFIG" ]; then
    print_skip "Neovim config not found (stow nvim module first)"
elif [ ! -f "$NVIM_CONFIG/lazy-lock.json" ]; then
    print_skip "No lazy-lock.json found, plugins will install on first nvim launch"
elif [ -d "$NVIM_DATA_DIR" ] && [ "$(ls -A "$NVIM_DATA_DIR" 2>/dev/null | wc -l)" -gt 5 ]; then
    print_skip "Neovim plugins already installed ($(ls -A "$NVIM_DATA_DIR" | wc -l) plugins)"
else
    if command -v nvim &> /dev/null; then
        print_step "Installing Neovim plugins (this may take a minute)..."

        # Run Lazy sync in headless mode
        if nvim --headless "+Lazy! sync" +qa 2>&1 | tee /tmp/nvim_plugin_install.log; then
            print_success "Neovim plugins installed successfully"
        else
            print_error "Neovim plugin installation had warnings (see /tmp/nvim_plugin_install.log)"
            print_step "Plugins will complete installation when you first open nvim"
        fi
    else
        print_error "nvim command not found, install Neovim first"
    fi
fi

echo ""

# ============================================================================
# Mason (LSP/DAP/Linters)
# ============================================================================

print_step "Checking Mason installations..."

MASON_DIR="$HOME/.local/share/nvim/mason"

if [ ! -d "$MASON_DIR" ]; then
    print_skip "Mason not initialized, will install on first nvim launch"
elif [ "$(find "$MASON_DIR/packages" -maxdepth 1 -type d 2>/dev/null | wc -l)" -gt 5 ]; then
    installed_count=$(find "$MASON_DIR/packages" -maxdepth 1 -type d | tail -n +2 | wc -l)
    print_skip "Mason packages already installed ($installed_count packages)"
else
    print_skip "Mason will install language servers when needed"
    echo "   Open Neovim and run :Mason to see available servers"
fi

# ============================================================================
# Hyprland Lua plugins (hyprland.lua require()s them; clones are gitignored)
# ============================================================================

echo ""
print_step "Checking Hyprland plugins..."

if ! command -v Hyprland &> /dev/null; then
    print_skip "Hyprland not installed, skipping its plugins"
else
    HYPR_PLUGIN_DIR="$HOME/.config/hypr/plugins/split-monitor-workspaces"
    HYPR_PLUGIN_URL="https://github.com/zjeffer/split-monitor-workspaces"
    # Plugin branches track Hyprland minor releases (release/0.57.x for 0.57.*)
    hypr_ver=$(Hyprland --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    want_branch="release/${hypr_ver%.*}.x"
    if ! git ls-remote --exit-code --heads "$HYPR_PLUGIN_URL" "$want_branch" &> /dev/null; then
        print_error "No $want_branch branch for Hyprland $hypr_ver; using main"
        want_branch="main"
    fi

    if [ -d "$HYPR_PLUGIN_DIR/.git" ]; then
        current_branch=$(git -C "$HYPR_PLUGIN_DIR" rev-parse --abbrev-ref HEAD)
        if [ "$current_branch" = "$want_branch" ]; then
            print_skip "split-monitor-workspaces already on $want_branch"
        else
            git -C "$HYPR_PLUGIN_DIR" fetch -q origin "$want_branch" &&
                git -C "$HYPR_PLUGIN_DIR" switch -q -C "$want_branch" "origin/$want_branch" &&
                print_success "split-monitor-workspaces switched to $want_branch" ||
                print_error "Could not switch split-monitor-workspaces to $want_branch"
        fi
    else
        mkdir -p "$(dirname "$HYPR_PLUGIN_DIR")"
        if git_clone -b "$want_branch" "$HYPR_PLUGIN_URL" "$HYPR_PLUGIN_DIR"; then
            print_success "split-monitor-workspaces cloned ($want_branch)"
        else
            print_error "Failed to clone split-monitor-workspaces"
        fi
    fi
fi

echo ""
echo "✅ Plugin initialization complete"
echo ""
echo "Next steps:"
echo "  1. Open tmux and press Prefix + I to install tmux plugins (if needed)"
echo "  2. Open Neovim - plugins will finish installing automatically"
echo "  3. In Neovim, run :Mason to install language servers"
