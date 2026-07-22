# Dependencies

Complete list of dependencies for all dotfiles modules.

## Table of Contents

1. [Core Dependencies](#core-dependencies)
2. [Per-Module Dependencies](#per-module-dependencies)
3. [Installation Commands](#installation-commands)
4. [Optional Dependencies](#optional-dependencies)

---

## Core Dependencies

Required for basic dotfiles management:

| Package | Purpose | Required By |
|---------|---------|-------------|
| `stow` | Symlink management | All modules |
| `git` | Version control | All modules |
| `zsh` | Shell | zsh module |
| `curl` | Download tool | Various |
| `wget` | Download tool | Various |

---

## Per-Module Dependencies

### Neovim

**Required:**
- `neovim` >= 0.9.0 (preferably 0.10+)
- `git` - For plugin management
- `curl` - For plugin downloads
- `ripgrep` (`rg`) - For Telescope grep
- `fd` - For Telescope file finding
- `nodejs` >= 18 - For LSP servers
- `npm` - For installing language servers
- `python3` - For Python providers
- `python-pip` - For Python packages

**Optional but Recommended:**
- `gcc` / `clang` - For Treesitter compilation
- `make` - For building native extensions
- `tree-sitter-cli` - For Treesitter development
- `lazygit` - Git TUI
- `delta` - Git diff viewer
- `bat` - Better cat with syntax highlighting
- `eza` - Better ls
- `jq` - JSON processor

**Language Servers (install via Mason or manually):**
- `lua-language-server` - Lua
- `typescript-language-server` - JavaScript/TypeScript
- `vscode-langservers-extracted` - HTML, CSS, JSON
- `solargraph` or `ruby-lsp` - Ruby
- `gopls` - Go
- `elixir-ls` - Elixir
- `clangd` - C/C++

**Debug Adapters:**
- `debugpy` - Python (via Mason)
- `js-debug-adapter` - JavaScript/TypeScript (via Mason)
- Ruby: `gem install debug`
- Go: `go install github.com/go-delve/delve/cmd/dlv@latest`

**Test Adapters:**
- Ruby: `gem install rspec` (if using RSpec)
- JavaScript: `npm install --save-dev jest` or `vitest`
- Go: Built-in `go test`
- Python: `pip install pytest`

---

### Hyprland

**Required:**
- `hyprland` - Wayland compositor
- `hyprpaper` - Wallpaper daemon
- `hypridle` - Idle management
- `hyprlock` - Screen locker
- `waybar` - Status bar
- `swaync` or `dunst` - Notification daemon
- `rofi` or `wofi` - Application launcher
- `wl-clipboard` - Clipboard management
- `grim` - Screenshot tool
- `slurp` - Region selector
- `swayimg` or `imv` - Image viewer

**Optional:**
- `hyprshot` - Screenshot wrapper
- `brightnessctl` - Brightness control
- `playerctl` - Media control
- `networkmanager` - Network management
- `bluez` - Bluetooth
- `blueman` - Bluetooth GUI
- `pavucontrol` - Audio control GUI
- `qt6ct` - Qt theme configuration
- `nwg-look` - GTK theme configuration

---

### Waybar

**Required:**
- `waybar` - Status bar
- `wireplumber` or `pipewire` - Audio server
- `networkmanager` - Network management

**Optional:**
- `python3` - For custom scripts
- `jq` - JSON processing in scripts
- `bluetui` - Bluetooth TUI (for right-click action)
- `nmtui` - NetworkManager TUI (for right-click action)

---

### Rofi

**Required:**
- `rofi-wayland` or `rofi` - Application launcher

**Optional:**
- `rofi-calc` - Calculator plugin
- `rofi-emoji` - Emoji selector
- `papirus-icon-theme` - Icon theme
- `nerd-fonts` - Icon fonts

---

### SwayNC

**Required:**
- `swaync` - Notification center

**Optional:**
- Custom CSS themes

---

### ZSH

**Required:**
- `zsh` - Shell
- `starship` - Prompt

**Recommended:**
- `zsh-autosuggestions` - Command suggestions
- `zsh-syntax-highlighting` - Syntax highlighting
- `fzf` - Fuzzy finder
- `zoxide` - Smart cd
- `mise` or `asdf` - Version manager
- `direnv` - Directory environment

**Optional:**
- `eza` - Better ls
- `bat` - Better cat
- `fd` - Better find
- `ripgrep` - Better grep

---

### Starship

**Required:**
- `starship` - Cross-shell prompt

**Recommended:**
- Nerd Font (for icons)
- `git` - For git status
- `nodejs` - For version detection
- `python` - For version detection
- `ruby` - For version detection
- `go` - For version detection

---

### Tmux

**Required:**
- `tmux` >= 3.0

**Recommended:**
- `tpm` - Tmux Plugin Manager (auto-installed)

**Plugins (auto-installed via TPM):**
- `tmux-sensible` - Sensible defaults
- `tmux-yank` - Copy to clipboard
- `tmux-resurrect` - Session persistence
- `tmux-continuum` - Auto-save sessions
- `catppuccin-tmux` - Theme
- `vim-tmux-navigator` - Seamless Vim/Tmux navigation
- `tmux-sessionx` - Session manager
- `tmux-fzf` - FZF integration

---

### Git

**Required:**
- `git` >= 2.30

**Recommended:**
- `delta` - Better diff viewer
- `lazygit` - Git TUI
- `gh` - GitHub CLI

**Optional:**
- `tig` - Git repository browser

---

### Toot (Mastodon CLI)

**Required:**
- `toot` - Mastodon CLI
- `python-pillow` - Image processing
- `python-term-image` - Terminal image display
- `jq` - JSON processing
- `libnotify` - Desktop notifications

**Optional:**
- `ghostty` or any terminal - For TUI

---

### Mise (Version Manager)

**Required:**
- `mise` (formerly rtx)

**Replaces:**
- `nvm` (Node Version Manager)
- `pyenv` (Python)
- `rbenv` / `rvm` (Ruby)
- `asdf` (Multi-language)

---

## Installation Commands

### Arch Linux

```bash
# Core
sudo pacman -S stow git zsh

# Neovim
sudo pacman -S neovim ripgrep fd nodejs npm python python-pip gcc make

# Hyprland Desktop
sudo pacman -S hyprland hyprpaper hypridle hyprlock waybar swaync rofi-wayland \
               wl-clipboard grim slurp swayimg brightnessctl playerctl \
               networkmanager bluez blueman pavucontrol qt6ct

# Shell Tools
sudo pacman -S starship zoxide fzf eza bat fd ripgrep direnv jq

# Tmux
sudo pacman -S tmux

# Git Tools
sudo pacman -S git-delta lazygit github-cli

# Toot (Mastodon)
sudo pacman -S toot python-pillow python-term-image jq libnotify

# Mise
curl https://mise.run | sh

# Fonts
sudo pacman -S ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd

# ZSH Plugins
sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting
```

### Debian / Ubuntu

```bash
# Core
sudo apt install stow git zsh

# Neovim (install from GitHub releases or PPA)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim ripgrep fd-find nodejs npm python3 python3-pip build-essential

# Hyprland (compile from source or use backports)
# See: https://hyprland.org/

# Shell Tools
# Starship:
curl -sS https://starship.rs/install.sh | sh

# Zoxide:
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# FZF:
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Eza:
sudo apt install -y gpg
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install eza

# Tmux
sudo apt install tmux

# Git Tools
# Delta:
wget https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
sudo dpkg -i git-delta_0.16.5_amd64.deb

# Mise
curl https://mise.run | sh
```

### Fedora

```bash
# Core
sudo dnf install stow git zsh

# Neovim
sudo dnf install neovim ripgrep fd-find nodejs npm python3 python3-pip gcc make

# Hyprland
sudo dnf install hyprland waybar rofi wl-clipboard grim slurp

# Shell Tools
sudo dnf install starship zoxide fzf eza bat ripgrep jq

# Tmux
sudo dnf install tmux

# Git Tools
sudo dnf install git-delta lazygit gh

# Mise
curl https://mise.run | sh
```

### macOS (Homebrew)

```bash
# Core
brew install stow git zsh

# Neovim
brew install neovim ripgrep fd node python gcc make

# Shell Tools
brew install starship zoxide fzf eza bat ripgrep jq direnv

# Tmux
brew install tmux

# Git Tools
brew install git-delta lazygit gh

# Mise
brew install mise

# Fonts
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font font-cascadia-code-nerd-font
```

---

## Optional Dependencies

### For Enhanced Experience

**Development:**
- `docker` - Container runtime (for Docker-aware testing/debugging)
- `docker-compose` - Multi-container orchestration
- `lazydocker` - Docker TUI
- `kubectl` - Kubernetes CLI
- `k9s` - Kubernetes TUI

**System Monitoring:**
- `btop` or `htop` - System monitor
- `bottom` - System monitor (Rust)
- `nvtop` - GPU monitor

**File Management:**
- `ranger` - File manager TUI
- `yazi` - Modern file manager TUI
- `nnn` - File manager
- `nautilus` - GUI file manager (GNOME)
- `thunar` - GUI file manager (XFCE)

**Productivity:**
- `obsidian` - Note-taking (if using Obsidian.nvim)
- `zathura` - PDF viewer
- `mpv` - Media player

**Audio:**
- `spotify` - Music streaming
- `tidal-hifi` - Hi-fi music streaming
- `pavucontrol` - PulseAudio volume control

---

## Post-Installation

After installing dependencies:

1. **Neovim plugins:**
   ```bash
   nvim
   # Lazy.nvim will auto-install plugins
   :Lazy sync
   :Mason  # Install language servers
   ```

2. **ZSH plugins:**
   ```bash
   # Already sourced from /usr/share/zsh/plugins/ on Arch
   # Or install manually if needed
   ```

3. **Tmux plugins:**
   ```bash
   # Press <prefix> + I (capital I) in tmux
   # TPM will auto-install plugins
   ```

4. **Mise tools:**
   ```bash
   mise install  # Install versions from .mise.toml or .tool-versions
   ```

5. **Mastodon notifications:**
   ```bash
   # Enable and start systemd service
   systemctl --user enable mastodon-notifications.service
   systemctl --user start mastodon-notifications.service
   ```

---

## Troubleshooting

### Neovim: Plugins not installing

```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Reinstall
nvim
:Lazy sync
```

### ZSH: Plugins not loading

```bash
# Check plugin paths
ls /usr/share/zsh/plugins/

# Or install to ~/.zsh/plugins/
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
```

### Hyprland: Missing protocols

```bash
# Install all Wayland protocols
sudo pacman -S wayland-protocols

# Or on other distros:
sudo apt install wayland-protocols
```

### Mise: Command not found

```bash
# Add to PATH (should be in .zshrc)
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall:
curl https://mise.run | sh
```

---

## Minimum vs Recommended

### Minimum (Shell + Editor)

```bash
# Arch
sudo pacman -S stow git zsh neovim starship

# Then stow
stow zsh nvim git starship
```

**Works:** Shell, editor, version control
**Missing:** Desktop environment, advanced features

### Recommended (Full Desktop)

```bash
# Arch
sudo pacman -S stow git zsh neovim ripgrep fd nodejs npm python \
               hyprland waybar swaync rofi-wayland wl-clipboard \
               starship zoxide fzf eza bat git-delta tmux

# Then stow
stow zsh nvim git starship hyprland waybar rofi swaync tmux mise personal
```

**Works:** Full desktop, all features
**Missing:** Optional tools

### Complete (Everything)

Use the full Arch installation command above + optional dependencies.

---

## Version Requirements

| Tool | Minimum | Recommended | Reason |
|------|---------|-------------|--------|
| Neovim | 0.9.0 | 0.10+ | Lazy.nvim, modern plugins |
| Tmux | 3.0 | 3.3+ | Plugin compatibility |
| Git | 2.30 | 2.40+ | Delta, modern features |
| Node.js | 18 | 20 LTS | LSP servers |
| Python | 3.8 | 3.11+ | Neovim providers, LSPs |
| Hyprland | 0.35 | Latest | Active development |

---

_Last Updated: 2025-10-10_
