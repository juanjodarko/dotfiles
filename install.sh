#!/bin/bash
#
# Dotfiles Bootstrap Installation Script
# Automatically detects OS, installs dependencies, backs up configs, and deploys dotfiles
#
# Usage:
#   ./install.sh              # Interactive full installation
#   ./install.sh --minimal    # Install only core modules
#   ./install.sh --no-backup  # Skip backup step
#   ./install.sh --help       # Show help

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emoji support
CHECK="✓"
CROSS="✗"
ARROW="→"
STAR="⭐"

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Flags
MINIMAL_INSTALL=false
NO_BACKUP=false
INTERACTIVE=true
MIGRATE_MODE=false
LAYERS=""

#==============================================================================
# Helper Functions
#==============================================================================

print_header() {
    echo ""
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  ${CYAN}Dotfiles Installation Script${NC}                         ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}  Professional Arch Linux Development Environment         ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}${ARROW}${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}${CHECK}${NC} ${1}"
}

print_error() {
    echo -e "${RED}${CROSS}${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}!${NC} ${1}"
}

ask_yn() {
    local prompt="$1"
    local default="${2:-y}"

    if [ "$INTERACTIVE" = false ]; then
        [ "$default" = "y" ] && return 0 || return 1
    fi

    while true; do
        if [ "$default" = "y" ]; then
            read -p "$(echo -e ${CYAN}${prompt}${NC} [Y/n]: )" yn
            yn=${yn:-y}
        else
            read -p "$(echo -e ${CYAN}${prompt}${NC} [y/N]: )" yn
            yn=${yn:-n}
        fi

        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==============================================================================
# Migration Mode - Safe Conflict Detection
#==============================================================================

check_stow_conflicts() {
    local module="$1"
    local conflicts=()

    # Run stow in simulation mode to detect conflicts
    cd "$DOTFILES_DIR"

    # Capture stow output
    local stow_output=$(stow -n -v "$module" 2>&1)

    # Parse conflicts from stow output
    while IFS= read -r line; do
        if [[ "$line" == *"existing target is"* ]] || [[ "$line" == *"conflicts"* ]]; then
            # Extract the file path from the error message
            local file=$(echo "$line" | grep -oP '(?<=: ).*?(?= )' | head -1)
            [ -n "$file" ] && conflicts+=("$file")
        fi
    done <<< "$stow_output"

    # Return number of conflicts
    echo "${#conflicts[@]}"

    # Store conflicts in global array for access
    CURRENT_CONFLICTS=("${conflicts[@]}")
}

migrate_deploy_module() {
    local module="$1"

    if [ ! -d "$module" ]; then
        print_warning "Module $module not found, skipping"
        return 1
    fi

    print_step "Checking $module for conflicts..."

    # Check for conflicts
    local conflict_count=$(check_stow_conflicts "$module")

    if [ "$conflict_count" -eq 0 ]; then
        # No conflicts, deploy directly
        if stow -R "$module" 2>&1; then
            print_success "$module deployed (no conflicts)"
            return 0
        else
            print_error "Failed to deploy $module"
            return 1
        fi
    else
        # Conflicts detected
        print_warning "Found $conflict_count conflicting file(s) in $module"

        # List conflicting files
        for conflict in "${CURRENT_CONFLICTS[@]}"; do
            echo "  - $conflict"
        done
        echo ""

        echo "Options:"
        echo "  1. Backup existing and deploy dotfiles (recommended)"
        echo "  2. Skip this module"
        echo "  3. Abort installation"
        echo ""

        read -p "$(echo -e ${CYAN}Choice [1]:${NC} )" choice
        choice=${choice:-1}

        case $choice in
            1)
                # Backup conflicting files
                print_step "Backing up conflicting files from $module..."

                for conflict in "${CURRENT_CONFLICTS[@]}"; do
                    local source="$HOME/$conflict"
                    local dest="$BACKUP_DIR/$conflict"

                    if [ -e "$source" ] && [ ! -L "$source" ]; then
                        mkdir -p "$(dirname "$dest")"
                        cp -r "$source" "$dest" 2>/dev/null || true
                        rm -rf "$source"
                        print_success "Backed up: $conflict"
                    fi
                done

                # Now deploy with stow
                if stow -R "$module" 2>&1; then
                    print_success "$module deployed successfully"
                    return 0
                else
                    print_error "Failed to deploy $module after backup"
                    return 1
                fi
                ;;
            2)
                print_warning "Skipped $module"
                return 0
                ;;
            3)
                print_error "Installation aborted by user"
                exit 1
                ;;
            *)
                print_error "Invalid choice"
                return 1
                ;;
        esac
    fi
}

