# Tmux Configuration

Powerful Catppuccin Mocha themed terminal multiplexer with vim integration, session management, and extensive plugin ecosystem.

## Features

- **Catppuccin Mocha Theme** - Beautiful status bar with powerline separators
- **Ctrl+A Prefix** - Ergonomic alternative to Ctrl+B
- **Vim Mode** - Vi-style copy mode with vim keybindings
- **Seamless Vim Integration** - Navigate between tmux panes and vim splits with same keys
- **Session Manager (SessionX)** - Fuzzy finder for sessions with zoxide integration
- **Smart Copy/Paste** - System clipboard integration with tmux-yank
- **URL Launcher** - Quick URL opening with fzf
- **Thumb Mode** - Hint-based text copying
- **Obsidian Integration** - Quick note creation and search
- **Status Bar Top** - macOS-style status bar positioning

## Dependencies

**Required:**
- `tmux` - Terminal multiplexer (v3.0+)

**Recommended:**
- `fzf` - Fuzzy finder (for sessionx, fzf-url)
- `zoxide` - Smart directory jumper (for sessionx)
- `nvim` - Neovim (for vim-tmux-navigator, obsidian integration)
- `xclip` or `wl-clipboard` - Clipboard utilities

**Optional:**
- `urlview` or `urlscan` - URL extraction
- `thumbs` - Rust-based hint picker

## Configuration Files

```
tmux/
├── .config/
│   └── tmux/
│       ├── tmux.conf           # Main configuration
│       ├── tmux.reset.conf     # Reset configuration
│       ├── scripts/
│       │   └── cal.sh          # Calendar script (optional)
│       └── plugins/            # TPM plugins (auto-installed)
│           ├── tpm/
│           ├── catppuccin-tmux/
│           ├── tmux-sessionx/
│           ├── vim-tmux-navigator/
│           ├── tmux-yank/
│           ├── tmux-fzf/
│           ├── tmux-fzf-url/
│           └── tmux-thumbs/
```

## Installation

### Install TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

### Install Plugins

1. **Start tmux:**
   ```bash
   tmux
   ```

2. **Install plugins:**
   Press `Ctrl+A` then `I` (capital i)

3. **Wait for installation to complete**

## Basic Usage

### Starting Tmux

```bash
# Start new session
tmux

# Start named session
tmux new -s myproject

# Attach to existing session
tmux attach

# Attach to specific session
tmux attach -t myproject

# List sessions
tmux ls
```

### Prefix Key

**Default:** `Ctrl+A` (not Ctrl+B)

All tmux commands start with the prefix key.

## Essential Keybindings

### Sessions

| Key | Action |
|-----|--------|
| `Ctrl+A` `o` | SessionX fuzzy finder |
| `Ctrl+A` `d` | Detach from session |
| `Ctrl+A` `$` | Rename session |
| `Ctrl+A` `s` | List sessions |

### Windows (Tabs)

| Key | Action |
|-----|--------|
| `Ctrl+A` `c` | Create new window |
| `Ctrl+A` `r` | Rename window |
| `Ctrl+A` `n` | Next window |
| `Ctrl+A` `p` | Previous window |
| `Ctrl+A` `0-9` | Go to window 0-9 |
| `Ctrl+A` `&` | Kill window |
| `Ctrl+A` `w` | List windows |

### Panes (Splits)

| Key | Action |
|-----|--------|
| `Ctrl+A` `\|` | Split horizontally |
| `Ctrl+A` `-` | Split vertically |
| `Ctrl+A` `x` | Kill pane |
| `Ctrl+A` `z` | Toggle zoom |
| `Ctrl+A` `{` | Move pane left |
| `Ctrl+A` `}` | Move pane right |
| `Ctrl+A` `q` | Show pane numbers |

### Vim-Style Navigation

**Navigate between panes AND vim splits:**

| Key | Action |
|-----|--------|
| `Ctrl+h` | Move left |
| `Ctrl+j` | Move down |
| `Ctrl+k` | Move up |
| `Ctrl+l` | Move right |

**No prefix needed!** Works seamlessly between tmux panes and vim splits.

### Copy Mode

| Key | Action |
|-----|--------|
| `Ctrl+A` `[` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `Ctrl+v` | Rectangle selection |
| `y` | Copy selection and exit |
| `q` | Exit copy mode |

**Copy mode uses vim keybindings:**
- `h/j/k/l` - Move cursor
- `w/b` - Word forward/backward
- `0/$` - Start/end of line
- `gg/G` - Top/bottom of buffer
- `/` - Search forward
- `?` - Search backward
- `n/N` - Next/previous match

## Plugin Features

### SessionX

**Purpose:** Modern session manager with fuzzy finder

**Keybinding:** `Ctrl+A` `o`

**Features:**
- Fuzzy search sessions
- Zoxide integration (recent directories)
- Create sessions from dotfiles
- Preview session windows
- Kill sessions with `Ctrl+x`

**Custom paths:**
- `~/dotfiles` - Pre-configured shortcut

