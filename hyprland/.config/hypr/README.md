# Hyprland Configuration

Professional Catppuccin Mocha themed Wayland compositor configuration with dual monitor support and advanced workspace management.

## Features

- **Catppuccin Mocha Theme** - Cohesive color scheme across all components
- **Dual Monitor Setup** - Independent workspaces per monitor
- **Split-Monitor-Workspaces** - 10 workspaces per monitor (20 total)
- **Dynamic Wallpapers** - Automated wallpaper management with random switching
- **Hyprlock Integration** - Themed lock screen with current wallpaper
- **Hypridle** - Auto-lock after 15 minutes of inactivity
- **Vim-Style Navigation** - hjkl window focus movement
- **Smooth Animations** - Custom bezier curves for buttery transitions
- **Screenshot Support** - Region, window, and full-screen capture
- **Multimedia Keys** - Volume, brightness, and media control

## Dependencies

**Required:**
- `hyprland` - Wayland compositor
- `hyprpaper` - Wallpaper daemon
- `hyprlock` - Screen locker
- `hypridle` - Idle management daemon
- `hyprpm` - Plugin manager
- `ghostty` - Terminal emulator
- `waybar` - Status bar
- `swaync` - Notification daemon
- `rofi-wayland` - Application launcher

**Recommended:**
- `hyprshot` - Screenshot tool
- `grim` - Screenshot backend
- `slurp` - Region selection
- `playerctl` - Media control
- `brightnessctl` - Brightness control
- `wpctl` (WirePlumber) - Audio control
- `nautilus` - File manager
- `qt6ct` - QT theme configuration

**Plugins:**
- `split-monitor-workspaces` - Per-monitor workspace management

## Configuration Files

```
hypr/
├── hyprland.conf                    # Main configuration
├── hyprpaper.conf                   # Auto-generated wallpaper config
├── hyprlock.conf                    # Lock screen configuration
├── hypridle.conf                    # Idle timeout configuration
├── mocha.conf                       # Catppuccin Mocha color definitions
├── generate_hyprpaper_config.sh     # Wallpaper preloader script
└── change_wallpaper.sh              # Random wallpaper switcher
```

## Monitor Setup

### Dual Monitor Configuration

This configuration is optimized for a laptop + external monitor setup:

```conf
monitor = DP-1, preferred, 0x0, 1        # External monitor (top)
monitor = eDP-1, preferred, 0x1080, 1    # Laptop screen (bottom)
monitor = Virtual-1, preferred, auto, 1  # Virtual displays
```

**Layout:**
```
┌─────────────────┐
│     DP-1        │  External Monitor (0, 0)
│  Workspaces 1-10│
└─────────────────┘
┌─────────────────┐
│    eDP-1        │  Laptop Screen (0, 1080)
│  Workspaces 1-10│
└─────────────────┘
```

**Independent Workspaces:**
- Each monitor has its own set of workspaces (1-10)
- Workspace 1 on eDP-1 is different from workspace 1 on DP-1
- Total of 20 workspaces (10 per monitor)

### Single Monitor

For single monitor setups, the configuration automatically adapts:

```conf
monitor = , preferred, auto, auto
```

## Workspace Management

### Split-Monitor-Workspaces Plugin

**Configuration:**
```conf
plugin {
    split-monitor-workpaces {
        count = 10                          # Workspaces per monitor
        keep_focused = 0                    # Don't keep focus on monitor switch
        enable_notifications = 0            # Disable notifications
        enable_persistent_workspace = 1     # Keep workspaces persistent
    }
}
```

**Benefits:**
- Each monitor maintains independent workspace numbering
- No confusion with workspace overlap
- Consistent workflow across monitors

### Workspace Navigation

**Switch workspaces** (on current monitor):
```
ALT + 1-9/0  → Switch to workspace 1-10
```

**Move windows to workspace:**
```
ALT + SHIFT + 1-9/0  → Move active window to workspace
```

**Special workspace (scratchpad):**
```
ALT + S              → Toggle scratchpad visibility
ALT + SHIFT + S      → Move window to scratchpad
```

## Window Management

### Vim-Style Navigation

**Focus windows:**
```
ALT + h  → Focus left
ALT + j  → Focus down
ALT + k  → Focus up
ALT + l  → Focus right
```

### Window Actions

