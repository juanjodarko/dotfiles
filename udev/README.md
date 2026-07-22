# Udev Rules - Bluetooth Power Management

This directory contains udev rules for managing hardware power settings, specifically to prevent Bluetooth disconnection issues caused by USB autosuspend.

## Problem

**Symptom:** Bluetooth devices (headphones, speakers, etc.) randomly disconnect during use, even on AC power. Manual reconnection attempts fail until the Bluetooth service is restarted or system is rebooted.

**Root Cause:** Linux USB autosuspend puts Bluetooth USB controllers into low-power mode after a period of inactivity. When the controller suspends:
- All connected Bluetooth devices disconnect
- Auto-reconnect attempts fail because the USB controller is in power-save mode
- Manual reconnection also fails until the controller wakes up

This happens **regardless of AC/battery power** because USB autosuspend is independent of system-level power management.

## Solution

The udev rule `50-bluetooth-usb-disable-autosuspend.rules` disables USB autosuspend for all Bluetooth controllers by:

1. Matching Bluetooth USB devices by multiple criteria:
   - Driver name (`btusb`)
   - Device class (Wireless Controller E0:01:01)
   - Vendor ID (Intel, Realtek, Qualcomm, Broadcom, MediaTek, etc.)
   - Product string containing "Bluetooth"

2. Setting `power/control` to `"on"` which keeps the controller always active

## Files

- **50-bluetooth-usb-disable-autosuspend.rules** - Udev rule that disables USB autosuspend for Bluetooth devices
- **Companion systemd service:** `systemd/.config/systemd/system/bluetooth-disable-usb-autosuspend.service`

## Deployment

### Quick Setup

Run the fix_bluetooth script which handles everything:

```bash
~/dotfiles/setup/fix_bluetooth.sh
```

Or use the integrated power management setup:

```bash
~/dotfiles/setup/init_power_management.sh
```

### Manual Deployment

If you need to deploy just the udev rules:

```bash
# Copy udev rule
sudo cp ~/dotfiles/udev/etc/udev/rules.d/50-bluetooth-usb-disable-autosuspend.rules /etc/udev/rules.d/

# Reload udev rules and trigger
sudo udevadm control --reload-rules
sudo udevadm trigger --action=add --subsystem-match=usb

# Deploy and enable systemd service
sudo cp ~/dotfiles/systemd/.config/systemd/system/bluetooth-disable-usb-autosuspend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now bluetooth-disable-usb-autosuspend.service
```

## Verification

### Check if udev rule is active

```bash
# List all Bluetooth USB devices and their power control status
for device in /sys/bus/usb/devices/*/; do
  if [ -f "$device/driver" ] && readlink "$device/driver" 2>/dev/null | grep -q btusb; then
    echo "Device: $(basename $device)"
    echo "  Control: $(cat $device/power/control 2>/dev/null)"
    echo "  Product: $(cat $device/product 2>/dev/null)"
    echo "  Vendor: $(cat $device/idVendor 2>/dev/null)"
    echo ""
  fi
done
```

Expected output: `Control: on` (not `auto`)

### Check systemd service

```bash
systemctl status bluetooth-disable-usb-autosuspend.service
```

Should show: `active (exited)` and `enabled`

### Monitor Bluetooth stability

```bash
# Watch Bluetooth service logs
journalctl -u bluetooth.service -f

# Monitor all USB power control changes
udevadm monitor --subsystem-match=usb
```

## Troubleshooting

### Issue: Udev rule not taking effect

**Symptoms:**
- `cat /sys/bus/usb/devices/*/power/control` shows `auto` instead of `on`
- Random disconnections still occurring

**Solutions:**

1. **Verify rule syntax:**
   ```bash
   sudo udevadm test $(udevadm info -q path -n /dev/bus/usb/001/XXX)
   ```

