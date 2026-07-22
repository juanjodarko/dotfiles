#!/usr/bin/env bash

#
# disable_fingerprint_pam.sh - Temporarily disable fingerprint PAM
# Fixes 10-second password delay while we debug the CS9711 driver
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

echo "🔧 Disabling fingerprint PAM..."
echo ""

PAM_FILE="/etc/pam.d/system-auth"

print_step "Current configuration:"
grep "pam_fprintd" "$PAM_FILE" || echo "  (already disabled)"
echo ""

# Create backup
print_step "Creating backup..."
sudo cp "$PAM_FILE" "$PAM_FILE.backup-disable-fp-$(date +%Y%m%d-%H%M%S)"
print_success "Backup created"

# Comment out the line
print_step "Disabling fingerprint PAM..."
sudo sed -i 's/^auth\s\+sufficient\s\+pam_fprintd\.so/#auth       sufficient  pam_fprintd.so/' "$PAM_FILE"

echo ""
print_step "New configuration:"
grep "pam_fprintd" "$PAM_FILE" || echo "  (disabled)"
echo ""

print_success "Fingerprint PAM disabled"
echo ""
echo "Password authentication will now work immediately!"
echo ""
echo "To re-enable later, uncomment the line in $PAM_FILE"
echo ""