```
ALT + Return         → Open terminal
ALT + Q              → Kill active window
ALT + V              → Toggle floating
ALT + P              → Pseudo-tile (dwindle)
ALT + J              → Toggle split (dwindle)
```

### Monitor Management

**Move windows between monitors:**
```
ALT + SHIFT + k  → Move window to laptop screen (eDP-1)
ALT + SHIFT + j  → Move window to external monitor (DP-1)
```

**Focus monitors:**
```
ALT + ,  → Focus laptop screen
ALT + .  → Focus external monitor
```

### Mouse Controls

```
ALT + LMB Drag   → Move window
ALT + RMB Drag   → Resize window
ALT + Scroll     → Switch workspaces
```

## Keybindings Reference

### Applications

| Key | Action |
|-----|--------|
| `ALT + Return` | Terminal (ghostty) |
| `ALT + E` | File manager (nautilus) |
| `ALT + Space` | App launcher (rofi drun) |
| `ALT + C` | Calculator (rofi calc) |
| `ALT + ;` | Emoji picker (rofi emoji) |

### System

| Key | Action |
|-----|--------|
| `ALT + SHIFT + L` | Lock screen (hyprlock) |
| `ALT + SHIFT + W` | Random wallpaper |
| `ALT + N` | Toggle notification center |
| `ALT + M` | Exit Hyprland |

### Screenshots

| Key | Action |
|-----|--------|
| `Print` | Full screen |
| `SHIFT + Print` | Region selection |
| `CTRL + Print` | Active window |
| `ALT + Print` | Active monitor |
| `ALT + SHIFT + P` | Region (alternative) |

### Multimedia Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Increase volume 5% |
| `XF86AudioLowerVolume` | Decrease volume 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone |
| `XF86MonBrightnessUp` | Increase brightness 10% |
| `XF86MonBrightnessDown` | Decrease brightness 10% |
| `XF86AudioPlay` | Play/pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

## Wallpaper Management

### Wallpaper Directory

**Location:** `~/wallpapers/`

**Supported formats:** `.jpg`, `.png`, `.jpeg`

### Setup Wallpapers

1. **Create wallpaper directory:**
   ```bash
   mkdir -p ~/wallpapers
   ```

2. **Add wallpapers:**
   ```bash
   cp /path/to/your/images/* ~/wallpapers/
   ```

3. **Generate configuration:**
   ```bash
   ~/.config/hypr/generate_hyprpaper_config.sh
   ```

### Generate Hyprpaper Config

**Script:** `generate_hyprpaper_config.sh`

**What it does:**
- Scans `~/wallpapers/` for image files
- Preloads all wallpapers into memory
- Sets random wallpaper for all monitors
- Creates symlink at `~/.cache/current_wallpaper` (for hyprlock)
- Restarts hyprpaper daemon

**When to run:**
- After adding new wallpapers
- When wallpapers aren't displaying
- On first installation

### Change Wallpaper Randomly

**Keybinding:** `ALT + SHIFT + W`

**Script:** `change_wallpaper.sh`

**What it does:**
- Picks random wallpaper from `~/wallpapers/`
- Applies to all monitors
- Updates lock screen wallpaper
- No hyprpaper restart needed

## Lock Screen (Hyprlock)

### Features

- **Current wallpaper** as background (blurred)
- **Time display** - Updates every 30 seconds
- **Date display** - Updates twice daily
- **User avatar** - From `~/.face` (optional)
- **Password input** - Catppuccin themed
- **Caps lock indicator** - Yellow highlight

### Configuration

**File:** `hyprlock.conf`

**Colors:**
- Accent: Mauve (`#cba6f7`)
- Background: Base (`#1e1e2e`)
- Input field: Surface0 (`#313244`)
- Text: Text (`#cdd6f4`)

### Auto-lock

**File:** `hypridle.conf`

**Settings:**
- Timeout: 15 minutes (900 seconds)
- Action: Lock session
- Resume: Shows notification

**Disable auto-lock:**
```bash
systemctl --user stop hypridle
```

**Re-enable:**
```bash
systemctl --user start hypridle
```

## Styling & Theming

### Window Appearance

**Gaps:**
```conf
gaps_in = 5    # Gap between windows
gaps_out = 20  # Gap from screen edge
```

