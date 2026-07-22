# Rofi Configuration

Modern Catppuccin Mocha themed application launcher and menu system for Hyprland.

## Features

- **Catppuccin Mocha Theme** - Cohesive lavender-accented design
- **Multiple Modi** - Application launcher, command runner, calculator, emoji picker, window switcher
- **Custom Menus** - Power, WiFi, and Bluetooth menus integrated with Waybar
- **Icon Support** - Papirus-Dark icon theme integration
- **Ghostty Integration** - Launches terminal applications seamlessly
- **Modern Styling** - Rounded corners, smooth animations, clean layout

## Dependencies

**Required:**
- `rofi-wayland` - Wayland-compatible rofi build
- `papirus-icon-theme` - Icon theme

**Recommended:**
- `ghostty` - Terminal emulator (for terminal applications)
- `nerd-fonts` - For icon glyphs in menus

## Configuration Files

```
rofi/
├── config.rasi           # Main configuration
├── catppuccin.rasi       # Primary Catppuccin theme (modern)
├── catppuccin-mocha.rasi # Alternative Catppuccin theme
├── theme.rasi            # Base color variables
├── power-menu.rasi       # Power options menu theme
├── wifi-menu.rasi        # WiFi network selector theme
└── bluetooth-menu.rasi   # Bluetooth device menu theme
```

## Modi (Application Modes)

### 1. Application Launcher (drun)

**Launch:** `rofi -show drun`

**Features:**
- Shows installed desktop applications
- Icon support with Papirus-Dark theme
- Format: `{icon} {name}`
- Display label: "   Apps "

**Keybindings:**
- Type to search applications
- Enter to launch
- Tab to switch between modi

### 2. Command Runner (run)

**Launch:** `rofi -show run`

**Features:**
- Execute shell commands directly
- Command history
- Display label: "   Run "

**Use Cases:**
- Quick command execution
- Scripts without desktop entries
- System commands

### 3. Calculator (calc)

**Launch:** `rofi -show calc`

**Features:**
- Built-in calculator mode
- Real-time calculation
- Display label: " 󰃬  Calc"

**Examples:**
```
2 + 2
sqrt(16)
log(100)
```

### 4. Emoji Picker (emoji)

**Launch:** `rofi -show emoji`

**Features:**
- Browse and select emojis
- Search by name
- Display label: " 󰞅  Emoji"
- Copies emoji to clipboard

### 5. Window Switcher (window)

**Launch:** `rofi -show window`

**Features:**
- Switch between open windows
- Shows window title and workspace
- Display label: " 﩯  Window"

## Custom Menus

### Power Menu

**Location:** `~/.config/waybar/scripts/power-menu.sh`

**Options:**
- 󰤄 Shutdown - `systemctl poweroff`
- 󰜉 Reboot - `systemctl reboot`
- 󰒲 Suspend - `systemctl suspend`
- 󰜛 Hibernate - `systemctl hibernate`
- 󰌾 Lock - `hyprlock`
- 󰍃 Logout - Exit Hyprland session

**Trigger:** Click power icon in Waybar

**Theme:** Compact northeast corner menu (150px wide)

### WiFi Menu

**Location:** `~/.config/waybar/scripts/wifi-menu.sh`

**Features:**
- List available networks
- Connect/disconnect
- Signal strength indicators
- Search functionality

**Trigger:** Click WiFi icon in Waybar

**Theme:** Top-anchored menu with search bar (240px wide)

### Bluetooth Menu

**Location:** `~/.config/waybar/scripts/bluetooth-menu.sh`

**Features:**
- List paired devices
- Connect/disconnect devices
- Power Bluetooth on/off

**Trigger:** Click Bluetooth icon in Waybar

## Theming

### Color Scheme (Catppuccin Mocha)

**Primary Theme (`catppuccin.rasi`):**

| Element | Color | Variable |
|---------|-------|----------|
| Background | `#1e1e2e` | `@bg` |
| Foreground | `#cdd6f4` | `@fg` |
| Border | `#b4befe` (lavender) | `@lavender` |
| Selected | `#45475a` (surface1) | `@surface1` |
| Selected Text | `#b4befe` (lavender) | `@lavender` |
| Input Background | `#313244` (surface0) | `@surface0` |
| Prompt | `#b4befe` (lavender) | `@lavender` |

**Base Theme (`theme.rasi`):**

Used by custom menus (power, wifi, bluetooth):

```rasi
main-bg:    #11111b  /* crust */
main-fg:    #cdd6f4  /* text */
main-br:    #9399b2  /* overlay2 */
input-bg:   #181825  /* mantle */
select-bg:  #9399b2  /* overlay2 */
select-fg:  #11111b  /* crust */
```

### Visual Style

**Window:**
- Width: 600px (main), 150-240px (custom menus)
- Border radius: 16px (main), 10px (menus)
- Border: 2px solid lavender
- Location: Center (main), contextual (menus)

**Elements:**
- Icon size: 48px
- Element padding: 12px
- Border radius: 10px (elements), 8px (buttons)
- List lines: 8 (main), 6 (menus)

**Input Bar:**
- Rounded background (12px radius)
- Lavender prompt badge
- Placeholder: "Search..."

**Mode Switcher:**
- Bottom tabs for switching between modi
- Active tab highlighted in lavender

## Keybindings

### Global Navigation

- **Tab** - Switch to next mode
- **Shift+Tab** - Switch to previous mode
- **Esc** - Close rofi
- **Enter** - Select item
- **Ctrl+Enter** - Run in terminal (for commands)

### Search & Selection

- **Type** - Filter/search items
- **↑/↓** or **Ctrl+k/j** - Navigate items
- **Page Up/Down** - Scroll by page
- **Home/End** - Jump to first/last

