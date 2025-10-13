#!/usr/bin/env bash

#
# init_packages.sh - Check and install missing system packages
# Idempotent: Only installs packages that are missing
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

echo "📦 Checking system packages..."
echo ""

# Detect package manager
if command -v pacman &> /dev/null; then
    PM="pacman"
    print_success "Detected package manager: pacman"
else
    print_error "Package manager not found (only pacman/Arch supported)"
    echo "Skipping package installation"
    exit 0
fi

echo ""

# Package list directory
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$SETUP_DIR/install_packages"

if [ ! -d "$PKG_DIR" ]; then
    print_error "Package directory not found: $PKG_DIR"
    exit 1
fi

# Collect all packages from lists
PACKAGE_LISTS=("base" "dev" "audio" "gpu" "battery" "hyprland" "fonts")
ALL_PACKAGES=()
MISSING_PACKAGES=()

print_step "Reading package lists..."
echo ""

for list in "${PACKAGE_LISTS[@]}"; do
    list_file="$PKG_DIR/${list}.txt"

    if [ -f "$list_file" ]; then
        # Read packages from file (skip empty lines and comments)
        while IFS= read -r package; do
            # Skip empty lines and comments
            [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue
            # Trim whitespace
            package=$(echo "$package" | xargs)
            [ -n "$package" ] && ALL_PACKAGES+=("$package")
        done < "$list_file"

        count=$(grep -v '^[[:space:]]*$' "$list_file" | grep -v '^[[:space:]]*#' | wc -l)
        print_step "Found $count packages in $list.txt"
    fi
done

echo ""
print_step "Checking installed packages..."
echo ""

# Check which packages are missing
INSTALLED_COUNT=0
MISSING_COUNT=0

for package in "${ALL_PACKAGES[@]}"; do
    if pacman -Qi "$package" &> /dev/null; then
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        MISSING_PACKAGES+=("$package")
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

echo "Total packages in lists: ${#ALL_PACKAGES[@]}"
echo -e "${GREEN}Installed:${NC} $INSTALLED_COUNT"
echo -e "${YELLOW}Missing:${NC} $MISSING_COUNT"
echo ""

# If no missing packages, exit
if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    print_success "All packages are already installed!"
    exit 0
fi

# Show missing packages
print_step "Missing packages:"
for package in "${MISSING_PACKAGES[@]}"; do
    echo "  - $package"
done
echo ""

# Ask to install
read -p "$(echo -e ${BLUE}Install ${MISSING_COUNT} missing packages?${NC} [Y/n]: )" response
response=${response:-y}

if [[ ! "$response" =~ ^[Yy] ]]; then
    print_skip "Skipped by user"
    exit 0
fi

# Install missing packages
print_step "Installing missing packages..."
echo ""

# Use yay if available (for AUR packages), otherwise pacman
if command -v yay &> /dev/null; then
    print_step "Using yay (AUR helper)..."
    if yay -S --needed --noconfirm "${MISSING_PACKAGES[@]}"; then
        print_success "All packages installed successfully!"
    else
        print_error "Some packages failed to install"
        echo "You can install them manually later:"
        echo "  yay -S ${MISSING_PACKAGES[*]}"
    fi
else
    print_step "Using pacman..."
    if sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"; then
        print_success "All packages installed successfully!"
    else
        print_error "Some packages failed to install"
        echo "You can install them manually later:"
        echo "  sudo pacman -S ${MISSING_PACKAGES[*]}"
    fi
fi

echo ""
echo "✅ Package check complete"
echo ""
echo "Summary:"
echo "  Total: ${#ALL_PACKAGES[@]}"
echo "  Already installed: $INSTALLED_COUNT"
echo "  Newly installed: $MISSING_COUNT"