**Navigation:**
- `↑/↓` or `Ctrl+j/k` - Navigate
- `Enter` - Switch to session
- `Ctrl+x` - Delete session
- `Ctrl+y` - Create new window in session
- `Esc` - Cancel

### Tmux Yank

**Purpose:** Copy to system clipboard

**Features:**
- Automatic clipboard integration
- Works with X11 (`xclip`) and Wayland (`wl-copy`)
- Copy mode selections automatically go to clipboard

**Usage:**
1. Enter copy mode: `Ctrl+A` `[`
2. Select text: `v` + movement keys
3. Copy: `y` (automatically copies to system clipboard)

### Vim-Tmux Navigator

**Purpose:** Seamless navigation between vim and tmux

**Features:**
- Same keybindings work in both vim and tmux
- No context switching needed
- Works with vim splits and tmux panes

**Keybindings:**
- `Ctrl+h` - Left
- `Ctrl+j` - Down
- `Ctrl+k` - Up
- `Ctrl+l` - Right

**Note:** These work WITHOUT the tmux prefix!

### Tmux FZF URL

**Purpose:** Extract and open URLs from terminal

**Keybinding:** `Ctrl+A` `u`

**Features:**
- Scans visible pane content for URLs
- Fuzzy search URLs
- Open in browser
- History of 2000 URLs

**Usage:**
1. Press `Ctrl+A` `u`
2. Select URL with fzf
3. Press `Enter` to open

### Tmux Thumbs

**Purpose:** Hint-based text copying

**Keybinding:** `Ctrl+A` `Space` (default)

**Features:**
- Shows hints (letters) next to copyable text
- Fast keyboard-driven selection
- Useful for UUIDs, paths, hashes

**Usage:**
1. Press `Ctrl+A` `Space`
2. Type hint letter(s)
3. Text automatically copied

### Tmux FZF

**Purpose:** Fuzzy finder for tmux commands

**Keybinding:** `Ctrl+A` `f`

**Features:**
- Search windows, panes, sessions
- Execute tmux commands
- Browse tmux options

## Obsidian Integration

### Quick Note Creation

**Keybinding:** `Ctrl+N` (global, no prefix)

**Action:** Opens Obsidian new note popup

**Configuration:**
```conf
bind-key -n C-n display-popup -E nvim -c ":ObsidianNew"
```

### Quick Note Search

**Keybinding:** `Ctrl+Q` (global, no prefix)

**Action:** Opens Obsidian search popup (90% width, 85% height)

**Configuration:**
```conf
bind-key -n C-q display-popup -w "90%" -h "85%" -E nvim -c ":ObsidianSearch"
```

**Requirements:**
- Neovim with obsidian.nvim plugin
- Obsidian vault configured

## Status Bar

### Layout

**Position:** Top of screen (macOS style)

**Modules:**
- **Left:** Session name
- **Right:** Current directory, time (HH:MM)

**Window List (Center):**
- Inactive windows: Grayed out with window number
- Active window: Highlighted with window name
- Zoom indicator: 🔍 when pane is zoomed

### Catppuccin Mocha Theme

**Colors:**
- Active window: Lavender (`#b4befe`)
- Inactive windows: Surface0 (`#313244`)
- Status bar: Base (`#1e1e2e`)
- Text: Text (`#cdd6f4`)

**Separators:**
- Powerline-style seamless separators
- Window: ` █`
- Status: ` `

## Configuration Details

### Terminal Colors

**True color support:**
```conf
set -ga terminal-overrides ",xterm*:Tc"
set-option -g default-terminal 'screen-256color'
set-option -g terminal-overrides ',xterm-256color:RGB'
```

### Base Settings

```conf
set -g prefix ^A              # Prefix: Ctrl+A
set -g base-index 1           # Windows start at 1 (not 0)
set -g renumber-windows on    # Renumber windows when one is closed
setw -g mode-keys vi          # Vim mode in copy mode
set -g history-limit 1000000  # Large scrollback buffer
set -g set-clipboard on       # System clipboard integration
set -g escape-time 0          # No escape delay (better vim experience)
```

### Split Panes

```conf
bind | split-window -h -c "#{pane_current_path}"  # Split right
bind - split-window -v -c "#{pane_current_path}"  # Split down
```

**New panes open in current directory!**

### Pane Borders

```conf
set -g pane-active-border-style 'fg=magenta,bg=default'
set -g pane-border-style 'fg=brightblack,bg=default'
```

## Customization

### Change Prefix Key

Edit `tmux.conf`:

```conf
unbind C-a
set -g prefix C-b  # Back to default
# or
set -g prefix C-Space  # Space as prefix
```

Then reload: `Ctrl+A` `:source-file ~/.config/tmux/tmux.conf`

### Change Split Keybindings

```conf
bind h split-window -h -c "#{pane_current_path}"  # Horizontal split
bind v split-window -v -c "#{pane_current_path}"  # Vertical split
```

### Move Status Bar to Bottom

```conf
set -g status-position bottom  # Change from top
```

### Disable Mouse

```conf
set -g mouse off  # Disable mouse support
```

