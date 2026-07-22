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

# ============================================================================
# Tmux Plugin Manager (TPM)
# ============================================================================

print_step "Checking Tmux Plugin Manager (TPM)..."

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
    print_skip "TPM already installed at $TPM_DIR"
else
    print_step "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    print_success "TPM installed successfully"
    echo "   Run 'tmux' and press Prefix + I to install plugins"
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

echo ""
echo "✅ Plugin initialization complete"
echo ""
echo "Next steps:"
echo "  1. Open tmux and press Prefix + I to install tmux plugins (if needed)"
echo "  2. Open Neovim - plugins will finish installing automatically"
echo "  3. In Neovim, run :Mason to install language servers"
