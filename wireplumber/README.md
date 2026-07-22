# WirePlumber Configuration

This directory contains WirePlumber configuration for automatic audio device management with intelligent switching and high-quality codec support.

## Features

### Automatic Device Switching
- **Bluetooth devices**: Auto-switch to Bluetooth headphones/speakers when connected
- **USB audio devices**: Auto-switch to USB headsets/DACs when plugged in
- **Razer Nari Ultimate**: Full support with automatic dual-channel profile (Game + Chat)
- **Smart priorities**: USB gaming headsets > Bluetooth > Built-in audio

### High-Quality Audio
- **Bluetooth codecs**: LDAC, aptX HD, aptX, AAC, SBC-XQ with automatic fallback
- **A2DP profile**: Prefers high-quality stereo profile for music/media
- **Hardware volume**: Battery-efficient volume control when supported
- **96kHz sampling**: For Bluetooth devices that support it

### Audio Stream Router (Advanced)
- **Manual stream routing**: Interactive wofi menu to route individual apps to specific devices
- **Saved routing rules**: Persistent preferences (e.g., "Tidal → Bluetooth", "Firefox → Headset")
- **Auto-apply daemon**: Background service that automatically routes new streams based on saved rules
- **Waybar integration**: Quick access via 🎵 button in system bar

## Installation

### Automatic (Recommended)

Run the setup script to automatically configure everything:

```bash
cd ~/dotfiles
./setup/setup.sh
```

The setup script will:
1. Install required audio packages (PipeWire, WirePlumber, codecs)
2. Deploy WirePlumber configurations using GNU Stow
3. Restart WirePlumber service if needed
4. Verify device detection

### Manual Installation

```bash
# Deploy configuration using stow
cd ~/dotfiles
stow wireplumber

# Restart WirePlumber
systemctl --user restart wireplumber.service
```

### Verify it's working:

```bash
# Check WirePlumber status
systemctl --user status wireplumber.service

# List all audio devices
wpctl status

# List audio sinks
pactl list sinks short

# Check active Bluetooth codec (if Bluetooth device connected)
pactl list cards | grep -A20 bluez
```

## Configuration Files

- `51-bluetooth-autoswitch.conf` - Bluetooth device priority and A2DP profile settings
- `52-default-nodes.conf` - Default audio device selection policy
- `53-usb-autoswitch.conf` - USB audio device auto-switching (Razer Nari, gaming headsets)
- `54-bluetooth-codecs.conf` - High-quality Bluetooth codec configuration (LDAC, aptX)

## Requirements

### Core Audio System
- WirePlumber >= 0.5.0
- PipeWire >= 0.3.0 (modern Linux audio server)
- pipewire-pulse (PulseAudio compatibility)
- pipewire-alsa (ALSA compatibility)

### Bluetooth Support
- BlueZ (Linux Bluetooth stack)
- bluez-utils

### High-Quality Codecs (Optional but Recommended)
- libldac (LDAC codec - Sony high-res)
- libfreeaptx (aptX codec - Qualcomm)

### Device-Specific
- razer-nari-pipewire-profile (for Razer Nari headsets)

All requirements are automatically installed by running `./setup/setup.sh`.

## How It Works

### Priority System

WirePlumber uses priority values to determine which device becomes the default:

1. **Razer Nari & USB Gaming Headsets**: Priority 2000
   - Highest priority for dedicated gaming audio
   - Automatic dual-channel configuration (Game + Chat)

2. **Bluetooth Audio Devices**: Priority 1800
   - Auto-selects best available codec
   - Prefers A2DP for high-quality audio
   - Higher than built-in audio to auto-switch when connected

3. **Generic USB Audio Devices**: Priority 1500
   - Medium-high priority
   - DACs, USB headphones, etc.

4. **Built-in Audio**: Priority 500-1500 (varies by profile)
   - Lowest priority, used as fallback
   - Pro audio profile uses 1500

### Codec Selection

For Bluetooth devices, the system tries codecs in this order:
1. LDAC (990 kbps, best quality)
2. aptX HD (576 kbps)
3. aptX (352 kbps)
4. AAC (256 kbps)
5. SBC-XQ (328 kbps)
6. SBC (fallback, universal)

## Important Notes

⚠️ **Configuration Design**
The configurations in this directory use a **priority-only** approach. They set node priorities to enable automatic device switching, but **do not force profiles or device properties**. WirePlumber handles profile selection automatically based on hardware capabilities.

**What NOT to do:**
- ❌ Do not set `device.profile` in `monitor.alsa.rules` - this can cause infinite loops and CPU spikes
- ❌ Do not force codec selection with `bluez5.a2dp.codec` - let WirePlumber auto-select
- ❌ Do not mix device-level and node-level properties
- ❌ Do not force sample rates or formats - let the hardware negotiate