### Change Theme

**Try different Catppuccin variants:**

```bash
# Available: mocha, macchiato, frappe, latte
set -g @catppuccin_flavour 'macchiato'
```

### Add Custom Status Modules

**Available modules:**
- `session`
- `user`
- `host`
- `date_time`
- `directory`
- `uptime`
- `battery`
- `cpu`
- `weather`

**Example:**
```conf
set -g @catppuccin_status_modules_right "directory battery date_time"
```

### Change Time Format

```conf
set -g @catppuccin_date_time_text "%I:%M %p"  # 12-hour format
```

## Troubleshooting

### Colors not working

```bash
# Check terminal supports true color
echo $TERM  # Should be xterm-256color or similar

# Test true color
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# Set TERM in shell config
export TERM=xterm-256color
```

### Plugins not loading

```bash
# Check TPM installed
ls ~/.config/tmux/plugins/tpm

# Reload plugins
# In tmux: Ctrl+A then I (capital i)

# Or reload config
tmux source-file ~/.config/tmux/tmux.conf
```

### Vim navigation not working

```bash
# Check vim-tmux-navigator plugin installed
ls ~/.config/tmux/plugins/vim-tmux-navigator

# Ensure Neovim plugin configured
# See nvim/README.md for setup
```

### Clipboard not working

```bash
# Install clipboard tool
# For X11:
sudo pacman -S xclip

# For Wayland:
sudo pacman -S wl-clipboard

# Test clipboard
echo "test" | tmux load-buffer -
tmux save-buffer - | xclip -selection clipboard
```

### SessionX not showing

```bash
# Check dependencies
which fzf
which zoxide

# Install if missing
sudo pacman -S fzf zoxide

# Test keybinding
# In tmux: Ctrl+A then o
```

### Status bar not showing

```bash
# Check status enabled
tmux show-option -g status  # Should be "on"

# Enable if disabled
tmux set-option -g status on

# Reload catppuccin theme
tmux run ~/.config/tmux/plugins/catppuccin-tmux/catppuccin.tmux
```

## Advanced Features

### Resurrect Sessions

**Plugin:** `tmux-resurrect` (not currently configured)

**Add to config:**
```conf
set -g @plugin 'tmux-plugins/tmux-resurrect'

# Save: Ctrl+A Ctrl+s
# Restore: Ctrl+A Ctrl+r
```

### Continuum (Auto-save)

**Plugin:** `tmux-continuum`

**Add to config:**
```conf
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'  # Auto-restore on tmux start
```

### Floating Windows

**Plugin:** `tmux-floax` (already installed)

**Usage:** Check plugin docs for keybindings

### Custom Scripts

**Add calendar to status bar:**

1. Create `~/.config/tmux/scripts/cal.sh`:
   ```bash
   #!/bin/bash
   gcalcli --nocolor agenda now 1h
   ```

2. Enable in config:
   ```conf
   set -g @catppuccin_meetings_text "#($HOME/.config/tmux/scripts/cal.sh)"
   ```

## Performance Tips

**For large terminals:**

```conf
set -g history-limit 50000  # Reduce from 1000000
```

**Disable aggressive resize:**

```conf
setw -g aggressive-resize off
```

## Workflow Tips

### Session per Project

```bash
# Create project session
tmux new -s myproject -c ~/projects/myproject

# Name windows by function
Ctrl+A r "editor"
Ctrl+A c  # New window
Ctrl+A r "server"
Ctrl+A c
Ctrl+A r "tests"
```

### Use SessionX for Quick Switching

1. `Ctrl+A` `o`
2. Type project name
3. `Enter`

**Or use zoxide shortcuts:**
- SessionX shows recently visited directories
- Create sessions on-the-fly

### Dotfiles Workflow

**Quick access configured:**
```conf
set -g @sessionx-custom-paths '~/dotfiles'
```

Press `Ctrl+A` `o` and select `dotfiles`.

## Keybinding Reference

**Most used commands:**

```
Ctrl+A o        - SessionX (session switcher)
Ctrl+A |        - Split pane right
Ctrl+A -        - Split pane down
Ctrl+A [        - Copy mode
Ctrl+A ]        - Paste buffer
Ctrl+A z        - Toggle zoom
Ctrl+A d        - Detach session

Ctrl+h/j/k/l    - Navigate panes/vim
Ctrl+N          - Obsidian new note
Ctrl+Q          - Obsidian search

(In copy mode)
v               - Begin selection
y               - Copy and exit
q               - Exit copy mode
```

## Links

- [Tmux GitHub](https://github.com/tmux/tmux)
- [Tmux Wiki](https://github.com/tmux/tmux/wiki)
- [TPM (Plugin Manager)](https://github.com/tmux-plugins/tpm)
- [Catppuccin Tmux](https://github.com/catppuccin/tmux)
- [SessionX](https://github.com/omerxx/tmux-sessionx)
- [Vim-Tmux Navigator](https://github.com/christoomey/vim-tmux-navigator)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)

---

_Last Updated: 2025-10-10_
