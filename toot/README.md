# Toot - Mastodon CLI/TUI Configuration

Catppuccin Mocha themed configuration for toot, including desktop notification integration.

## Features

- **Catppuccin Mocha Theme** - Complete color palette for the TUI
- **True Color Support** - 24-bit colors for accurate theme rendering
- **Kitty Graphics Protocol** - Inline image display in ghostty terminal
- **Desktop Notifications** - Mastodon notifications in swaync with clickable actions

## Files

```
toot/
├── .config/
│   ├── systemd/user/
│   │   └── mastodon-notifications.service  # Systemd service for notification daemon
│   └── toot/
│       └── settings.toml                    # Toot configuration with Catppuccin theme
└── .local/bin/
    └── mastodon-notifications               # Notification polling script
```

## Setup

### 1. Install Dependencies

```bash
# Main package
sudo pacman -S toot

# For inline image display
sudo pacman -S python-pillow python-term-image

# For notification script (should already be installed)
sudo pacman -S jq libnotify
```

### 2. Login to Mastodon

```bash
toot login
# This will open your browser to authenticate
```

### 3. Enable Desktop Notifications

```bash
# Reload systemd user services
systemctl --user daemon-reload

# Enable and start the notification daemon
systemctl --user enable mastodon-notifications.service
systemctl --user start mastodon-notifications.service

# Check status
systemctl --user status mastodon-notifications.service
```

### 4. Configuration

The notification check interval can be adjusted by setting the environment variable in the service file:

```toml
# ~/.config/systemd/user/mastodon-notifications.service
Environment="MASTODON_CHECK_INTERVAL=60"  # seconds (default: 60)
```

After changing, reload with:
```bash
systemctl --user daemon-reload
systemctl --user restart mastodon-notifications.service
```

## Usage

### TUI (Terminal User Interface)

```bash
toot tui
```

**Keyboard shortcuts in TUI:**
- `n` - Compose new post
- `r` - Reply to selected post
- `b` - Boost (reblog) selected post
- `f` - Favourite selected post
- `v` - View images/media
- `t` - View thread
- `q` - Quit

### CLI Commands

```bash
# Post a status
toot post "Hello Mastodon!"

# Post with image
toot post -m ~/Pictures/photo.jpg "Check this out!"

# Post with editor
toot post -e

# View home timeline
toot timelines home

# View notifications
toot notifications

# Search
toot search "search term"
```

### Desktop Notifications

The notification daemon automatically checks for new Mastodon notifications and displays them via swaync.

**Notification actions:**
- Click notification body - Opens toot TUI
- "View Post" button - Shows the specific post in a terminal window
- "Open Toot" button - Opens toot TUI to notifications

**Manual commands:**
```bash
# Check for notifications once
mastodon-notifications check

# Reset notification tracking (show all as new)
mastodon-notifications reset

# View daemon logs
journalctl --user -u mastodon-notifications.service -f
```

## Theme

The Catppuccin Mocha theme uses these colors:

- **Backgrounds**: base (#1e1e2e), surface0 (#313244), surface1 (#45475a)
- **Text**: text (#cdd6f4), subtext0 (#a6adc8)
- **Accents**:
  - Mauve (#cba6f7) - Focused elements
  - Blue (#89b4fa) - Links, accounts
  - Teal (#94e2d5) - Hashtags
  - Green (#a6e3a1) - Success, public posts
  - Yellow (#f9e2af) - Warnings, unlisted
  - Red (#f38ba8) - Errors, direct messages
  - Pink (#f5c2e7) - Code blocks

## Troubleshooting

### Images not displaying in TUI

Ensure you have the dependencies installed:
```bash
sudo pacman -S python-pillow python-term-image
```

Verify ghostty supports Kitty graphics protocol (it does by default).

### Notifications not appearing

Check the daemon status:
```bash
systemctl --user status mastodon-notifications.service
journalctl --user -u mastodon-notifications.service -n 50
```

Manually check for notifications:
```bash
mastodon-notifications check
```

### Permission issues

Ensure the script is executable:
```bash
chmod +x ~/.local/bin/mastodon-notifications
```

## Links

- [Toot Documentation](https://toot.bezdomni.net/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Ghostty Terminal](https://ghostty.org/)
