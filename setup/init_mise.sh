#!/usr/bin/env bash

#
# init_mise.sh - Install mise and its configured tools
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

echo "📦 Initializing mise (version manager)..."
echo ""

# ============================================================================
# Check if mise is installed
# ============================================================================

print_step "Checking mise installation..."

if ! command -v mise &> /dev/null; then
    print_error "mise not found in PATH"
    echo ""
    echo "To install mise:"
    echo "  curl https://mise.run | sh"
    echo "  # Or on Arch: sudo pacman -S mise"
    echo ""
    exit 1
fi

MISE_VERSION=$(mise --version | head -n1 || echo "unknown")
print_success "mise installed: $MISE_VERSION"

echo ""

# ============================================================================
# Check mise configuration
# ============================================================================

print_step "Checking mise configuration..."

MISE_CONFIG="$HOME/.config/mise/config.toml"

if [ ! -f "$MISE_CONFIG" ]; then
    print_skip "No mise config found (stow mise module first)"
    exit 0
fi

print_success "Found mise config: $MISE_CONFIG"

# Show configured tools
if grep -q "^\[tools\]" "$MISE_CONFIG"; then
    echo ""
    print_step "Configured tools:"
    grep -A 10 "^\[tools\]" "$MISE_CONFIG" | grep "^[a-z]" | sed 's/^/  /' || true
fi

echo ""

# ============================================================================
# Install mise tools
# ============================================================================

print_step "Checking installed mise tools..."

# Get list of configured tools
CONFIGURED_TOOLS=$(mise ls --current 2>/dev/null | awk '{print $1}' | sort -u || echo "")

if [ -z "$CONFIGURED_TOOLS" ]; then
    print_step "Installing mise tools (this may take a few minutes)..."
    echo ""

    if mise install 2>&1 | tee /tmp/mise_install.log; then
        print_success "All mise tools installed successfully"
    else
        print_error "Some tools failed to install (see /tmp/mise_install.log)"
        echo "   You can install them manually later with: mise install"
    fi
else
    print_skip "Tools already installed:"
    echo "$CONFIGURED_TOOLS" | sed 's/^/  /'

    # Check if any tools need updating
    print_step "Checking for outdated tools..."
    OUTDATED=$(mise outdated 2>/dev/null || echo "")

    if [ -n "$OUTDATED" ]; then
        echo ""
        echo "Outdated tools found:"
        echo "$OUTDATED" | sed 's/^/  /'
        echo ""
        echo "To update: mise upgrade"
    else
        print_success "All tools are up to date"
    fi
fi

echo ""

# ============================================================================
# Verify mise shims
# ============================================================================

print_step "Checking mise shims..."

MISE_SHIMS="$HOME/.local/share/mise/shims"

if [ -d "$MISE_SHIMS" ] && [ -n "$(ls -A "$MISE_SHIMS" 2>/dev/null)" ]; then
    SHIM_COUNT=$(ls "$MISE_SHIMS" | wc -l)
    print_success "Found $SHIM_COUNT shims in $MISE_SHIMS"
else
    print_step "Generating mise shims..."
    mise reshim 2>/dev/null || true
    print_success "Shims regenerated"
fi

echo ""

# ============================================================================
# Install Python build tools (for AUR package builds)
# ============================================================================

# Check if Python is managed by mise
if mise ls python &>/dev/null; then
    print_step "Installing Python build tools for AUR compatibility..."

    # Find all Python installations
    PYTHON_PATHS=$(find ~/.local/share/mise/installs/python/*/bin/python -type f 2>/dev/null || true)

    if [ -n "$PYTHON_PATHS" ]; then
        for python_bin in $PYTHON_PATHS; do
            # Check if build module is already installed
            if ! $python_bin -m build --version &>/dev/null; then
                print_step "Installing build module for: $python_bin"
                $python_bin -m pip install --quiet build 2>/dev/null || true
            fi
        done
        print_success "Python build tools verified"
    fi
fi

echo ""
echo "✅ Mise initialization complete"
echo ""
echo "Installed tools:"
mise ls --current 2>/dev/null | sed 's/^/  /' || echo "  (none)"
echo ""
echo "To manage mise:"
echo "  mise install <tool>       # Install a specific tool"
echo "  mise use <tool@version>   # Set tool version"
echo "  mise upgrade              # Update all tools"
echo "  mise doctor               # Check for issues"
