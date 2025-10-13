# Wofi Configuration

Wofi is a Wayland-native launcher and dmenu replacement used for all interactive menus in this setup.

## Migration from Rofi

This configuration was migrated from rofi due to better Wayland compatibility with Hyprland. Rofi had issues with focus and window management when launched from Waybar in Hyprland environments.

## Menu Scripts

All waybar menu scripts now use wofi:

- **power-menu.sh** - System power options (lock, shutdown, reboot, suspend, hibernate, logout)
- **wifi-menu.sh** - WiFi network selection and connection
- **bluetooth-menu.sh** - Bluetooth device management
- **wofi-update-manager.sh** - System package updates (pacman, AUR, flatpak)

## Theme Files

Each menu has its own CSS theme file in Catppuccin Mocha colors:

- `power-menu.css` - Compact northeast positioned menu
- `wifi-menu.css` - Medium width menu with input bar
- `bluetooth-menu.css` - Medium width menu with input bar
- `update-manager.css` - Wide center menu for update lists
- `style.css` - Base Catppuccin Mocha theme for application launcher
- `config` - Main wofi configuration

## Key Differences from Rofi

- **Styling**: CSS instead of rasi format
- **Parameters**: Different flag names (e.g., `--dmenu` vs `-dmenu`, `--style` vs `-config`)
- **Dynamic Styling**: No equivalent to rofi's `-theme-str`, handled via prompt text and separate CSS files
- **Markup**: Wofi supports pango markup natively without special flags
- **Positioning**: Done via CSS and `--location` parameter

## Testing

To test individual menus:

```bash
# Power menu
~/.config/waybar/scripts/power-menu.sh

# WiFi menu
~/.config/waybar/scripts/wifi-menu.sh

# Bluetooth menu
~/.config/waybar/scripts/bluetooth-menu.sh

# Update manager
~/.config/waybar/scripts/wofi-update-manager.sh
```

## Backup

Old rofi scripts are backed up with `.backup` extension in:
`~/.config/waybar/scripts/`