# Directories several modules stow into must exist as real dirs first.
# Otherwise, on a fresh home, stow "folds" them into a single module's symlink
# (e.g. ~/.local/share -> dotfiles/personal/.local/share) and every app's data
# ends up inside the repo.
ensure_shared_dirs() {
    local d
    for d in "$HOME/.config" "$HOME/.config/systemd/user" "$HOME/.local/bin" \
             "$HOME/.local/share" "$HOME/.local/share/applications" "$HOME/.local/state" \
             "$HOME/.config/toot"; do   # toot writes config.json (Mastodon token!) next to its stowed settings
        [ -L "$d" ] && print_warning "$d is a symlink (folded by an earlier stow) — fix by hand"
        mkdir -p "$d"
    done
}

migrate_deploy_dotfiles() {
    print_step "Deploying dotfiles with safe migration..."
    echo ""

    cd "$DOTFILES_DIR"
    ensure_shared_dirs

    local deployed=0
    local skipped=0
    local failed=0

    for module in "${MODULES[@]}"; do
        echo ""
        if migrate_deploy_module "$module"; then
            deployed=$((deployed + 1))
        else
            if [ $? -eq 0 ]; then
                skipped=$((skipped + 1))
            else
                failed=$((failed + 1))
            fi
        fi
    done

    echo ""
    print_success "Migration summary: $deployed deployed, $skipped skipped, $failed failed"

    if [ $failed -gt 0 ]; then
        print_warning "Some modules failed to deploy"
        if ! ask_yn "Continue anyway?" "y"; then
            exit 1
        fi
    fi
}

#==============================================================================
# OS Detection
#==============================================================================

detect_os() {
    print_step "Detecting operating system..."

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif [ "$(uname)" = "Darwin" ]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion)
    else
        print_error "Unable to detect operating system"
        exit 1
    fi

    print_success "Detected: $OS $OS_VERSION"
}

#==============================================================================
# Dependency Installation
#==============================================================================

# Package layers live in packages/<layer>.txt (one name per line; "# aur" marks
# AUR packages). Default: base desktop apps dev, plus hardware-<hostname> when
# such a file exists. Override with --layers base,desktop,...
default_layers() {
    local host layers="base desktop apps dev"
    host="$(cat /etc/hostname 2>/dev/null || hostnamectl --static 2>/dev/null || hostname)"
    host="${host,,}"
    [ -f "$DOTFILES_DIR/packages/hardware-$host.txt" ] && layers="$layers hardware-$host"
    echo "$layers"
}

# $1 = layer, $2 = official|aur
layer_packages() {
    local file="$DOTFILES_DIR/packages/$1.txt"
    [ -f "$file" ] || { print_warning "No package layer: $file"; return; }
    if [ "$2" = aur ]; then
        grep -vE '^[[:space:]]*(#|$)' "$file" | grep -E '#[[:space:]]*aur' | awk '{print $1}'
    else
        grep -vE '^[[:space:]]*(#|$)' "$file" | grep -vE '#[[:space:]]*aur' | awk '{print $1}'
    fi
}

enable_multilib() {
    grep -q '^\[multilib\]' /etc/pacman.conf && return
    print_step "Enabling the [multilib] repository (steam, lib32-*)..."
    sudo sed -i '/^#\[multilib\]$/,/^#Include/ s/^#//' /etc/pacman.conf
}

ensure_yay() {
    command -v yay &> /dev/null && return 0
    print_step "Bootstrapping yay (AUR helper)..."
    local tmp; tmp="$(mktemp -d)"
    if git clone -q https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" &&
       (cd "$tmp/yay-bin" && makepkg -si --noconfirm); then
        print_success "yay installed"
    else
        print_error "Could not install yay; AUR packages will be skipped"
    fi
    rm -rf "$tmp"
    command -v yay &> /dev/null
}