2. **Force trigger udev:**
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger --action=add --subsystem-match=usb
   ```

3. **Manually set power control (temporary test):**
   ```bash
   # Find your Bluetooth device
   for device in /sys/bus/usb/devices/*/; do
     if [ -f "$device/driver" ] && readlink "$device/driver" 2>/dev/null | grep -q btusb; then
       echo "on" | sudo tee "$device/power/control"
     fi
   done
   ```

4. **Reboot** (ensures all udev rules and services start fresh)

### Issue: Service fails to start

**Check service logs:**
```bash
sudo systemctl status bluetooth-disable-usb-autosuspend.service
sudo journalctl -u bluetooth-disable-usb-autosuspend.service
```

**Common causes:**
- Bluetooth service not running: `sudo systemctl start bluetooth.service`
- Missing `/sys/class/bluetooth`: Bluetooth driver not loaded
- Permission issues: Service needs root privileges (it's a system service, not user service)

### Issue: Disconnections still happening after fix

**Possible causes:**

1. **Bluetooth controller firmware issues:**
   ```bash
   dmesg | grep -i bluetooth
   journalctl -u bluetooth.service --since "1 hour ago"
   ```

2. **Signal interference:**
   - Move away from WiFi routers (2.4GHz can interfere with Bluetooth)
   - Disable WiFi temporarily to test
   - Check for USB 3.0 interference (USB 3.0 can interfere with 2.4GHz)

3. **Distance/obstacles:**
   - Bluetooth range is typically 10m (33ft)
   - Walls and obstacles reduce range

4. **Device-specific issues:**
   - Update Bluetooth device firmware
   - Try re-pairing the device
   - Test with a different Bluetooth device

5. **Kernel/driver issues:**
   ```bash
   # Check kernel version
   uname -r

   # Check loaded Bluetooth modules
   lsmod | grep bluetooth
   lsmod | grep btusb
   ```

### Issue: High battery drain

**Expected impact:** Minimal. Keeping Bluetooth controller active uses very little power when idle.

**If battery drain is significant:**
1. Check what profile is active: `bluetoothctl show`
2. Disconnect devices when not in use
3. Consider using `bluetoothctl power off` when Bluetooth not needed

## Technical Details

### Why USB Autosuspend Affects Bluetooth

1. Most Bluetooth controllers connect via USB (even built-in ones)
2. Linux USB subsystem enables autosuspend by default for power savings
3. After ~2 seconds of USB inactivity, controller enters suspend
4. Bluetooth connections require continuous USB communication
5. When controller suspends, all Bluetooth connections drop

### How This Fix Works

The udev rule runs when:
- System boots
- USB device is hot-plugged
- udev rules are manually triggered

It writes `"on"` to `/sys/bus/usb/devices/X-Y/power/control`:
- `"on"` = disable autosuspend (always active)
- `"auto"` = enable autosuspend (default)

The systemd service provides redundancy:
- Runs at boot after bluetooth.service starts
- Ensures settings persist across resume from suspend
- Catches devices that might not match udev rules

## Related Configuration

This fix integrates with other Bluetooth configurations:

- **`/etc/bluetooth/main.conf`** - BlueZ daemon configuration
  - `ReconnectAttempts = 7` - Auto-reconnect on link loss
  - `ResumeDelay = 2` - Delay after system resume
  - See `~/dotfiles/setup/fix_bluetooth.sh` for full config

- **WirePlumber configs** - Audio device management
  - Auto-switches to Bluetooth audio devices
  - High-quality codec support (LDAC, aptX, AAC)
  - See `~/dotfiles/wireplumber/.config/wireplumber/`

- **Power management** - System suspend behavior
  - Conditional suspend (battery only)
  - See `~/dotfiles/setup/init_power_management.sh`

## Battery Impact

**Q: Will this drain my battery?**

**A:** Minimal impact. Here's why:

1. **Bluetooth controller idle power:** ~1-5mW when connected but idle
2. **USB autosuspend savings:** ~10-50mW when fully suspended
3. **Real-world impact:** < 0.5% battery per hour difference
4. **Trade-off:** Stability vs. minimal battery savings

For comparison:
- Screen backlight: 2000-5000mW
- WiFi active: 500-1500mW
- CPU idle: 500-2000mW
- Bluetooth active: 1-5mW

**Recommendation:** Keep autosuspend disabled for Bluetooth. The battery impact is negligible compared to the stability issues it causes.

## References

- [Linux USB Power Management](https://www.kernel.org/doc/html/latest/driver-api/usb/power-management.html)
- [BlueZ Documentation](http://www.bluez.org/)
- [udev Rules Documentation](https://man.archlinux.org/man/udev.7)
- [systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

## Support

If you continue to experience issues after applying these fixes:

1. **Collect diagnostic information:**
   ```bash
   # System info
   uname -a
   bluetoothctl --version

   # Bluetooth hardware
   lsusb | grep -i bluetooth
   rfkill list bluetooth

   # Current status
   systemctl status bluetooth.service
   systemctl status bluetooth-disable-usb-autosuspend.service

   # USB power management
   grep . /sys/bus/usb/devices/*/power/control 2>/dev/null | grep -v auto

   # Recent logs
   journalctl -u bluetooth.service --since "1 hour ago" --no-pager
   ```

2. **Check for known issues:**
   - Search for your Bluetooth adapter model + "Linux disconnection"
   - Check Arch Wiki: https://wiki.archlinux.org/title/Bluetooth
   - Check kernel bugzilla: https://bugzilla.kernel.org/

3. **Try alternative solutions:**
   - Disable Bluetooth power management in BlueZ config
   - Update kernel/firmware
   - Use different Bluetooth adapter

---

**Last Updated:** 2025-10-17
**Related Scripts:** `fix_bluetooth.sh`, `init_power_management.sh`
