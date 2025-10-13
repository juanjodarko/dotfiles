# WirePlumber Configuration

This directory contains WirePlumber configuration for automatic Bluetooth audio device management.

## Features

- **Auto-switch to Bluetooth devices**: When you connect Bluetooth headphones/speakers, they automatically become the default audio output
- **High-quality audio**: Prefers A2DP profile for best audio quality
- **Auto-connect**: Bluetooth devices automatically reconnect when in range

## Installation

### On a new system:

```bash
# Create symlink from ~/.config to dotfiles
ln -sf ~/dotfiles/wireplumber/.config/wireplumber ~/.config/wireplumber

# Restart WirePlumber
systemctl --user restart wireplumber.service
```

### Verify it's working:

```bash
# Check WirePlumber status
systemctl --user status wireplumber.service

# List audio sinks
pactl list sinks short
```

## Configuration Files

- `51-bluetooth-autoswitch.conf` - Bluetooth device priority and A2DP profile settings
- `52-default-nodes.conf` - Default audio device selection policy

## Requirements

- WirePlumber >= 0.5.0
- PipeWire (modern Linux audio server)
- BlueZ (Linux Bluetooth stack)

## Troubleshooting

### Bluetooth not switching automatically:
```bash
# Restart WirePlumber
systemctl --user restart wireplumber.service

# Check logs
journalctl --user -u wireplumber.service -f
```

### Manually set Bluetooth as default:
```bash
# List devices
pactl list sinks short | grep bluez

# Set as default (use the name from above)
pactl set-default-sink bluez_output.XX_XX_XX_XX_XX_XX.1
```

## References

- [WirePlumber Documentation](https://pipewire.pages.freedesktop.org/wireplumber/)
- [PipeWire Wiki](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/home)