### Custom Actions

- **Ctrl+Space** - Show actions menu (mode-specific)
- **Shift+Delete** - Remove from history (for run mode)

## Integration with Hyprland

### Launch Rofi

Add to `hyprland.conf`:

```conf
# Application launcher
bind = ALT, R, exec, rofi -show drun

# Window switcher
bind = ALT, Tab, exec, rofi -show window

# Emoji picker
bind = ALT, period, exec, rofi -show emoji

# Calculator
bind = ALT, C, exec, rofi -show calc
```

### Waybar Integration

Custom menus are triggered from Waybar modules:

```jsonc
"custom/power": {
  "format": " ⏻ ",
  "on-click": "~/.config/waybar/scripts/power-menu.sh"
},

"network": {
  "on-click": "~/.config/waybar/scripts/wifi-menu.sh"
},

"bluetooth": {
  "on-click": "~/.config/waybar/scripts/bluetooth-menu.sh"
}
```

## Configuration Options

### Main Config (`config.rasi`)

```rasi
configuration {
    modi: "drun,run,calc,emoji,window";  // Available modes
    icon-theme: "Papirus-Dark";          // Icon set
    show-icons: true;                     // Enable icons
    terminal: "ghostty";                  // Terminal emulator
    location: 0;                          // Center (0-8)
    hide-scrollbar: true;                 // Clean look
    sidebar-mode: true;                   // Show mode tabs
    font: "CaskaydiaCove Nerd Font 14";  // UI font
}
```

### Display Formats

Customize mode labels:

```rasi
display-drun: "   Apps ";
display-run: "   Run ";
display-calc: " 󰃬  Calc";
display-emoji: " 󰞅  Emoji";
display-window: " 﩯  Window";
```

## Customization

### Change Theme Colors

Edit `catppuccin.rasi`:

```rasi
* {
    bg: #1e1e2e;           /* Background */
    fg: #cdd6f4;           /* Text color */
    lavender: #b4befe;     /* Accent color */
}
```

### Adjust Window Size

Edit `catppuccin.rasi`:

```rasi
window {
    width: 600px;          /* Change width */
    border-radius: 16px;   /* Change roundness */
}
```

### Change List Length

```rasi
listview {
    lines: 8;              /* Number of visible items */
}
```

### Add New Mode

1. **Install rofi plugin** (e.g., `rofi-calc`)
2. **Add to modi list:**
   ```rasi
   modi: "drun,run,calc,emoji,window,mynewmode";
   ```
3. **Add display format:**
   ```rasi
   display-mynewmode: "  Icon Text";
   ```

### Create Custom Menu

1. **Create theme file:**
   ```bash
   cp wifi-menu.rasi my-menu.rasi
   ```

2. **Customize styling in `my-menu.rasi`**

3. **Create launcher script:**
   ```bash
   #!/usr/bin/env bash
   config="$HOME/.config/rofi/my-menu.rasi"

   options="Option 1\nOption 2\nOption 3"

   selected=$(echo -e "$options" | rofi -dmenu -i -config "$config")

   case "$selected" in
     "Option 1") command1 ;;
     "Option 2") command2 ;;
   esac
   ```

## Troubleshooting

### Rofi not launching

```bash
# Test configuration syntax
rofi -dump-config

# Check for errors
rofi -show drun -no-lazy-grab
```

### Icons not showing

```bash
# Install Papirus icons
sudo pacman -S papirus-icon-theme

# Refresh icon cache
gtk-update-icon-cache
```

### Wrong terminal opens

Edit `config.rasi`:
```rasi
terminal: "ghostty";  # Change to your terminal
```

### Theme not applied

```bash
# Check theme path
rofi -dump-theme

# Verify theme file exists
ls ~/.config/rofi/catppuccin.rasi

# Test with explicit theme
rofi -show drun -theme ~/.config/rofi/catppuccin.rasi
```

### Custom menu not working

```bash
# Make script executable
chmod +x ~/.config/waybar/scripts/power-menu.sh

# Test script directly
~/.config/waybar/scripts/power-menu.sh

# Check rofi theme exists
ls ~/.config/rofi/power-menu.rasi
```

### Emoji mode not available

```bash
# Install rofi-emoji plugin (if needed)
yay -S rofi-emoji

# Or use rofimoji
yay -S rofimoji
```

## Performance Tips

**For faster startup:**

```rasi
configuration {
    disable-history: false;  // Set to true to disable history
    sorting-method: "fzf";   // Faster fuzzy matching
}
```

**For better responsiveness:**

```rasi
configuration {
    lazy-grab: true;         // Grab keyboard lazily
    matching: "fuzzy";       // Use fuzzy matching
}
```

## Advanced Features

### Command-line Usage

```bash
# Launch specific mode
rofi -show drun

# Use dmenu mode with custom prompt
echo -e "Option 1\nOption 2\nOption 3" | rofi -dmenu -p "Select:"

# Custom theme
rofi -show drun -theme ~/.config/rofi/catppuccin.rasi

# Case insensitive search
rofi -show drun -i

# Show only matching
rofi -show drun -matching fuzzy
```

### Scripting Examples

**Simple selection menu:**
```bash
#!/usr/bin/env bash
choice=$(echo -e "Yes\nNo\nMaybe" | rofi -dmenu -p "Choose:")
echo "You selected: $choice"
```

**File selector:**
```bash
#!/usr/bin/env bash
file=$(ls | rofi -dmenu -p "Select file:")
[[ -n "$file" ]] && xdg-open "$file"
```

## Links

- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Rofi Wayland](https://github.com/lbonn/rofi)
- [Catppuccin Rofi](https://github.com/catppuccin/rofi)
- [Papirus Icons](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)

---

_Last Updated: 2025-10-10_
