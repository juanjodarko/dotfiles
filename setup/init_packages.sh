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

# Detect system type (laptop vs desktop)
IS_LAPTOP=false

print_step "Detecting system type..."

# Check for battery (most reliable laptop indicator)
if ls /sys/class/power_supply/BAT* &> /dev/null; then
    IS_LAPTOP=true
    print_success "Detected: Laptop (battery found)"
elif [ -d /sys/class/power_supply/AC ] || [ -d /sys/class/power_supply/ADP* ]; then
    # Has AC adapter, likely laptop
    IS_LAPTOP=true
    print_success "Detected: Laptop (AC adapter found)"
else
    # No battery detected, ask user
    echo -e "${YELLOW}Could not auto-detect system type${NC}"
    read -p "$(echo -e ${BLUE}Is this a laptop?${NC} [y/N]: )" response
    response=${response:-n}
    if [[ "$response" =~ ^[Yy] ]]; then
        IS_LAPTOP=true
        print_success "User selected: Laptop"
    else
        print_success "User selected: Desktop"
    fi
fi

echo ""

# Build package list based on system type
PACKAGE_LISTS=("base" "dev" "audio" "hyprland" "fonts")

# Add laptop-specific packages
if [ "$IS_LAPTOP" = true ]; then
    PACKAGE_LISTS+=("laptop")
    print_step "Including laptop-specific packages"
else
    print_step "Skipping laptop-specific packages (desktop system)"
fi

# Check for conflicting audio packages (PulseAudio vs PipeWire)
print_step "Checking for conflicting audio packages..."

CONFLICTING_PACKAGES=()
SAFE_PA_TOOLS=("pavucontrol" "pavucontrol-qt" "pulsemixer" "pamixer" "paprefs")

# Check for PulseAudio packages (exclude safe control tools)
while IFS= read -r pkg; do
    pkg_name=$(echo "$pkg" | awk '{print $1}')
    # Skip if it's a safe PA tool
    if [[ " ${SAFE_PA_TOOLS[@]} " =~ " ${pkg_name} " ]]; then
        continue
    fi
    # Check if it's a PulseAudio package
    if [[ "$pkg_name" =~ ^pulseaudio ]]; then
        CONFLICTING_PACKAGES+=("$pkg_name")
    fi
done < <(pacman -Q 2>/dev/null | grep -E '^pulseaudio' || true)

# Check for razer-nari-pulseaudio-profile specifically
if pacman -Qi razer-nari-pulseaudio-profile &> /dev/null; then
    CONFLICTING_PACKAGES+=("razer-nari-pulseaudio-profile")
fi