install_arch_deps() {
    local layers=${LAYERS:-$(default_layers)}
    [ "$MINIMAL_INSTALL" = true ] && layers="base"
    layers="${layers//,/ }"
    print_step "Installing Arch Linux packages (layers: $layers)..."

    local official=() aur=() layer
    for layer in $layers; do
        mapfile -t -O "${#official[@]}" official < <(layer_packages "$layer" official)
        mapfile -t -O "${#aur[@]}" aur < <(layer_packages "$layer" aur)
    done

    if ! ask_yn "Install ${#official[@]} official + ${#aur[@]} AUR packages?" "y"; then
        return
    fi

    printf '%s\n' "${official[@]}" | grep -qE '^(lib32-|steam$)' && enable_multilib
    sudo pacman -Syu --needed --noconfirm "${official[@]}" || {
        print_error "Failed to install some official packages"
        print_warning "You may need to install missing packages manually"
    }

    if [ ${#aur[@]} -gt 0 ] && ensure_yay; then
        yay -S --needed --noconfirm --answerdiff None --answerclean None "${aur[@]}" || {
            print_error "Failed to install some AUR packages"
            print_warning "Re-run: yay -S --needed ${aur[*]}"
        }
    fi
}

install_debian_deps() {
    print_step "Installing Debian/Ubuntu dependencies..."

    print_warning "Not all packages available in Debian repositories"
    print_warning "Some tools will need manual installation"

    sudo apt update
    sudo apt install -y stow git zsh curl wget build-essential \
                        neovim ripgrep fd-find nodejs npm python3 python3-pip \
                        tmux jq
}

install_fedora_deps() {
    print_step "Installing Fedora dependencies..."

    sudo dnf install -y stow git zsh curl wget gcc make \
                        neovim ripgrep fd-find nodejs npm python3 python3-pip \
                        tmux jq
}

install_macos_deps() {
    print_step "Installing macOS dependencies..."

    if ! command -v brew &> /dev/null; then
        print_error "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew install stow git zsh neovim ripgrep fd node python \
                 starship zoxide fzf eza bat ripgrep jq direnv \
                 tmux git-delta lazygit gh mise
}

install_dependencies() {
    case $OS in
        arch)
            install_arch_deps
            ;;
        ubuntu|debian)
            install_debian_deps
            ;;
        fedora)
            install_fedora_deps
            ;;
        macos)
            install_macos_deps
            ;;
        *)
            print_error "Unsupported OS: $OS"
            print_warning "Please install dependencies manually (see DEPENDENCIES.md)"
            if ! ask_yn "Continue anyway?" "n"; then
                exit 1
            fi
            ;;
    esac

    # Install mise (cross-platform)
    if ! command -v mise &> /dev/null; then
        print_step "Installing mise..."
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

#==============================================================================
# Backup Existing Configs
#==============================================================================

backup_configs() {
    if [ "$NO_BACKUP" = true ]; then
        print_warning "Skipping backup (--no-backup flag)"
        return 0
    fi

    print_step "Backing up existing configurations..."

    local configs_to_backup=(
        ".config/nvim"
        ".config/hypr"
        ".config/waybar"
        ".config/rofi"
        ".config/swaync"
        ".config/tmux"
        ".config/starship.toml"
        ".zshrc"
        ".gitconfig"
    )

    local backed_up=0

    for config in "${configs_to_backup[@]}"; do
        if [ -e "$HOME/$config" ] && [ ! -L "$HOME/$config" ]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$config")"
            cp -r "$HOME/$config" "$BACKUP_DIR/$config"
            backed_up=$((backed_up + 1))
        fi
    done

    if [ $backed_up -gt 0 ]; then
        print_success "Backed up $backed_up configs to: $BACKUP_DIR"
        echo "$BACKUP_DIR" > "$HOME/.dotfiles_last_backup"
    else
        print_success "No existing configs to backup"
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
}

#==============================================================================
# Stow Deployment
#==============================================================================

# Module sets mirror what each machine actually stows (checked on the laptop
# 2026-11-11). themes/ is linked by setup/init_themes.sh, not stow.
# waybar/ is still stowed for its scripts (SUPER+F8, audio-router, settings menu).
MODULES_CORE=("zsh" "nvim" "git" "vim" "tmux" "mise")
MODULES_DESKTOP=("hyprland" "quickshell" "swaync" "kitty" "wofi" "waybar" "swayimg" "wireplumber" "wallpaperd" "systemd" "bin")
MODULES_PERSONAL=("toot" "personal")
# macOS: the same set ./mac stows
MODULES_MACOS=("bin" "nvim" "mac_personal" "tmux" "mac_zsh" "aerospace" "starship")

