# Waybar Configuration

Catppuccin Mocha themed status bar for Hyprland with custom scripts and modules.

## Features

- **Catppuccin Mocha Theme** - Cohesive color scheme with custom CSS
- **Custom Scripts** - CPU temp, WiFi status, media player, system updates
- **Hyprland Integration** - Workspace switcher, window titles
- **System Information** - CPU, memory, temperature, battery
- **Connectivity** - WiFi, Bluetooth, network management
- **Media Controls** - Now playing with album art
- **Notification Center** - SwayNC integration
- **Power Menu** - Shutdown, reboot, suspend, lock

## Dependencies

**Required:**
- `waybar` - Status bar
- `hyprland` - Window manager
- `swaync` - Notification center

**Recommended:**
- `python3` - For custom scripts
- `jq` - JSON processing
- `playerctl` - Media control
- `brightnessctl` - Brightness control
- `networkmanager` - Network management
- `bluez` - Bluetooth
- `wireplumber` or `pipewire` - Audio

**Optional:**
- `bluetui` - Bluetooth TUI (for right-click menu)
- `nmtui` - NetworkManager TUI (for right-click menu)
- `ghostty` - Terminal for launching TUIs

## Configuration Files

```
waybar/
├── config.jsonc       # Main configuration
├── style.css          # Styling with Catppuccin
├── theme.css          # Color variables
└── scripts/
    ├── cpu-temp.sh           # CPU temperature
    ├── cpu-usage.sh          # CPU usage percentage
    ├── wifi-status.sh        # WiFi connection status
    ├── wifi-menu.sh          # WiFi network selector
    ├── bluetooth-menu.sh     # Bluetooth device selector
    ├── system-update.sh      # Package update checker
    ├── media-player.py       # Now playing info
    ├── volume-control.sh     # Audio volume control
    ├── brightness-control.sh # Screen brightness
    └── power-menu.sh         # Power options menu
```

## Modules

### Left Bar

**Window Info:**
- Custom window icon
- Hyprland workspaces (1-10 per monitor)
- Active window title with app-specific icons
- Submap indicator (for special modes)

### Center Bar

**System Monitoring:**
- CPU temperature
- Memory usage with warnings (75% warning, 90% critical)
- CPU usage percentage
- Idle inhibitor (presentation mode toggle)

**Time & Date:**
- 24-hour time format
- Month-day date
- Calendar popup on click

**Connectivity:**
- WiFi status with signal strength
- Bluetooth device counter
- System update indicator
- Notification center toggle

### Right Bar

**System Tray:**
- Application tray icons

**Media:**
- Now playing (artist - title)
- Play/pause on click

**Audio & Display:**
- Output device with volume
- Brightness control (for laptops)
- Battery status with icons

**Power:**
- Power menu button

## Custom Scripts

### CPU Temperature (`cpu-temp.sh`)

Reads CPU temperature from `/sys/class/thermal/`.

**Output:** JSON with temperature and tooltip
```json
{
  "text": "🌡️ 45°C",
  "tooltip": "CPU Temperature: 45°C"
}
```

### WiFi Status (`wifi-status.sh`)

Shows WiFi connection using NetworkManager.

**Output:** JSON with connection status
```json
{
  "text": "󰤨",
  "tooltip": "WiFi: MyNetwork (80%)"
}
```

**Click:** Opens WiFi menu (`wifi-menu.sh`)
**Right-click:** Opens `nmtui` in terminal

### Bluetooth Menu (`bluetooth-menu.sh`)

Interactive Bluetooth device selector using `rofi`.

**Features:**
- List paired devices
- Connect/disconnect devices
- Power on/off Bluetooth

**Right-click:** Opens `bluetui` in terminal

### System Update (`system-update.sh`)

Checks for package updates (Arch Linux).

**Output:**
- ` ` - Updates available (shows count)
- `` - System up to date

**Click:** Opens update terminal and runs `yay` (or `pacman`)

**Manual refresh:** `pkill -RTMIN+20 waybar`

### Media Player (`media-player.py`)

Shows now playing information from `playerctl`.

**Output:** `Artist - Title` (truncated to 35 chars)

**Click:** Play/pause

**Supports:** Spotify, Tidal, VLC, Firefox, etc.

### Volume Control (`volume-control.sh`)

Controls audio volume with `wpctl` (WirePlumber).

**Usage:**
- Scroll up: Increase volume
- Scroll down: Decrease volume
- Click: Toggle mute

### Brightness Control (`brightness-control.sh`)

Controls screen brightness with `brightnessctl`.