**Borders:**
```conf
border_size = 2
col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
col.inactive_border = rgba(595959aa)
```

**Rounded Corners:**
```conf
rounding = 10  # 10px radius
```

### Decorations

**Shadows:**
```conf
shadow {
    enabled = true
    range = 4
    render_power = 3
    color = rgba(1a1a1aee)
}
```

**Blur:**
```conf
blur {
    enabled = true
    size = 3
    passes = 1
    vibrancy = 0.1696
}
```

**Opacity:**
```conf
active_opacity = 1.0
inactive_opacity = 1.0
```

### Animations

**Custom bezier curves:**
```conf
bezier = easeOutQuint, 0.23, 1, 0.32, 1
bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
bezier = quick, 0.15, 0, 0.1, 1
```

**Animation timings:**
- Windows: 4.79 (easeOutQuint)
- Window in: 4.1 (pop-in effect)
- Window out: 1.49 (linear)
- Workspaces: 1.94 (fade)
- Borders: 5.39 (smooth color transition)

## Window Rules

### Floating Windows

**System dialogs:**
```conf
windowrule = float, title:^(Open File)$
windowrule = float, title:^(Save File)$
windowrule = float, title:^(Save As)$
windowrule = size 800 600, title:^(Open File)$
```

**System tools:**
```conf
windowrule = float, class:^(pavucontrol)$       # Volume control
windowrule = float, class:^(blueman-manager)$   # Bluetooth
windowrule = float, class:^(nm-connection-editor)$  # Network
```

### Picture-in-Picture

**Firefox PiP:**
```conf
windowrule = float, class:^(firefox)$, title:^(Picture-in-Picture)$
windowrule = pin, class:^(firefox)$, title:^(Picture-in-Picture)$
windowrule = size 800 450, class:^(firefox)$, title:^(Picture-in-Picture)$
```

### General Rules

```conf
# Ignore maximize requests
windowrule = suppressevent maximize, class:.*

# Fix XWayland drag issues
windowrule = nofocus, class:^$, title:^$, xwayland:1, floating:1
```

## Layouts

### Dwindle (Default)

**Features:**
- Binary tree window layout
- Automatic tiling
- Pseudotile support

**Configuration:**
```conf
dwindle {
    pseudotile = true           # Enable pseudotiling
    preserve_split = true       # Maintain split direction
}
```

**Controls:**
- `ALT + P` - Toggle pseudotile
- `ALT + J` - Toggle split direction

### Master Layout

**Alternative layout** (not default):

```conf
master {
    new_status = master  # New windows become master
}
```

## Input Configuration

### Keyboard

```conf
kb_layout = us    # US layout
```

### Mouse

```conf
follow_mouse = 1               # Focus follows mouse
follow_mouse_threshold = 3.0   # Threshold in pixels
sensitivity = 0                # Default sensitivity
accel_profile = adaptive       # Adaptive acceleration
```

### Touchpad

```conf
natural_scroll = false         # Traditional scrolling
disable_while_typing = true    # Prevent accidental touches
tap-to-click = true            # Enable tap-to-click
tap-and-drag = true            # Enable tap-and-drag
middle_button_emulation = false
```

## Environment Variables

### Wayland

```bash
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
XDG_SESSION_DESKTOP=Hyprland
```

### QT/GTK

```bash
QT_QPA_PLATFORMTHEME=qt6ct
QT_AUTO_SCREEN_SCALE_FACTOR=1
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
```

### Cursor

```bash
XCURSOR_SIZE=24
HYPRCURSOR_SIZE=24
```

### NVIDIA (Optional)

Uncomment if using NVIDIA GPU:

```bash
# LIBVA_DRIVER_NAME=nvidia
# __GLX_VENDOR_LIBRARY_NAME=nvidia
# NVD_BACKEND=direct
# WLR_NO_HARDWARE_CURSORS=1
```

## Autostart

**Services launched on startup:**

```conf
exec-once = hyprctl setcursor catppuccin-mocha-dark-cursors 28
exec-once = ~/.config/hypr/generate_hyprpaper_config.sh
exec-once = waybar & swaync & hypridle
exec-once = sleep 1 && hyprpm reload -n
```

**Permissions:**
```conf
permission = /usr/(bin|local/bin)/hyprpm, plugin, allow
permission = /usr/bin/hyprshot, screencopy, allow
permission = /usr/bin/grim, screencopy, allow
permission = /usr/bin/slurp, screencopy, allow
```