# If conflicts found, offer to remove them
if [ ${#CONFLICTING_PACKAGES[@]} -gt 0 ]; then
    echo ""
    print_error "Found ${#CONFLICTING_PACKAGES[@]} conflicting PulseAudio packages:"
    for pkg in "${CONFLICTING_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    echo -e "${YELLOW}These packages conflict with PipeWire and should be removed.${NC}"
    echo ""

    read -p "$(echo -e ${BLUE}Remove conflicting packages?${NC} [Y/n]: )" response
    response=${response:-y}

    if [[ "$response" =~ ^[Yy] ]]; then
        print_step "Removing conflicting packages..."
        if sudo pacman -Rns --noconfirm "${CONFLICTING_PACKAGES[@]}"; then
            print_success "Conflicting packages removed successfully"
        else
            print_error "Failed to remove some packages"
            echo "You may need to remove them manually:"
            echo "  sudo pacman -Rns ${CONFLICTING_PACKAGES[*]}"
        fi
    else
        print_skip "Keeping conflicting packages (may cause audio issues)"
    fi
    echo ""
else
    print_success "No conflicting PulseAudio packages found"
fi

echo ""

# Detect GPU configuration
print_step "Detecting GPU configuration..."

GPU_OUTPUT=$(lspci -nn 2>/dev/null | grep -iE '(vga|3d|display)' || true)
GPU_COUNT=$(echo "$GPU_OUTPUT" | grep -c . || echo "0")

HAS_INTEL=false
HAS_AMD=false
HAS_NVIDIA=false
IS_HYBRID=false

# Detect GPU vendors
if echo "$GPU_OUTPUT" | grep -iq 'intel'; then
    HAS_INTEL=true
fi
if echo "$GPU_OUTPUT" | grep -iq 'amd\|ati\|radeon'; then
    HAS_AMD=true
fi
if echo "$GPU_OUTPUT" | grep -iq 'nvidia'; then
    HAS_NVIDIA=true
fi

# Check for hybrid setup (iGPU + NVIDIA dGPU)
# Also check if supergfxctl is installed and reports a vendor
if command -v supergfxctl &> /dev/null; then
    DGPU_VENDOR=$(supergfxctl --vendor 2>/dev/null || true)
    if [[ -n "$DGPU_VENDOR" ]]; then
        if [[ "$DGPU_VENDOR" =~ "Nvidia" ]]; then
            HAS_NVIDIA=true
            IS_HYBRID=true
        fi
    fi
fi

# Determine if hybrid (Intel/AMD iGPU + NVIDIA dGPU)
if [[ "$IS_HYBRID" == false ]]; then
    if [[ "$HAS_NVIDIA" == true ]] && [[ "$HAS_INTEL" == true || "$HAS_AMD" == true ]]; then
        IS_HYBRID=true
    fi
fi

# Display detection results
echo ""
if [ "$GPU_COUNT" -eq 0 ]; then
    print_skip "No GPU detected or lspci unavailable"
    echo ""
else
    if [ "$IS_HYBRID" == true ]; then
        print_success "Detected: Hybrid GPU system"
        if [ "$HAS_INTEL" == true ]; then
            echo "  - Intel integrated GPU (iGPU)"
        elif [ "$HAS_AMD" == true ]; then
            echo "  - AMD integrated GPU (iGPU)"
        fi
        echo "  - NVIDIA dedicated GPU (dGPU)"
        echo ""
        echo "Hybrid GPUs will be managed by supergfxctl"
        echo ""

        read -p "$(echo -e ${BLUE}Install packages for hybrid GPU system?${NC} [Y/n]: )" response
        response=${response:-y}

        if [[ "$response" =~ ^[Yy] ]]; then
            PACKAGE_LISTS+=("gpu-base")
            PACKAGE_LISTS+=("gpu-nvidia")
            if [ "$HAS_INTEL" == true ]; then
                PACKAGE_LISTS+=("gpu-intel")
            elif [ "$HAS_AMD" == true ]; then
                PACKAGE_LISTS+=("gpu-amd")
            fi
            PACKAGE_LISTS+=("gpu-hybrid")
        fi
    else
        # Single GPU system
        if [ "$HAS_NVIDIA" == true ]; then
            print_success "Detected: NVIDIA GPU"
        elif [ "$HAS_AMD" == true ]; then
            print_success "Detected: AMD/ATI GPU"
        elif [ "$HAS_INTEL" == true ]; then
            print_success "Detected: Intel GPU"
        else
            print_step "Detected: Unknown GPU"
        fi
        echo ""

        read -p "$(echo -e ${BLUE}Install GPU packages?${NC} [Y/n]: )" response
        response=${response:-y}

        if [[ "$response" =~ ^[Yy] ]]; then
            PACKAGE_LISTS+=("gpu-base")
            if [ "$HAS_NVIDIA" == true ]; then
                PACKAGE_LISTS+=("gpu-nvidia")
            fi
            if [ "$HAS_AMD" == true ]; then
                PACKAGE_LISTS+=("gpu-amd")
            fi
            if [ "$HAS_INTEL" == true ]; then
                PACKAGE_LISTS+=("gpu-intel")
            fi
        fi
    fi
fi

echo ""

ALL_PACKAGES=()
MISSING_PACKAGES=()

echo ""
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

# Temporarily modify PATH to use system Python for AUR builds
# This prevents issues with mise/asdf Python installations that may lack build tools
ORIGINAL_PATH="$PATH"
export PATH="/usr/bin:/usr/local/bin:$PATH"

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

# Restore original PATH
export PATH="$ORIGINAL_PATH"

echo ""
echo "✅ Package check complete"
echo ""
echo "Summary:"
echo "  Total: ${#ALL_PACKAGES[@]}"
echo "  Already installed: $INSTALLED_COUNT"
echo "  Newly installed: $MISSING_COUNT"