select_modules() {
    if [ "$OS" = macos ]; then
        MODULES=("${MODULES_MACOS[@]}")
        print_success "macOS modules: ${MODULES[*]}"
        return
    fi

    if [ "$MINIMAL_INSTALL" = true ]; then
        MODULES=("${MODULES_CORE[@]}")
        print_success "Minimal install: ${MODULES[*]}"
        return
    fi

    if [ "$INTERACTIVE" = false ]; then
        # Default full install
        MODULES=("${MODULES_CORE[@]}" "${MODULES_DESKTOP[@]}" "${MODULES_PERSONAL[@]}")
        return
    fi

    echo ""
    echo -e "${CYAN}Select modules to install:${NC}"
    echo "  1. Minimal (${MODULES_CORE[*]})"
    echo "  2. Desktop (+ ${MODULES_DESKTOP[*]})"
    echo "  3. Full (+ ${MODULES_PERSONAL[*]})"
    echo "  4. Custom (select individually)"
    echo ""

    read -p "Choice [3]: " choice
    choice=${choice:-3}

    case $choice in
        1) MODULES=("${MODULES_CORE[@]}") ;;
        2) MODULES=("${MODULES_CORE[@]}" "${MODULES_DESKTOP[@]}") ;;
        3) MODULES=("${MODULES_CORE[@]}" "${MODULES_DESKTOP[@]}" "${MODULES_PERSONAL[@]}") ;;
        4) select_custom_modules ;;
        *)
            print_error "Invalid choice, using full install"
            MODULES=("${MODULES_CORE[@]}" "${MODULES_DESKTOP[@]}" "${MODULES_PERSONAL[@]}")
            ;;
    esac
}

select_custom_modules() {
    MODULES=()
    local module
    for module in "${MODULES_CORE[@]}" "${MODULES_DESKTOP[@]}" "${MODULES_PERSONAL[@]}"; do
        if ask_yn "Install $module?" "y"; then
            MODULES+=("$module")
        fi
    done
}

deploy_dotfiles() {
    print_step "Deploying dotfiles with stow..."

    cd "$DOTFILES_DIR"
    ensure_shared_dirs

    for module in "${MODULES[@]}"; do
        if [ -d "$module" ]; then
            print_step "Stowing $module..."

            # Use --adopt for first-time install to handle conflicts
            if stow --adopt -v "$module" 2>&1; then
                print_success "Deployed $module"
            else
                print_error "Failed to deploy $module"
                if ask_yn "Continue with other modules?" "y"; then
                    continue
                else
                    exit 1
                fi
            fi
        else
            print_warning "Module $module not found, skipping"
        fi
    done
}

#==============================================================================
# NAS Mounts
#==============================================================================

# Calibre library on the Synology NFS share, mounted on first access so boot
# never waits on the NAS (e.g. away from home). Only one Calibre instance may
# open the library at a time: SQLite over the network has no safe sharing.
NAS_HOST="192.168.0.238"
NAS_BOOKS_EXPORT="/volume3/books"
NAS_BOOKS_MOUNT="/mnt/books"

setup_nas_books() {
    [ "$OS" = "arch" ] || return 0

    if grep -qs "[[:space:]]$NAS_BOOKS_MOUNT[[:space:]]" /etc/fstab; then
        print_success "NAS books mount already in /etc/fstab"
        return 0
    fi

    if ask_yn "Add NAS books automount ($NAS_HOST:$NAS_BOOKS_EXPORT -> $NAS_BOOKS_MOUNT)?" "y"; then
        sudo mkdir -p "$NAS_BOOKS_MOUNT"
        printf '%s:%s  %s  nfs4  nfsvers=4.1,_netdev,noauto,x-systemd.automount,x-systemd.idle-timeout=10min,x-systemd.mount-timeout=30s  0 0\n' \
            "$NAS_HOST" "$NAS_BOOKS_EXPORT" "$NAS_BOOKS_MOUNT" | sudo tee -a /etc/fstab > /dev/null
        sudo systemctl daemon-reload
        sudo systemctl start "$(systemd-escape --path "$NAS_BOOKS_MOUNT").automount" || true
        print_success "NAS books automount added (point Calibre at $NAS_BOOKS_MOUNT)"
    fi
}

#==============================================================================
# Post-Installation
#==============================================================================

post_install() {
    print_step "Running post-installation tasks..."

    # Change default shell to zsh (via sudo: plain chsh prompts for a password,
    # which aborts a --non-interactive run)
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_yn "Change default shell to zsh?" "y"; then
            if sudo chsh -s "$(which zsh)" "$USER"; then
                print_success "Changed shell to zsh (restart terminal to apply)"
            else
                print_warning "Could not change shell; run: chsh -s $(which zsh)"
            fi
        fi
    fi

    setup_nas_books

    # Install mise tools
    if command -v mise &> /dev/null; then
        print_step "Installing mise tools..."
        mise install || print_warning "mise install failed (you can run 'mise install' manually later)"
    fi

    # Install Neovim plugins
    if ask_yn "Install Neovim plugins now?" "y"; then
        print_step "Installing Neovim plugins..."
        nvim --headless "+Lazy! sync" +qa || print_warning "Plugin installation may have failed"
    fi

    # Install Tmux plugins
    if ask_yn "Install Tmux plugins now?" "n"; then
        print_step "Installing Tmux plugins..."
        print_warning "Press Prefix + I in tmux to install plugins"
    fi

    # Enable Mastodon notifications
    if command -v systemctl &> /dev/null && [ -f "$HOME/.config/systemd/user/mastodon-notifications.service" ]; then
        if ask_yn "Enable Mastodon notification daemon?" "y"; then
            systemctl --user daemon-reload
            systemctl --user enable mastodon-notifications.service
            systemctl --user start mastodon-notifications.service
            print_success "Mastodon notifications enabled"
        fi
    fi
}

