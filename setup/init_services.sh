#!/usr/bin/env bash

#
# init_services.sh - Enable and start systemd user services
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

echo "🔧 Initializing systemd user services..."
echo ""

if ! command -v systemctl &> /dev/null; then
    print_error "systemctl not found, skipping service initialization"
    exit 0
fi

# Reload systemd user daemon
systemctl --user daemon-reload 2>/dev/null || true

# ============================================================================
# Mastodon Notifications Service
# ============================================================================

MASTODON_SERVICE="mastodon-notifications.service"
MASTODON_SERVICE_PATH="$HOME/.config/systemd/user/$MASTODON_SERVICE"

print_step "Checking $MASTODON_SERVICE..."

if [ ! -f "$MASTODON_SERVICE_PATH" ]; then
    print_skip "Service file not found (stow toot module first)"
elif systemctl --user is-enabled "$MASTODON_SERVICE" &>/dev/null; then
    if systemctl --user is-active "$MASTODON_SERVICE" &>/dev/null; then
        print_skip "Already enabled and running"
    else
        print_step "Service enabled but not running, starting..."
        systemctl --user start "$MASTODON_SERVICE"
        print_success "Service started"
    fi
else
    echo ""
    if ask_yn "Enable Mastodon notification daemon?" "n"; then
        systemctl --user enable "$MASTODON_SERVICE"
        systemctl --user start "$MASTODON_SERVICE"
        print_success "Service enabled and started"
        echo "   Notifications will appear when you have new Mastodon activity"
    else
        print_skip "Skipped by user choice"
        echo "   To enable later: systemctl --user enable --now $MASTODON_SERVICE"
    fi
fi

echo ""

# ============================================================================
# Battery Guard Service
# ============================================================================

BATTERY_SERVICE="battery-guard.service"
BATTERY_SERVICE_PATH="$HOME/.config/systemd/user/$BATTERY_SERVICE"

print_step "Checking $BATTERY_SERVICE..."

if [ ! -f "$BATTERY_SERVICE_PATH" ]; then
    print_skip "Service file not found (stow personal module first)"
elif systemctl --user is-enabled "$BATTERY_SERVICE" &>/dev/null; then
    if systemctl --user is-active "$BATTERY_SERVICE" &>/dev/null; then
        print_skip "Already enabled and running"
    else
        print_step "Service enabled but not running, starting..."
        systemctl --user start "$BATTERY_SERVICE"
        print_success "Service started"
    fi
else
    echo ""
    if ask_yn "Enable battery guard service?" "n"; then
        systemctl --user enable "$BATTERY_SERVICE"
        systemctl --user start "$BATTERY_SERVICE"
        print_success "Service enabled and started"
        echo "   Battery notifications will now be active"
    else
        print_skip "Skipped by user choice"
        echo "   To enable later: systemctl --user enable --now $BATTERY_SERVICE"
    fi
fi

echo ""
echo "✅ Service initialization complete"
echo ""
echo "To check service status:"
echo "  systemctl --user status $MASTODON_SERVICE"
echo "  systemctl --user status $BATTERY_SERVICE"
