# SwayNC Configuration

Modern Catppuccin Mocha themed notification center for Wayland with rich widget support and custom styling.

## Features

- **Catppuccin Mocha Theme** - Complete color scheme integration
- **Notification Center** - Panel with notification history
- **Do Not Disturb** - Toggle to silence notifications
- **Priority-Based Styling** - Visual distinction for low/normal/critical notifications
- **Action Buttons** - Clickable notification actions
- **Rich Widgets** - DND toggle, power menu, quick settings
- **Custom Categories** - Special styling for specific notification types (e.g., Mastodon)
- **Keyboard Shortcuts** - Control center navigation
- **Relative Timestamps** - "5 minutes ago" format
- **Smooth Animations** - 200ms transitions

## Dependencies

**Required:**
- `swaync` - Notification daemon for Wayland

**Recommended:**
- `hyprland` - Window manager (for hyprlock integration)
- `networkmanager` - For network quick action
- `blueman` - For Bluetooth quick action

## Configuration Files

```
swaync/
├── config.json  # Main configuration (behavior, widgets)
└── style.css    # Catppuccin Mocha theme
```

## Control Center

### Opening the Control Center

**From Waybar:**
- Click notification icon in Waybar

**From Hyprland:**
```conf
bind = ALT, N, exec, swaync-client -t -sw
```

**From Command Line:**
```bash
# Toggle notification center
swaync-client -t -sw

# Open notification center
swaync-client -op

# Close notification center
swaync-client -cp
```

### Layout

**Position:** Top-right corner

**Dimensions:**
- Width: 500px
- Height: 600px
- Margins: 10px

**Widgets (in order):**
1. Title - "Notifications" with "Clear All" button
2. Do Not Disturb toggle
3. Notifications list

### Features

- **Clear All Button** - Dismiss all notifications
- **Scrollable List** - Navigate through notification history
- **Relative Timestamps** - "5 min ago", "1 hour ago"
- **Priority Indicators** - Color-coded borders
- **Hover Effects** - Visual feedback

## Widgets

### Title Widget

**Purpose:** Header with clear all button

**Configuration:**
```json
"title": {
  "text": "Notifications",
  "clear-all-button": true,
  "button-text": " Clear All"
}
```

**Styling:**
- Background: Mantle (`#181825`)
- Text color: Text (`#cdd6f4`)
- Clear button: Surface0 background, mauve border on hover

### Do Not Disturb Widget

**Purpose:** Toggle to silence notifications

**Configuration:**
```json
"dnd": {
  "text": " Do Not Disturb"
}
```

**Behavior:**
- When enabled: Notifications are suppressed (still saved)
- Visual: Purple switch when active
- Notifications still appear in control center

**Styling:**
- Background: Mantle
- Switch: Surface0 (off), Mauve (on)

## Notifications

### Notification Types

#### Low Priority

**Visual:** Green border (`#a6e3a1`)

**Timeout:** 5 seconds

**Use Cases:**
- Background tasks completed
- Non-urgent updates
- System information

**Styling:**
```css
.low {
  border-color: @green;
  background-color: alpha(@green, 0.1);
}
```

#### Normal Priority

**Visual:** Gray border (`#585b70`)

**Timeout:** 10 seconds

**Use Cases:**
- Default notifications
- Application messages
- General alerts

**Styling:**
```css
.notification {
  border-color: @surface2;
}
```

#### Critical Priority

**Visual:** Red border (`#f38ba8`)

**Timeout:** Never (stays until dismissed)

**Use Cases:**
- System errors
- Important alerts
- Security warnings

**Styling:**
```css
.critical {
  border-color: @red;
  background-color: alpha(@red, 0.1);
}
```

### Notification Structure

**Elements:**

1. **App Icon** (64x64px)
   - Rounded corners (8px)
   - Left side of notification

2. **Summary** (Title)
   - Bold, 14px
   - Text color: `#cdd6f4`

3. **Time**
   - Relative timestamp
   - Gray, 11px
   - Right of summary

4. **Body** (Message)
   - Regular, 12px
   - Subtext color: `#a6adc8`

5. **Actions** (Buttons)
   - Custom action buttons
   - Bottom of notification

6. **Close Button**
   - Red circle
   - Top-right corner

### Special Notification Categories

#### Mastodon Notifications (IM)

**Category:** `im.received`

**Visual:** Teal border (`#94e2d5`)

**Styling:**
```css
.notification.im\.received {
  border-color: @teal;
  background-color: alpha(@teal, 0.1);
}
```

**Trigger:**
Set category when sending notification:
```bash
notify-send -c "im.received" "Mastodon" "New notification"
```