#==============================================================================
# Verification
#==============================================================================

verify_installation() {
    print_step "Verifying installation..."

    local checks=(
        "zsh:ZSH"
        "nvim:Neovim"
        "git:Git"
        "starship:Starship"
        "stow:Stow"
        "rg:Ripgrep"
        "fd:fd"
    )

    local failed=0

    for check in "${checks[@]}"; do
        local cmd="${check%%:*}"
        local name="${check##*:}"

        if command -v "$cmd" &> /dev/null; then
            print_success "$name installed"
        else
            print_error "$name not found"
            failed=$((failed + 1))
        fi
    done

    if [ $failed -eq 0 ]; then
        print_success "All core tools installed!"
    else
        print_warning "$failed tool(s) missing (see DEPENDENCIES.md)"
    fi
}

#==============================================================================
# Main Installation Flow
#==============================================================================

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --migrate       Safe migration mode for systems with existing configs"
    echo "  --minimal       Install only core modules (zsh, nvim, git, starship)"
    echo "  --no-backup     Skip backing up existing configs"
    echo "  --non-interactive  Run without prompts (use defaults)"
    echo "  --help          Show this help message"
    echo ""
    echo "Installation Modes:"
    echo "  Fresh install:    ./install.sh"
    echo "                    Best for new systems with no existing configs"
    echo ""
    echo "  Migration:        ./install.sh --migrate"
    echo "                    Best for systems with existing configs"
    echo "                    - Detects conflicts per module"
    echo "                    - Asks what to do for each conflict"
    echo "                    - Uses safe stow --restow instead of --adopt"
    echo "                    - Backs up only conflicting files"
    echo ""
    echo "  Update:           ./setup/setup.sh"
    echo "                    Best for systems where dotfiles are already installed"
    echo "                    - Idempotent: only installs missing pieces"
    echo "                    - Checks packages, plugins, themes, services"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full interactive install (fresh system)"
    echo "  $0 --migrate          # Safe install (has existing configs)"
    echo "  $0 --minimal          # Minimal install"
    echo "  $0 --no-backup        # Skip backup step"
    echo ""
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --migrate)
                MIGRATE_MODE=true
                shift
                ;;
            --minimal)
                MINIMAL_INSTALL=true
                shift
                ;;
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --non-interactive)
                INTERACTIVE=false
                shift
                ;;
            --layers)
                LAYERS="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    print_header

    print_step "Starting installation in: $DOTFILES_DIR"
    echo ""

    detect_os

    if ask_yn "Install dependencies?" "y"; then
        install_dependencies
    fi

    backup_configs

    select_modules

    if ask_yn "Deploy dotfiles with stow?" "y"; then
        if [ "$MIGRATE_MODE" = true ]; then
            migrate_deploy_dotfiles
        else
            deploy_dotfiles
        fi
    fi

    post_install

    # Run comprehensive setup system
    if ask_yn "Run setup scripts (themes, plugins, services, mise)?" "y"; then
        if [ -x "$DOTFILES_DIR/setup/setup.sh" ]; then
            print_step "Running setup orchestrator..."
            echo ""
            "$DOTFILES_DIR/setup/setup.sh"
        else
            print_warning "Setup orchestrator not found, skipping"
            verify_installation
        fi
    else
        verify_installation
    fi

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${STAR} Installation Complete! ${STAR}                              ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Open Neovim and let plugins install: nvim"
    echo "  3. If using Hyprland, logout and select Hyprland session"
    echo "  4. Check out the README.md for usage guides"
    echo ""

    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Your old configs are backed up in:${NC}"
        echo "  $BACKUP_DIR"
        echo -e "${YELLOW}To restore: ./scripts/restore.sh $BACKUP_DIR${NC}"
        echo ""
    fi

    echo -e "${MAGENTA}Enjoy your new dotfiles! ${STAR}${NC}"
}

# Run main function
main "$@"
