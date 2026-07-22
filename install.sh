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

migrate_deploy_dotfiles() {
    print_step "Deploying dotfiles with safe migration..."
    echo ""

    cd "$DOTFILES_DIR"

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

install_arch_deps() {
    print_step "Installing Arch Linux dependencies..."

    local packages=(
        # Core
        "stow" "git" "zsh" "curl" "wget" "base-devel"

        # Neovim
        "neovim" "ripgrep" "fd" "nodejs" "npm" "python" "python-pip"

        # Hyprland (if not minimal)
        "hyprland" "hyprpaper" "hypridle" "hyprlock" "waybar" "swaync"
        "rofi-wayland" "wl-clipboard" "grim" "slurp" "swayimg"
        "brightnessctl" "playerctl" "networkmanager" "bluez" "blueman"
        "pavucontrol" "qt6ct"

        # Shell Tools
        "starship" "zoxide" "fzf" "eza" "bat" "jq" "direnv"

        # Tmux
        "tmux"

        # Git Tools
        "git-delta" "lazygit" "github-cli"

        # Toot (Mastodon)
        "toot" "python-pillow" "python-term-image" "libnotify"

        # ZSH Plugins
        "zsh-autosuggestions" "zsh-syntax-highlighting"

        # Fonts
        "ttf-jetbrains-mono-nerd" "ttf-cascadia-code-nerd"
    )

    if [ "$MINIMAL_INSTALL" = true ]; then
        packages=("stow" "git" "zsh" "neovim" "ripgrep" "fd" "nodejs" "npm" "starship")
    fi

    if ask_yn "Install packages with pacman?" "y"; then
        sudo pacman -Syu --needed --noconfirm "${packages[@]}" || {
            print_error "Failed to install some packages"
            print_warning "You may need to install missing packages manually"
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

select_modules() {
    if [ "$MINIMAL_INSTALL" = true ]; then
        MODULES=("zsh" "nvim" "git" "starship")
        print_success "Minimal install: ${MODULES[*]}"
        return
    fi

    if [ "$INTERACTIVE" = false ]; then
        # Default full install
        MODULES=("zsh" "nvim" "git" "starship" "hyprland" "waybar" "rofi" "swaync" "tmux" "toot" "mise" "personal")
        return
    fi

    echo ""
    echo -e "${CYAN}Select modules to install:${NC}"
    echo "  1. Minimal (zsh, nvim, git, starship)"
    echo "  2. Desktop (+ hyprland, waybar, rofi, swaync)"
    echo "  3. Full (+ tmux, toot, mise, personal)"
    echo "  4. Custom (select individually)"
    echo ""

    read -p "Choice [3]: " choice
    choice=${choice:-3}

    case $choice in
        1)
            MODULES=("zsh" "nvim" "git" "starship")
            ;;
        2)
            MODULES=("zsh" "nvim" "git" "starship" "hyprland" "waybar" "rofi" "swaync")
            ;;
        3)
            MODULES=("zsh" "nvim" "git" "starship" "hyprland" "waybar" "rofi" "swaync" "tmux" "toot" "mise" "personal")
            ;;
        4)
            select_custom_modules
            ;;
        *)
            print_error "Invalid choice, using full install"
            MODULES=("zsh" "nvim" "git" "starship" "hyprland" "waybar" "rofi" "swaync" "tmux" "toot" "mise" "personal")
            ;;
    esac
}

select_custom_modules() {
    MODULES=()
    local available=("zsh" "nvim" "git" "starship" "hyprland" "waybar" "rofi" "swaync" "dunst" "tmux" "toot" "mise" "bash" "vim" "personal")

    for module in "${available[@]}"; do
        if ask_yn "Install $module?" "y"; then
            MODULES+=("$module")
        fi
    done
}

deploy_dotfiles() {
    print_step "Deploying dotfiles with stow..."

    cd "$DOTFILES_DIR"

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
# Post-Installation
#==============================================================================

post_install() {
    print_step "Running post-installation tasks..."

    # Change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_yn "Change default shell to zsh?" "y"; then
            chsh -s "$(which zsh)"
            print_success "Changed shell to zsh (restart terminal to apply)"
        fi
    fi

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