## Notification Actions

### Action Buttons

Notifications can include clickable action buttons.

**Example:**
```bash
notify-send \
  -A "view=View Post" \
  -A "reply=Reply" \
  "Mastodon" \
  "New mention from @user"
```

**Styling:**
- Background: Surface0 (`#313244`)
- Border: Surface2 (`#585b70`)
- Hover: Surface1 with mauve border
- Padding: 8px 16px
- Rounded: 6px

## Theming

### Color Palette (Catppuccin Mocha)

| Color | Hex | Usage |
|-------|-----|-------|
| Base | `#1e1e2e` | Notification background |
| Mantle | `#181825` | Widget background |
| Crust | `#11111b` | Darkest background |
| Text | `#cdd6f4` | Primary text |
| Subtext0 | `#a6adc8` | Secondary text |
| Surface0 | `#313244` | Buttons, inputs |
| Surface1 | `#45475a` | Hover states |
| Surface2 | `#585b70` | Borders |
| Mauve | `#cba6f7` | Accent color |
| Red | `#f38ba8` | Critical, close button |
| Green | `#a6e3a1` | Low priority |
| Teal | `#94e2d5` | Mastodon category |

### Custom Color Variables

Edit `style.css`:

```css
@define-color base #1e1e2e;
@define-color mauve #cba6f7;
/* ... change colors as needed */
```

### Font

**Default:** JetBrainsMono Nerd Font

**Change font:**
```css
* {
  font-family: "Your Font Name";
  font-size: 13px;
}
```

## Configuration Options

### Timeouts

**File:** `config.json`

```json
"timeout": 10,          // Normal priority (seconds)
"timeout-low": 5,       // Low priority (seconds)
"timeout-critical": 0   // Critical (0 = never timeout)
```

### Dimensions

```json
"control-center-width": 500,
"control-center-height": 600,
"notification-window-width": 400
```

### Margins

```json
"control-center-margin-top": 10,
"control-center-margin-bottom": 10,
"control-center-margin-right": 10,
"control-center-margin-left": 0
```

### Position

```json
"positionX": "right",  // left, center, right
"positionY": "top"     // top, center, bottom
```

### Images

```json
"notification-icon-size": 64,
"notification-body-image-height": 100,
"notification-body-image-width": 200,
"image-visibility": "when-available"  // always, when-available, never
```

### Behavior

```json
"hide-on-clear": false,       // Don't close control center on clear all
"hide-on-action": true,       // Close notification on action click
"relative-timestamps": true,  // "5 min ago" vs "14:30"
"keyboard-shortcuts": true,   // Enable keyboard navigation
"fit-to-screen": true        // Ensure notifications fit on screen
```

## Keyboard Shortcuts

### In Control Center

- **Escape** - Close control center
- **Up/Down** - Navigate notifications
- **Enter** - Activate notification
- **Delete** - Remove notification
- **Ctrl+Shift+D** - Toggle Do Not Disturb

## Integration

### Waybar

**Module configuration:**

```jsonc
"custom/notification": {
  "tooltip": false,
  "format": "{icon} {}",
  "format-icons": {
    "notification": "<span foreground='red'><sup></sup></span>",
    "none": "",
    "dnd-notification": "<span foreground='red'><sup></sup></span>",
    "dnd-none": "",
    "inhibited-notification": "<span foreground='red'><sup></sup></span>",
    "inhibited-none": ""
  },
  "return-type": "json",
  "exec-if": "which swaync-client",
  "exec": "swaync-client -swb",
  "on-click": "swaync-client -t -sw",
  "on-click-right": "swaync-client -d -sw",
  "escape": true
}
```

**Actions:**
- Left click: Toggle control center
- Right click: Toggle Do Not Disturb

### Hyprland

**Auto-start:**
```conf
exec-once = swaync
```

**Keybinding:**
```conf
bind = ALT, N, exec, swaync-client -t -sw
```

### Custom Scripts

Send notifications from scripts:

```bash
#!/bin/bash

# Simple notification
notify-send "Title" "Message"

# With urgency
notify-send -u critical "Error" "Something went wrong"

# With category
notify-send -c "im.received" "Mastodon" "New message"

# With actions
notify-send \
  -A "yes=Yes" \
  -A "no=No" \
  "Question" \
  "Do you want to continue?"

# With icon
notify-send -i "dialog-information" "Info" "Message"
```

## Advanced Features

### Custom Scripts on Action

**Configuration:**
```json
"scripts": {
  "example-script": {
    "exec": "~/path/to/script.sh",
    "urgency": "Normal"
  }
}
```

### Notification Rules

**File:** `config.json`

