# Dotfiles

> Professional Arch Linux development environment with Hyprland, Neovim, and Catppuccin Mocha theme

[![Neovim](https://img.shields.io/badge/Neovim-10.0%2F10-57A143?style=flat&logo=neovim)](nvim/.config/nvim)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-5BCEFA?style=flat)](hyprland/.config/hypr)
[![Theme](<https://img.shields.io/badge/Theme-Catppuccin%20(4%20flavors)-CBA6F7?style=flat>)](themes)
[![Centralized](https://img.shields.io/badge/Theme%20System-Centralized-89B4FA?style=flat)](themes)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Overview

This is my personal dotfiles repository for a modern Linux development environment. It features a **centralized theme system** with one-click switching between 4 Catppuccin flavors, professional-grade Neovim configuration with Docker-aware testing/debugging, and a productive Wayland-based desktop with Hyprland.

**Managed with [GNU Stow](https://www.gnu.org/software/stow/)** for easy deployment and organization.

---

## Features

### Centralized Theme System

- **One-click theme switching** across all applications
- **4 Catppuccin flavors**: Mocha (dark), Latte (light), Frappé (dark), Macchiato (dark)
- **Instant updates** - no application restarts needed
- Synchronized themes: Neovim, Tmux, Waybar, Wofi, Rofi, Ghostty, Hyprland
- Settings menu integration with visual theme picker

### Professional Neovim (10/10)

- **Smart Docker detection** for testing and debugging (unique feature!)
- Full DAP (Debug Adapter Protocol) support with breakpoints
- Neotest with inline results and watch mode
- Monorepo-aware LSP configuration
- 53 plugins, all lazy-loaded
- Comprehensive snippet library
- See [nvim/.config/nvim](nvim/.config/nvim) for details

### Modern Wayland Desktop

- **Hyprland** compositor with split-monitor workspaces
- **Waybar** status bar with custom scripts
- **SwayNC** notification center
- **Rofi** application launcher
- Automated wallpaper management
- Multi-monitor aware

### Optimized Shell

- **ZSH** with starship prompt
- mise for version management (Node, Ruby, Python, etc.)
- FZF with fuzzy finding
- Zoxide for smart directory jumping
- Custom helper functions

### Developer Tools

- **Tmux** with Catppuccin theme and plugins
- **Git** with Delta (side-by-side diffs)
- **Toot** Mastodon CLI with notification daemon
- Docker-aware test runner (RSpec, Jest, Vitest, Go, Python)

---

## 📂 Module Overview

| Module                            | Description                                                    | Status      |
| --------------------------------- | -------------------------------------------------------------- | ----------- |
| [themes](themes)                  | Centralized theme system for all applications                  | 🎨 Complete |
| [nvim](nvim/.config/nvim)         | Professional Neovim config with Docker-aware testing/debugging | ⭐ 10/10    |
| [hyprland](hyprland/.config/hypr) | Wayland compositor with dual-monitor support                   | ✅ Complete |
| [waybar](waybar/.config/waybar)   | Status bar with custom scripts and theme integration           | ✅ Complete |
| [wofi](wofi/.config/wofi)         | Menu system (WiFi, Bluetooth, Power, Settings, Theme)          | ✅ Complete |
| [rofi](rofi/.config/rofi)         | Application launcher with Catppuccin theme                     | ✅ Complete |
| [swaync](swaync/.config/swaync)   | Notification center                                            | ✅ Complete |
| [zsh](zsh)                        | Shell configuration with optimization                          | ✅ Complete |
| [starship](starship/.config)      | Cross-shell prompt                                             | ✅ Complete |
| [tmux](tmux/.config/tmux)         | Terminal multiplexer with theme support                        | ✅ Complete |
| [git](git)                        | Version control with Delta                                     | ✅ Complete |
| [toot](toot)                      | Mastodon CLI with notification daemon                          | ✅ Complete |
| [mise](mise/.config)              | Polyglot version manager                                       | ✅ Complete |
| personal                          | Machine-specific configurations                                | ✅ Complete |

See [DEPENDENCIES.md](DEPENDENCIES.md) for full dependency list.

---

## Quick Start

### Prerequisites

- **Operating System:** Arch Linux (primary), other distros supported
- **Display Server:** Wayland
- **Terminal:** Ghostty (or any terminal with true color support)

### Installation

1. **Clone this repository:**

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Choose your installation mode:**

#### Option A: Fresh Install (New System)

**Best for:** Clean systems with no existing configurations

```bash
chmod +x install.sh
./install.sh
```

**What it does:**

- Detects your OS and installs dependencies
- Backs up any existing configurations to timestamped directory
- Deploys dotfiles using GNU Stow with `--adopt` for quick setup
- Runs theme initialization, plugin installation, and service setup
- Uses `./setup/setup.sh` orchestrator for comprehensive setup

**Use this when:** Setting up a brand new system or VM

---

#### Option B: Migration Mode (Existing System)

**Best for:** Systems with existing configurations you want to keep

```bash
chmod +x install.sh
./install.sh --migrate
```

**What it does:**

- Checks **each module individually** for conflicts before deploying
- Shows you exactly which files will conflict
- For each conflicting module, asks you to:
  - **Backup & Deploy** (recommended) - Backs up only conflicting files, then deploys dotfiles
  - **Skip** - Leave existing config untouched for that module
  - **Abort** - Stop installation
- Uses safe `stow -R` (restow) instead of `--adopt`
- Provides summary of deployed/skipped/failed modules

**Use this when:** You already have `.zshrc`, `.config/nvim`, etc. and want safe migration

**Example workflow:**

```bash
./install.sh --migrate

# For each module with conflicts:
# "Found 3 conflicting files in nvim:"
#   - .config/nvim/init.lua
#   - .config/nvim/lazy-lock.json
#
# Options:
#   1. Backup existing and deploy dotfiles (recommended)
#   2. Skip this module
#   3. Abort installation
#
# Choice [1]: 1
# ✓ Backed up: .config/nvim/init.lua
# ✓ nvim deployed successfully
```

---

#### Option C: Update Mode (Already Installed)

**Best for:** Systems where these dotfiles are already installed

```bash
./setup/setup.sh
```

**What it does:**

- **Idempotent** - Only installs missing components
- Checks and installs missing system packages
- Initializes required directories
- Updates theme system if needed
- Installs missing plugins (Tmux, Neovim)
- Sets up systemd services
- Installs mise tools
- Runs verification checks

**Use this when:**

- Running the script again after initial installation
- Updating to latest changes from git
- Fixing missing dependencies or plugins

---

### Quick Comparison

| Mode              | Command                  | Best For          | Safety Level          |
| ----------------- | ------------------------ | ----------------- | --------------------- |
| **Fresh Install** | `./install.sh`           | New systems       | ⚠️ Uses `--adopt`     |
| **Migration**     | `./install.sh --migrate` | Existing configs  | ✅ Interactive & safe |
| **Update**        | `./setup/setup.sh`       | Already installed | ✅ Idempotent         |

---

### Post-Installation

After running any installation mode:

1. **Restart your terminal:**

   ```bash
   source ~/.zshrc
   # Or open a new terminal
   ```

2. **Verify installation:**

   ```bash
   # Run comprehensive health check
   ./setup/verify.sh
   ```

3. **Open Neovim to finish plugin installation:**

   ```bash
   nvim
   # Plugins will install automatically via Lazy.nvim
   ```

4. **Install Tmux plugins (if using Tmux):**

   ```bash
   tmux
   # Press Prefix + I (default: Ctrl+b then I)
   ```

5. **Test theme switching:**
   ```bash
   # In Hyprland: Press Alt+Space → Settings → Theme
   # Or directly: ~/.config/waybar/scripts/wofi-theme-switcher.sh
   ```

---

### Manual Installation (Advanced)

If you prefer manual control:

```bash
# Install dependencies
sudo pacman -S stow git zsh neovim tmux # ... see DEPENDENCIES.md

# Deploy specific modules with stow
cd ~/dotfiles
stow nvim zsh git starship  # Minimal
stow hyprland waybar rofi swaync  # Desktop
stow tmux toot mise personal  # Additional

# Run setup scripts
./setup/init_packages.sh   # Install missing packages
./setup/init_themes.sh     # Initialize themes
./setup/init_plugins.sh    # Install plugins
./setup/verify.sh          # Verify everything
```

---

## Screenshots

### Neovim

<!-- TODO: Add screenshot -->

- Catppuccin Mocha theme
- LSP with inline diagnostics
- Neotest with inline test results
- DAP debugging with UI

### Hyprland Desktop

<!-- TODO: Add screenshot -->

- Waybar status bar
- SwayNC notifications
- Rofi launcher
- Multi-monitor setup

### Terminal

<!-- TODO: Add screenshot -->

- Starship prompt
- FZF fuzzy finder
- Catppuccin colors

---

## Highlights

### Neovim: Docker-Aware Testing & Debugging

**Zero-config testing in Docker containers:**

```yaml
# docker-compose.yml
services:
  app:
    build: .
    volumes:
      - .:/app
```

**Result:** Tests automatically run with `docker compose run --rm app bundle exec rspec` ✅

**Features:**

- Automatic Docker Compose detection
- Smart service name detection (app, frontend, backend, api)
- Path mapping for debugging
- Fallback to native execution
- Supports RSpec, Jest, Vitest, Go, Python

**Usage:**

```vim
<leader>tr     " Run nearest test (auto-detects Docker)
<leader>dc     " Debug in Docker (attach) - automatic path mapping!
```

See [nvim/.config/nvim/IMPROVEMENTS.md](nvim/.config/nvim/IMPROVEMENTS.md) for details.

### Centralized Theme System

**One command to switch all themes:**

Press `Alt+Space` → Settings → Theme, then select from 4 Catppuccin flavors:

```
● Mocha (Dark)      - Original dark theme
○ Latte (Light)     - Light theme for daytime
○ Frappé (Dark)     - Cool, muted dark theme
○ Macchiato (Dark)  - Warm, rich dark theme
```

**What gets updated:**

- **Neovim** - Instant colorscheme change (no restart)
- **Tmux** - Status bar updates automatically
- **Waybar** - Reloads with new colors
- **Wofi** - All 7 menus (WiFi, Bluetooth, Power, Settings, Theme, Update Manager)
- **Rofi** - Main application launcher
- **Ghostty** - Terminal colors (reloads via SIGUSR2)
- **Hyprland** - Border colors and window decorations

**Architecture:**

Central theme files in `~/dotfiles/themes/`:

```bash
themes/
├── catppuccin/
│   ├── mocha.{css,rasi,ghostty,tmux}
│   ├── latte.{css,rasi,ghostty,tmux}
│   ├── frappe.{css,rasi,ghostty,tmux}
│   └── macchiato.{css,rasi,ghostty,tmux}
├── current.css          # Symlink to active theme
├── current.rasi         # Symlink to active theme
├── current.ghostty      # Symlink to active theme
├── current.tmux         # Symlink to active theme
└── current_flavor.txt   # Plain text: "mocha", "latte", etc.
```

**How it works:**

1. Theme switcher updates symlinks and flavor file
2. Applications read from central `current.*` files
3. Running instances receive reload commands via socket/signal
4. New instances automatically use correct theme

**All colors follow [Catppuccin style guide](https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md):**

- Mocha: `#1e1e2e` (base), `#cdd6f4` (text), `#cba6f7` (mauve)
- Latte: `#eff1f5` (base), `#4c4f69` (text), `#8839ef` (mauve)
- Frappé: `#303446` (base), `#c6d0f5` (text), `#ca9ee6` (mauve)
- Macchiato: `#24273a` (base), `#cad3f5` (text), `#c6a0f6` (mauve)

### Mastodon Integration

Custom notification daemon for Mastodon:

- Polls `toot` CLI every 60 seconds
- Shows notifications via SwayNC
- Clickable actions (View Post, Open TUI)
- Themed with Catppuccin teal
- Systemd service for auto-start

---

## Customization

### Theme Switching

**Interactive (recommended):**

Press `Alt+Space`, select "Settings", then "Theme". Choose from 4 Catppuccin flavors.

**Command line:**

```bash
# View current theme
cat ~/.config/themes/current_flavor.txt

# Manual theme switch (updates all symlinks)
cd ~/dotfiles/themes
ln -sf catppuccin/latte.css current.css
ln -sf catppuccin/latte.rasi current.rasi
ln -sf catppuccin/latte.ghostty current.ghostty
ln -sf catppuccin/latte.tmux current.tmux
echo "latte" > current_flavor.txt

# Reload applications
pkill -SIGUSR2 waybar  # Waybar
pkill -SIGUSR2 ghostty  # Ghostty
tmux source ~/.config/tmux/tmux.conf  # Tmux
# Neovim reloads automatically via server sockets
```

**Add new themes:**

1. Create theme files in `themes/catppuccin/`:
   - `mytheme.css` (Waybar/Wofi)
   - `mytheme.rasi` (Rofi)
   - `mytheme.ghostty` (Terminal)
   - `mytheme.tmux` (Tmux flavor setting)

2. Update theme switcher menu:

   ```bash
   vim waybar/.config/waybar/scripts/wofi-theme-switcher.sh
   ```

3. Add to theme detection in Neovim:
   ```lua
   -- lua/user/theme.lua
   local valid_flavors = { mocha = true, latte = true, frappe = true, macchiato = true, mytheme = true }
   ```

### Module Selection

Only install what you need:

```bash
# Minimal setup (shell + editor)
stow zsh nvim git starship

# Desktop environment
stow zsh nvim git starship hyprland waybar rofi swaync

# Full setup
stow zsh nvim git starship hyprland waybar rofi swaync tmux toot mise personal
```

---

## 📚 Documentation

Each major module has its own README:

- [Neovim Configuration](nvim/.config/nvim/README.md) - Full feature list, keybindings, workflow
- [Neovim Improvements](nvim/.config/nvim/IMPROVEMENTS.md) - Recent enhancements (9.3 → 10.0)
- [Neovim Workflow](nvim/.config/nvim/WORKFLOW.md) - Day-in-the-life developer guide
- [Hyprland Configuration](hyprland/.config/hypr/README.md) - Window manager setup
- [Waybar Configuration](waybar/.config/waybar/README.md) - Status bar modules
- [Wofi Configuration](wofi/.config/wofi/README.md) - Menu system
- [Rofi Configuration](rofi/.config/rofi/README.md) - Launcher customization
- [Tmux Configuration](tmux/.config/tmux/README.md) - Terminal multiplexer
- [Toot Configuration](toot/README.md) - Mastodon CLI setup
- [Wireplumber Configuration](wireplumber/README.md) - Audio configuration

---

## 🔧 Backup & Restore

Use the provided scripts for safe configuration management:

```bash
# Backup current configs before stowing
./scripts/backup.sh

# Backup specific module
./scripts/backup.sh nvim

# List backups
./scripts/backup.sh --list

# Restore from backup
./scripts/restore.sh ~/.dotfiles_backup_20250110_143022

# Cleanup old backups (keeps last 5)
./scripts/cleanup.sh
```

---

## Testing

Before deploying to your main system:

1. **Test in VM or container:**

   ```bash
   # Podman/Docker
   podman run -it --rm archlinux bash
   # Then clone and install
   ```

2. **Selective deployment:**

   ```bash
   # Test one module first
   stow --no nvim  # Dry run
   stow nvim       # Actually deploy
   ```

3. **Verify configs:**
   ```bash
   # Check for syntax errors
   nvim --headless "+Lazy! sync" +qa
   zsh -n ~/.zshrc
   ```

---

## Dependencies

See [DEPENDENCIES.md](DEPENDENCIES.md) for:

- Core dependencies (stow, git, zsh)
- Per-module dependencies
- Optional dependencies
- Installation commands for various distros

---

## Contributing

This is my personal dotfiles repository, but feel free to:

- Fork and adapt for your own use
- Open issues for bugs or questions
- Submit PRs for improvements

---

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

## Credits

**Inspiration and tools from:**

- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful pastel theme
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor
- [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor
- [Lazy.nvim](https://github.com/folke/lazy.nvim) - Modern plugin manager
- [Starship](https://starship.rs/) - Cross-shell prompt
- [ThePrimeagen](https://github.com/ThePrimeagen) - Harpoon, tmux-sessionizer
- [Folke](https://github.com/folke) - Multiple Neovim plugins

**Similar dotfiles repositories:**

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)

---

## Contact

- GitHub: [@juanjodarko``](https://github.com/juanjodarko)

---

<p align="center">
  <sub>Built with ❤️ and ☕ on Arch Linux</sub>
</p>