These configs are safe and tested to avoid configuration loops that can freeze your system.

## Troubleshooting

### Bluetooth not switching automatically

```bash
# Restart WirePlumber
systemctl --user restart wireplumber.service

# Check logs
journalctl --user -u wireplumber.service -f

# Verify Bluetooth service is running
systemctl status bluetooth.service
```

### USB device not auto-switching

```bash
# Check if device is detected
wpctl status
pactl list cards short

# Verify configuration is loaded
ls -la ~/.config/wireplumber/wireplumber.conf.d/53-usb-autoswitch.conf

# Restart WirePlumber
systemctl --user restart wireplumber.service
```

### Razer Nari not using full profile

```bash
# Check if profile is installed
ls -la /usr/share/alsa-card-profile/mixer/profile-sets/razer-nari-usb-audio.conf

# Install if missing
sudo pacman -S razer-nari-pipewire-profile

# Restart WirePlumber
systemctl --user restart wireplumber.service
```

### Check active Bluetooth codec

```bash
# Show detailed Bluetooth card info
pactl list cards | grep -A30 bluez

# Look for "Active Profile" and codec information
```

### Manually switch devices

```bash
# List all devices with IDs
wpctl status

# Set default sink (output)
wpctl set-default <device-id>

# Set default source (input)
wpctl set-default <device-id>
```

### Audio quality issues

```bash
# Check sample rate and format
pactl list sinks | grep -E "Name:|Sample|Format"

# For Bluetooth, verify high-quality codec is active
pactl list cards | grep -A20 bluez | grep -i "ldac\|aptx\|aac"

# Ensure codec packages are installed
pacman -Q libldac libfreeaptx
```

### Reset to default configuration

```bash
# Remove custom configurations
rm -rf ~/.config/wireplumber

# Re-deploy from dotfiles
cd ~/dotfiles
stow wireplumber

# Restart services
systemctl --user restart pipewire wireplumber
```

## Testing

### Test USB Auto-Switch
1. Play audio (music, video, etc.)
2. Plug in USB headset/DAC
3. Audio should automatically switch to USB device
4. Unplug USB device
5. Audio should return to previous device

### Test Bluetooth Auto-Switch
1. Play audio
2. Connect Bluetooth headphones
3. Audio should automatically switch to Bluetooth
4. Check codec: `pactl list cards | grep -A20 bluez`
5. Should show LDAC or aptX if supported

### Test Razer Nari
1. Plug in Razer Nari
2. Check profile: `pactl list cards | grep -A5 "Razer.*Nari"`
3. Should show "Game Output + Chat Output + Chat Input" as active profile
4. Both game and chat channels should be available

## Using Audio Stream Router

### Manual Routing

Click the 🎵 button in Waybar to open the Audio Router:

1. **Select an application stream**: Shows all currently playing audio streams with their current device
2. **Choose output device**: Select where you want to route the audio
3. **Save route (optional)**: Choose whether to remember this preference

### Saved Routes Management

- **View saved routes**: Select "Manage Saved Routes" from the main menu
- **Delete routes**: Select a route to remove it from saved preferences
- **Auto-apply**: Enable the daemon to automatically apply saved routes to new streams

### Enable Auto-Router Daemon

```bash
# Enable the daemon to auto-apply saved routes
systemctl --user enable --now audio-router.service

# Check daemon status
systemctl --user status audio-router.service

# View daemon logs
journalctl --user -u audio-router.service -f

# View routing history
cat ~/.config/audio-router/daemon.log
```

### Use Cases

**Dedicated music player to Bluetooth**:
1. Start playing music in Tidal/Spotify
2. Open Audio Router (🎵)
3. Select the music stream
4. Route to Bluetooth headphones
5. Save the route
6. Future music sessions will auto-route to Bluetooth

**Gaming audio to headset, Discord to speakers**:
1. Start game and Discord
2. Route game to USB headset
3. Route Discord to built-in speakers
4. Save both routes
5. Next time they'll auto-route correctly

**Browser audio based on content**:
1. Open YouTube in Firefox
2. Route to external speakers
3. Save "Firefox" route
4. All browser audio now goes to speakers by default

## References

- [WirePlumber Documentation](https://pipewire.pages.freedesktop.org/wireplumber/)
- [PipeWire Wiki](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/home)
- [Arch Linux PipeWire Guide](https://wiki.archlinux.org/title/PipeWire)
- [Bluetooth Audio Configuration](https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-Bluetooth)