```json
"notification-visibility": {
  "example-app": {
    "state": "muted",           // muted, ignored, transient
    "urgency": "Low",
    "override-urgency": true
  }
}
```

**States:**
- `muted` - Silent (no popup, shown in control center)
- `ignored` - Completely hidden
- `transient` - Shown but not saved in history

### 2FA Action

**Enable:**
```json
"notification-2fa-action": true
```

**Behavior:**
Automatically copies 2FA codes from notification body.

## Troubleshooting

### SwayNC not showing

```bash
# Check if running
pgrep swaync

# Start manually
swaync

# Check logs
journalctl --user -u swaync -f
```

### Notifications not appearing

```bash
# Test notification
notify-send "Test" "If you see this, it works"

# Check Do Not Disturb status
swaync-client -D

# Toggle DND off
swaync-client -df
```

### Theme not applied

```bash
# Reload SwayNC
swaync-client -R

# Or restart
killall swaync && swaync &
```

### Control center in wrong position

Edit `config.json`:
```json
"positionX": "right",  // Change to left/center/right
"positionY": "top"     // Change to top/center/bottom
```

### Icons not showing

```bash
# Install icon theme
sudo pacman -S papirus-icon-theme

# Set GTK icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
```

### Waybar integration broken

```bash
# Check swaync-client
which swaync-client

# Test command
swaync-client -swb

# Reload waybar
pkill -SIGUSR2 waybar
```

## Customization

### Add Custom Widget

Edit `config.json`:

```json
"widgets": [
  "title",
  "dnd",
  "mpris",        // Add media player widget
  "volume",       // Add volume slider
  "backlight",    // Add brightness slider
  "notifications"
]
```

### Widget Configuration

**MPRIS (Media Player):**
```json
"mpris": {
  "image-size": 96,
  "image-radius": 8,
  "blur": true
}
```

**Volume:**
```json
"volume": {
  "label": ""
}
```

**Backlight:**
```json
"backlight": {
  "label": ""
}
```

### Add Power Menu

```json
"widgets": ["title", "dnd", "menubar", "notifications"],

"widget-config": {
  "menubar": {
    "menu#power-buttons": {
      "label": "⏻",
      "position": "right",
      "actions": [
        {"label": " Shutdown", "command": "systemctl poweroff"},
        {"label": " Reboot", "command": "systemctl reboot"},
        {"label": " Suspend", "command": "systemctl suspend"},
        {"label": " Lock", "command": "hyprlock"}
      ]
    }
  }
}
```

### Add Quick Settings

```json
"widgets": ["title", "dnd", "buttons-grid", "notifications"],

"widget-config": {
  "buttons-grid": {
    "actions": [
      {"label": "", "command": "networkmanager_dmenu"},
      {"label": "", "command": "blueman-manager"}
    ]
  }
}
```

### Change Notification Size

Edit `style.css`:

```css
.notification {
  margin: 0 20px 20px 20px;  /* Increase margins */
  padding: 16px;              /* Increase padding */
}

.notification-icon {
  min-width: 80px;            /* Larger icon */
  min-height: 80px;
}
```

### Change Border Radius

```css
.control-center,
.notification {
  border-radius: 16px;  /* More rounded */
}
```

### Transparent Background

```css
.control-center {
  background-color: alpha(@base, 0.8);  /* More transparent */
}

.notification {
  background-color: alpha(@base, 0.9);
}
```

## Command-Line Reference

```bash
# Toggle control center
swaync-client -t -sw

# Open control center
swaync-client -op

# Close control center
swaync-client -cp

# Toggle Do Not Disturb
swaync-client -d -sw

# Enable Do Not Disturb
swaync-client -dn

# Disable Do Not Disturb
swaync-client -df

# Get DND status
swaync-client -D

# Get notification count
swaync-client -c

# Close all notifications
swaync-client -C

# Reload config
swaync-client -R

# Subscribe to events (for Waybar)
swaync-client -swb
```

## Performance

**Memory Usage:** ~15-20MB

**CPU Usage:** Minimal (<1% idle)

**Optimization Tips:**

1. **Limit notification history:**
   - Regularly clear old notifications
   - Use transient notifications for temporary alerts

2. **Reduce animation time:**
   ```json
   "transition-time": 100  // Faster transitions
   ```

3. **Disable blur (if using):**
   Remove blur from widgets in config

## Links

- [SwayNC GitHub](https://github.com/ErikReider/SwayNotificationCenter)
- [SwayNC Wiki](https://github.com/ErikReider/SwayNotificationCenter/wiki)
- [Catppuccin SwayNC](https://github.com/catppuccin/swaync)

---

_Last Updated: 2025-10-10_