## Troubleshooting

### Hyprland won't start

```bash
# Check logs
journalctl --user -u hyprland -b

# Validate configuration
hyprctl reload

# Start from TTY
Hyprland
```

### Wallpaper not showing

```bash
# Check wallpaper directory
ls ~/wallpapers/

# Regenerate config
~/.config/hypr/generate_hyprpaper_config.sh

# Check hyprpaper status
pgrep hyprpaper
```

### Monitor not detected

```bash
# List available monitors
hyprctl monitors

# Check current config
hyprctl monitors all

# Edit monitor configuration in hyprland.conf
```

### Workspaces not switching

```bash
# Check plugin status
hyprpm list

# Reload plugins
hyprpm reload

# Reinstall plugin
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces
```

### Screenshots not working

```bash
# Install dependencies
sudo pacman -S hyprshot grim slurp

# Check permissions
hyprctl reload  # Reload to apply permissions

# Test manually
hyprshot -m region
```

### Animations laggy

Edit `hyprland.conf`:

```conf
# Reduce animation speed
animation = global, 1, 5, default  # Lower number = faster

# Or disable animations
animations {
    enabled = false
}
```

### High memory usage

```bash
# Reduce preloaded wallpapers
# Edit generate_hyprpaper_config.sh to limit wallpapers

# Or disable blur
decoration {
    blur {
        enabled = false
    }
}
```

## Customization

### Change Main Modifier Key

Edit `hyprland.conf`:

```conf
$mainMod = SUPER  # Change to Super (Windows key)
# or
$mainMod = CTRL   # Change to Control
```

### Add New Keybinding

```conf
bind = $mainMod, <key>, <dispatcher>, <params>

# Examples:
bind = $mainMod, B, exec, firefox        # Open Firefox
bind = $mainMod, F, fullscreen,          # Toggle fullscreen
bind = $mainMod SHIFT, M, movetoworkspace, special  # Move to special
```

### Custom Window Rules

```conf
# Make specific app always float
windowrule = float, class:^(myapp)$

# Set specific size
windowrule = size 1920 1080, class:^(myapp)$

# Move to specific workspace
windowrule = workspace 5, class:^(myapp)$

# Set opacity
windowrulev2 = opacity 0.9, class:^(myapp)$
```

### Change Colors

Edit `mocha.conf` for global color changes:

```conf
$accent = $mauve  # Change accent color
# Options: $rosewater, $flamingo, $pink, $mauve, $red, $maroon,
#          $peach, $yellow, $green, $teal, $sky, $sapphire,
#          $blue, $lavender
```

### Adjust Gaps

```conf
general {
    gaps_in = 10   # Larger gaps between windows
    gaps_out = 30  # Larger gaps from edges
}
```

### Smart Gaps (No gaps when only one window)

Uncomment in `hyprland.conf`:

```conf
workspace = w[tv1], gapsout:0, gapsin:0
workspace = f[1], gapsout:0, gapsin:0
windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
```

## Performance Optimization

### For older hardware:

```conf
# Reduce blur
blur {
    size = 2      # Lower blur size
    passes = 1    # Single pass
}

# Simpler animations
animation = global, 1, 5, default
```

### For high refresh rate monitors:

```conf
# Smoother animations
animation = global, 1, 15, default

# Higher blur quality
blur {
    passes = 2
}
```

## Integration with Other Tools

### Waybar

Configuration includes automatic waybar launch. See `waybar/README.md`.

### SwayNC

Notification daemon with Catppuccin theme. See `swaync/README.md`.

### Rofi

Application launcher and menus. See `rofi/README.md`.

## Plugin Management

### Install Plugin

```bash
# Install split-monitor-workspaces
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces
hyprpm enable split-monitor-workspaces
```

### List Plugins

```bash
hyprpm list
```

### Update Plugins

```bash
hyprpm update
```

### Remove Plugin

```bash
hyprpm remove split-monitor-workspaces
```

## Links

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
- [Catppuccin Hyprland](https://github.com/catppuccin/hyprland)
- [Split-Monitor-Workspaces Plugin](https://github.com/Duckonaut/split-monitor-workspaces)

---

_Last Updated: 2025-10-10_
