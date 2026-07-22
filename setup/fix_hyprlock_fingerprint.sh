#!/usr/bin/env bash

#
# fix_hyprlock_fingerprint.sh - Fix fingerprint timeout for hyprlock
# Adds timeout and max-tries parameters to pam_fprintd.so
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

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "🔧 Fixing hyprlock fingerprint authentication..."
echo ""

PAM_FILE="/etc/pam.d/system-auth"

print_step "Current PAM configuration:"
grep "pam_fprintd" "$PAM_FILE"
echo ""

echo "The issue: pam_fprintd.so blocks password input for 30 seconds by default"
echo ""
echo "The fix: Add timeout=10 max-tries=1 for faster fallback"
echo "  - timeout=10: Fails after 10 seconds instead of 30"
echo "  - max-tries=1: Only one fingerprint attempt"
echo "  - Press ESC or wait 10s to use password"
echo ""

read -p "$(echo -e ${BLUE}Apply fix?${NC} [Y/n]: )" response
response=${response:-y}

if [[ ! "$response" =~ ^[Yy] ]]; then
    echo "Cancelled"
    exit 0
fi

# Create backup
print_step "Creating backup..."
sudo cp "$PAM_FILE" "$PAM_FILE.backup-hyprlock-$(date +%Y%m%d-%H%M%S)"
print_success "Backup created"

# Apply fix
print_step "Applying fix..."
sudo sed -i 's/^auth\s\+sufficient\s\+pam_fprintd\.so$/auth       sufficient  pam_fprintd.so timeout=10 max-tries=1/' "$PAM_FILE"

# Verify
echo ""
print_step "New PAM configuration:"
grep "pam_fprintd" "$PAM_FILE"
echo ""

if grep -q "pam_fprintd.so timeout=10 max-tries=1" "$PAM_FILE"; then
    print_success "Fix applied successfully!"
else
    print_error "Fix may not have been applied correctly"
    echo "Current line:"
    grep "pam_fprintd" "$PAM_FILE"
    exit 1
fi

echo ""
echo "✅ Configuration fixed!"
echo ""
echo "How it works now:"
echo "  1. Lock screen: hyprlock"
echo "  2. Touch fingerprint sensor → unlocks instantly"
echo "  3. Don't touch sensor → password prompt after 10 seconds"
echo "  4. Press ESC → password prompt immediately"
echo ""
echo "Test it:"
echo "  1. Lock your screen"
echo "  2. Try fingerprint authentication"
echo "  3. Try password authentication"
echo ""