**Usage:**
- Scroll up: Increase brightness
- Scroll down: Decrease brightness

### Power Menu (`power-menu.sh`)

Shows power options with `rofi`.

**Options:**
- 󰤄 Shutdown
- 󰜉 Reboot
- 󰒲 Suspend
- 󰌾 Lock

## Theming

### Color Scheme (Catppuccin Mocha)

**Main Colors:**
- Base: `#1e1e2e` (background)
- Text: `#cdd6f4` (foreground)
- Crust: `#11111b` (dark background)

**Module Colors:**
- Workspaces: `#fab387` (peach)
- CPU Info: `#f9e2af` (yellow)
- Memory: `#a6e3a1` (green)
- CPU: `#89b4fa` (blue)
- Distro: `#cba6f7` (mauve)
- Time: `#fab387` (peach)
- Date: `#f38ba8` (red)
- Tray: `#94e2d5` (teal)
- Audio: `#f5c2e7` (pink)
- Brightness: `#f9e2af` (yellow)
- Battery: `#a6e3a1` (green)
- Power: `#f38ba8` (red)

### Custom Styling

Edit `style.css` to customize:
- Font (default: JetBrainsMono Nerd Font)
- Padding and margins
- Border radius
- Module backgrounds
- Hover effects

Edit `theme.css` to change colors:
```css
@define-color workspaces #fab387;
@define-color cpuinfo #f9e2af;
/* ... */
```

## Window Title Rewriting

Waybar rewrites window titles with icons:

| Application | Icon | Pattern |
|-------------|------|---------|
| Terminal | `` | `ghostty`, `zsh`, `~` |
| Firefox | `󰈹` | `Mozilla Firefox` |
| Zen Browser | `󰈹` | `Zen Browser` |
| VS Code | `󰨞` | `Visual Studio Code` |
| Discord | `` | `Discord`, `vesktop` |
| Spotify | `` | `Spotify` |
| Tidal | `󰎆` | `TIDAL` |
| Godot | `` | `Godot Engine` |

Add more patterns in `config.jsonc` under `hyprland/window.rewrite`.

## Troubleshooting

### Waybar not loading

```bash
# Check for syntax errors
waybar --config ~/.config/waybar/config.jsonc --check

# View logs
waybar --log-level debug
```

### Scripts not executing

```bash
# Make scripts executable
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.py

# Test script manually
~/.config/waybar/scripts/cpu-temp.sh
```

### Module not showing

Check `config.jsonc`:
- Module is in `modules-left/center/right`
- Module configuration exists
- Dependencies are installed

### Theme not applied

```bash
# Reload CSS
pkill -SIGUSR2 waybar

# Or restart waybar
pkill waybar && waybar &
```

### WiFi/Bluetooth not working

```bash
# Check NetworkManager
systemctl status NetworkManager

# Check Bluetooth
systemctl status bluetooth

# Enable services
systemctl enable --now NetworkManager
systemctl enable --now bluetooth
```

## Customization

### Add New Module

1. **Edit `config.jsonc`:**
   ```json
   "modules-right": [
     "custom/my-module",
     ...
   ],

   "custom/my-module": {
     "exec": "~/.config/waybar/scripts/my-script.sh",
     "return-type": "json",
     "format": "{}",
     "interval": 60
   }
   ```

2. **Create script:**
   ```bash
   #!/bin/bash
   echo '{"text":"My Text","tooltip":"My Tooltip"}'
   ```

3. **Make executable:**
   ```bash
   chmod +x ~/.config/waybar/scripts/my-script.sh
   ```

4. **Reload waybar:**
   ```bash
   pkill -SIGUSR2 waybar
   ```

### Change Update Interval

Edit `config.jsonc` and change `interval` (in seconds):
```json
"custom/cpuinfo": {
  "interval": 10  # Update every 10 seconds
}
```

### Disable Module

Comment out in `modules-*`:
```json
"modules-right": [
  // "custom/media",  # Disabled
  "pulseaudio"
]
```

## Performance

**Polling Intervals (Battery Life):**
- WiFi: 5s (reduced from 1s)
- Bluetooth: 5s (reduced from 1s)
- Brightness: 3s (reduced from 1s)
- Battery: 1s (needed for accuracy)

**To reduce CPU usage:**
- Increase intervals in `config.jsonc`
- Disable unused modules
- Use `interval` instead of `exec-if` where possible

## Links

- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [Waybar Configuration](https://github.com/Alexays/Waybar/wiki/Configuration)
- [Catppuccin Waybar](https://github.com/catppuccin/waybar)

---

_Last Updated: 2025-10-10_
