# Bluetooth Connection Fix for Solgard Speakers

## Problem Identified

Your Solgard speakers ("Solarbank by Solgaard" - MAC: 30:21:35:44:57:68) are failing to connect with this error:

```
profiles/audio/avdtp.c:avdtp_connect_cb() connect to 30:21:35:44:57:68: Permission denied (13)
```

## Root Cause

The issue is caused by **two configuration problems** in `/etc/bluetooth/main.conf`:

1. **`AutoEnable = true`** - Not supported in BlueZ 5.84 (your version)
   - Causes: `Unknown key AutoEnable for group General` warning

2. **`SessionMode = ertm`** in [AVDTP] section - Incompatible with many Bluetooth speakers
   - Causes: "Permission denied" errors when trying to connect
   - ERTM (Enhanced Retransmission Mode) is not supported by many consumer Bluetooth devices

## Solution

The `fix_bluetooth.sh` script has been updated with the correct configuration:
- Removed `AutoEnable` option
- Changed `SessionMode = ertm` to `SessionMode = basic`

## Steps to Fix

### 1. Run the fixed Bluetooth configuration script

```bash
cd ~/dotfiles
./setup/fix_bluetooth.sh
```

This will:
- Apply the corrected `/etc/bluetooth/main.conf`
- Restart the Bluetooth service
- Deploy USB autosuspend prevention (udev rules + systemd service)
- Verify the configuration

### 2. Test the connection

After the script completes:

```bash
# Turn on your Solgard speakers (make sure they're in pairing mode)

# Connect via bluetoothctl
bluetoothctl connect 30:21:35:44:57:68

# Or use your GUI Bluetooth manager
```

### 3. Verify the fix worked

```bash
# Check for errors in logs (should be clean now)
journalctl -u bluetooth.service --since "5 minutes ago" | grep -i error

# Check connection status
bluetoothctl info 30:21:35:44:57:68
```

You should see:
- No "Unknown key AutoEnable" warning
- No "Permission denied" errors
- Device connects successfully

## What Changed

### Before (Broken Configuration)
```conf
[General]
AutoEnable = true              # ← Not supported in BlueZ 5.84
Experimental = true

[AVDTP]
SessionMode = ertm             # ← Causes "Permission denied" errors
```

### After (Fixed Configuration)
```conf
[General]
# AutoEnable removed
Experimental = true

[AVDTP]
SessionMode = basic            # ← Compatible with all devices
```

## If It Still Doesn't Work

### Reset the Bluetooth pairing

Sometimes the old failed connection attempts corrupt the pairing state:

```bash
# Remove the device
bluetoothctl remove 30:21:35:44:57:68

# Put speakers in pairing mode
# Scan for devices
bluetoothctl scan on

# Wait for device to appear, then:
bluetoothctl pair 30:21:35:44:57:68
bluetoothctl trust 30:21:35:44:57:68
bluetoothctl connect 30:21:35:44:57:68
```

### Check for interference

- **WiFi interference:** Try disabling WiFi temporarily (both use 2.4GHz)
- **USB 3.0 interference:** USB 3.0 devices can interfere with 2.4GHz Bluetooth
- **Distance:** Make sure speakers are within 10 meters with no obstacles

### Verify Bluetooth hardware

```bash
# Check Bluetooth controller
bluetoothctl show

# Check hardware status
rfkill list bluetooth

# Check for kernel errors (requires sudo)
sudo dmesg | grep -i bluetooth | tail -20
```

## Technical Details

### Why ERTM Causes Problems

ERTM (Enhanced Retransmission Mode) is a Bluetooth feature that provides:
- Better error correction
- Improved reliability for data streams
- Lower latency

However:
- Many consumer Bluetooth speakers don't support it
- When ERTM is forced, devices reject the connection with "Permission denied"
- Basic mode works with all Bluetooth devices

### The Error Sequence

1. Device pairs successfully (BR/EDR connection)
2. System tries to establish AVDTP audio connection
3. System requests ERTM mode
4. Speaker rejects with "Permission denied (13)"
5. Connection fails with "br-connection-unknown"

### Why Basic Mode Works

Basic mode uses simple Bluetooth audio streaming without advanced features:
- Universal compatibility
- Slightly higher latency (negligible for most users)
- Still supports high-quality codecs (LDAC, aptX, AAC) via WirePlumber

## Additional Fixes Included

The updated `fix_bluetooth.sh` also includes:

1. **USB Autosuspend Prevention**
   - Prevents random disconnections during use
   - See `udev/README.md` for details

2. **Auto-reconnect Configuration**
   - Reconnects automatically after link loss
   - 7 attempts with exponential backoff

3. **High-Quality Codec Support**
   - LDAC, aptX HD, aptX, AAC, SBC-XQ
   - Requires WirePlumber configuration (already in your dotfiles)

## Related Files

- **Configuration script:** `setup/fix_bluetooth.sh`
- **Udev rules:** `udev/etc/udev/rules.d/50-bluetooth-usb-disable-autosuspend.rules`
- **Systemd service:** `systemd/.config/systemd/system/bluetooth-disable-usb-autosuspend.service`
- **Documentation:** `udev/README.md`

## Support

If you continue to have issues after applying this fix:

1. Check the detailed troubleshooting guide: `udev/README.md`
2. Collect diagnostic information:
   ```bash
   bluetoothctl show
   bluetoothctl info 30:21:35:44:57:68
   systemctl status bluetooth.service
   journalctl -u bluetooth.service --since "1 hour ago" --no-pager
   ```

---

**Date:** 2025-10-17
**Issue:** AVDTP "Permission denied" errors with Bluetooth speakers
**Fix:** Change AVDTP SessionMode from `ertm` to `basic`
