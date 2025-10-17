# Power Management & GPU Mode Configuration

This directory contains systemd services and configurations for managing power states (suspend/hibernate) and GPU mode detection on systems with hybrid graphics (Intel + NVIDIA) using supergfxd.

## Overview

These configurations solve several common issues:
- **Spurious wake-ups**: USB devices and PCIe devices waking the system from suspend
- **Screen blinking during suspend**: Caused by immediate wake after entering suspend
- **NVIDIA service failures**: nvidia-powerd failing when GPU is disabled
- **No automatic suspend**: Hypridle only locking screen, never suspending
- **Smart suspend behavior**: Only suspend when on battery, stay awake when plugged in
- **Lid close always suspends**: Lid now intelligently locks (AC) or suspends (battery)

## Components

### 1. GPU Mode Detection (`~/.local/bin/gpu-mode-check.sh`)

A utility script that queries supergfxd to determine the current GPU mode.

**Supported modes:**
- `Integrated` - Intel GPU only (NVIDIA disabled) - Exit code 1
- `Hybrid` - Both Intel and NVIDIA GPUs active - Exit code 0
- `NvidiaNoModeset` - NVIDIA GPU active - Exit code 0

**Usage:**
```bash
~/.local/bin/gpu-mode-check.sh
echo $?  # 0 = NVIDIA active, 1 = Integrated mode
```

### 2. Conditional NVIDIA Power Service

**File:** `systemd/.config/systemd/system/nvidia-powerd.service.d/10-conditional.conf`

Prevents nvidia-powerd from starting (and failing) when the NVIDIA GPU is disabled.

**How it works:** Checks for `/proc/driver/nvidia/version` - only exists when NVIDIA driver is loaded.

### 3. Fixed Hypridle Configuration

**File:** `hyprland/.config/hypr/hypridle.conf`

Multi-stage idle management:
- **10 minutes**: Screen dims (DPMS off)
- **15 minutes**: Session locks (hyprlock)
- **20 minutes**: System suspends (**only when on battery** - see Conditional Suspend below)

Also includes `before_sleep_cmd` to ensure screen locks before any suspend operation.

### 4. USB Wake Prevention Service

**File:** `systemd/.config/systemd/system/disable-usb-wake.service`

Disables USB controller (XHC) as a wake source to prevent mouse/keyboard movements from waking the system.

### 5. PCIe Wake Prevention Service

**File:** `systemd/.config/systemd/system/disable-pcie-wake.service`

Disables unnecessary PCIe wake sources (PEG0, RP13, RP06) that can cause spurious wake-ups.

### 6. Conditional Suspend Script

**File:** `~/.local/bin/conditional-suspend.sh`

Smart suspend wrapper that only suspends when running on battery power.

**Behavior:**
- **On battery** (AC adapter unplugged): Suspends the system to conserve power
- **On AC power** (plugged in): Skips suspend, allowing continuous operation
- **Force suspend**: Set `FORCE_SUSPEND_ON_AC=1` to override and suspend even when plugged in

**How it works:**
- Checks `/sys/class/power_supply/AC0/online` (1=plugged in, 0=battery)
- Sends notification when suspend is skipped
- Logs all decisions to `$XDG_RUNTIME_DIR/conditional-suspend.log`

**Usage:**
```bash
# Called automatically by hypridle after 20min idle
# Or manually:
~/.local/bin/conditional-suspend.sh

# Force suspend even on AC power:
FORCE_SUSPEND_ON_AC=1 ~/.local/bin/conditional-suspend.sh
```

### 7. Power-Aware Lid Handling

**File:** `systemd/.config/systemd/logind.conf.d/10-power-aware-lid.conf`

Configures systemd-logind to handle lid close events based on power state, matching the conditional suspend behavior.

**Behavior:**
- **On battery + lid close**: Suspends immediately to conserve power
- **On AC power + lid close**: Locks screen only, keeps system running
- **When docked + lid close**: Ignores (for external monitor setups)

**How it works:**
- Uses systemd-logind's built-in power state detection
- `HandleLidSwitch=suspend` for battery operation
- `HandleLidSwitchExternalPower=lock` for AC power operation
- `HandleLidSwitchDocked=ignore` for docked operation

**Why this is useful:**
- Prevents interrupting long-running tasks when closing lid while plugged in
- Still conserves battery by suspending when unplugged
- Allows "close lid and walk away" workflow on AC power

### 8. GPU Mode Monitor (Optional)

**Files:**
- `~/.local/bin/gpu-mode-monitor.sh` - D-Bus monitor script
- `systemd/.config/systemd/user/gpu-mode-monitor.service` - User service

Monitors supergfxd D-Bus signals for GPU mode changes and logs them. Can be extended to trigger actions on mode changes.

**Log location:** `$XDG_RUNTIME_DIR/gpu-mode-monitor.log` (usually `/run/user/1000/`)

## Installation

### Quick Setup (Recommended)

The easiest way to deploy power management is using the automated setup script:

```bash
cd ~/dotfiles/setup
./init_power_management.sh
```

This script will:
- Detect if you're on a laptop (Razer Blade detection included)
- Deploy all components interactively
- Verify the configuration
- Handle all idempotency checks

**Standalone Usage:**
```bash
./init_power_management.sh              # Interactive setup
./init_power_management.sh --verify-only  # Just check status
./init_power_management.sh --force       # Re-apply all configs
```

**Integrated Usage:**
The power management setup is automatically included when running `setup/setup.sh` on laptop systems.

---

### Manual Installation (Advanced)

If you prefer manual control, follow these steps:

#### Step 1: Deploy Scripts

The scripts in `bin/.local/bin/` should be symlinked to `~/.local/bin/`:

```bash
cd ~/dotfiles
stow bin  # or your preferred deployment method
```

#### Step 2: Deploy Systemd System Services

These services require root access and must be installed to `/etc/systemd/system/`:

```bash
# Create directories
sudo mkdir -p /etc/systemd/system/nvidia-powerd.service.d

# Copy system services
sudo cp systemd/.config/systemd/system/disable-usb-wake.service /etc/systemd/system/
sudo cp systemd/.config/systemd/system/disable-pcie-wake.service /etc/systemd/system/
sudo cp systemd/.config/systemd/system/nvidia-powerd.service.d/10-conditional.conf \
    /etc/systemd/system/nvidia-powerd.service.d/

# Enable services
sudo systemctl daemon-reload
sudo systemctl enable disable-usb-wake.service
sudo systemctl enable disable-pcie-wake.service

# Start services
sudo systemctl start disable-usb-wake.service
sudo systemctl start disable-pcie-wake.service
```

#### Step 3: Deploy Power-Aware Lid Handling

Configure systemd-logind to handle lid close based on power state:

```bash
# Create directory
sudo mkdir -p /etc/systemd/logind.conf.d

# Copy logind configuration
sudo cp systemd/.config/systemd/logind.conf.d/10-power-aware-lid.conf \
    /etc/systemd/logind.conf.d/

# Restart systemd-logind to apply changes
sudo systemctl restart systemd-logind.service
```

**Note:** You may need to log out and back in for changes to take full effect.

#### Step 4: Deploy Systemd User Services (Optional)

For the GPU mode monitor:

```bash
# Copy user service
mkdir -p ~/.config/systemd/user
cp systemd/.config/systemd/user/gpu-mode-monitor.service ~/.config/systemd/user/

# Enable and start
systemctl --user daemon-reload
systemctl --user enable gpu-mode-monitor.service
systemctl --user start gpu-mode-monitor.service
```

#### Step 5: Update Hypridle Configuration

```bash
cd ~/dotfiles
stow hyprland  # or your preferred deployment method
```

Then restart hypridle:
```bash
killall hypridle && hypridle &
```

## Verification

### Check Wake Sources

```bash
# Check which devices can wake the system
cat /proc/acpi/wakeup

# XHC should show *disabled after installation
# PEG0, RP13, RP06 should show *disabled
```

### Check NVIDIA Service Status

```bash
# Should not show failures in Integrated mode
systemctl status nvidia-powerd.service
```

### Test Suspend

```bash
# Manual suspend test
systemctl suspend

# System should:
# 1. Lock the screen
# 2. Enter suspend without screen blinking
# 3. NOT wake up from USB device movement
# 4. Wake from power button press
```

### Test Lid Handling

```bash
# Check current logind configuration
systemd-analyze cat-config systemd/logind.conf | grep HandleLidSwitch

# Test lid behavior based on power state:
# 1. While PLUGGED IN - close lid
#    Expected: Screen locks, system stays running (no suspend)
#
# 2. While ON BATTERY - close lid
#    Expected: System suspends immediately
#
# 3. Open lid
#    Expected: Wake from suspend (if suspended) or unlock screen

# Check AC power status
cat /sys/class/power_supply/AC0/online  # 1=plugged in, 0=battery
```

### Monitor GPU Mode Changes

```bash
# View monitor logs
tail -f $XDG_RUNTIME_DIR/gpu-mode-monitor.log

# Check current GPU mode
supergfxctl -g

# Change GPU mode (requires reboot)
supergfxctl -m Hybrid  # or Integrated, NvidiaNoModeset
```

## Troubleshooting

### System still wakes immediately after suspend

1. Check wake sources are actually disabled:
   ```bash
   cat /proc/acpi/wakeup | grep enabled
   ```

2. Check systemd service status:
   ```bash
   sudo systemctl status disable-usb-wake.service
   sudo systemctl status disable-pcie-wake.service
   ```

3. Check for other wake sources:
   ```bash
   # Find USB devices with wake enabled
   for i in /sys/bus/usb/devices/*/power/wakeup; do
       [ "$(cat $i)" = "enabled" ] && echo "$i: enabled"
   done
   ```

### nvidia-powerd still failing

1. Verify the drop-in was loaded:
   ```bash
   systemctl cat nvidia-powerd.service
   # Should show the ConditionPathExists line
   ```

2. Check if NVIDIA driver is loaded:
   ```bash
   ls /proc/driver/nvidia/version 2>/dev/null && echo "NVIDIA active" || echo "NVIDIA disabled"
   ```

### Hypridle not suspending

1. Check hypridle is running:
   ```bash
   ps aux | grep hypridle
   ```

2. Check hypridle configuration:
   ```bash
   cat ~/.config/hypr/hypridle.conf
   ```

3. Test manual suspend:
   ```bash
   systemctl suspend
   ```

4. Check if on battery vs AC power:
   ```bash
   # Check AC power status (0=battery, 1=AC)
   cat /sys/class/power_supply/AC0/online

   # Test conditional suspend script directly
   ~/.local/bin/conditional-suspend.sh
   ```

5. Check conditional suspend logs:
   ```bash
   tail -f $XDG_RUNTIME_DIR/conditional-suspend.log
   ```

### GPU mode monitor not logging

1. Check service status:
   ```bash
   systemctl --user status gpu-mode-monitor.service
   ```

2. Check D-Bus availability:
   ```bash
   busctl tree org.supergfxctl.Daemon
   ```

### Lid close suspends even when plugged in

1. Check if logind configuration was applied:
   ```bash
   systemd-analyze cat-config systemd/logind.conf | grep HandleLidSwitch
   # Should show:
   # HandleLidSwitch=suspend
   # HandleLidSwitchExternalPower=lock
   # HandleLidSwitchDocked=ignore
   ```

2. Check if systemd-logind was restarted:
   ```bash
   sudo systemctl status systemd-logind.service
   # Check the service start time - should be after config was copied
   ```

3. Restart systemd-logind and re-login:
   ```bash
   sudo systemctl restart systemd-logind.service
   # Then log out and log back in
   ```

4. Check AC power detection:
   ```bash
   cat /sys/class/power_supply/AC0/online
   # Should show 1 when plugged in, 0 on battery
   ```

### Lid close doesn't lock screen when plugged in

This is expected behavior with the power-aware configuration. When plugged in and lid closes:
- Screen locks (via `HandleLidSwitchExternalPower=lock`)
- System does NOT suspend
- Hyprlock should activate

If hyprlock doesn't activate, check:
```bash
# Ensure hyprlock is configured
cat ~/.config/hypr/hypridle.conf | grep lock_cmd

# Test hyprlock manually
hyprlock
```

## Technical Details

### Why These Solutions Work

**USB/PCIe Wake Prevention:**
- Writing a device name to `/proc/acpi/wakeup` toggles its wake capability
- The services toggle wake sources OFF at boot, preventing spurious wakes

**Conditional NVIDIA Service:**
- systemd `ConditionPathExists` prevents service start if path doesn't exist
- `/proc/driver/nvidia/version` only exists when NVIDIA driver is loaded
- When condition fails, service is skipped (not failed)

**Hypridle Stages:**
- Multiple listeners with different timeouts create staged idle behavior
- `before_sleep_cmd` ensures security (lock) before sleep
- Conditional suspend script intelligently decides when to suspend

**Conditional Suspend:**
- Reads `/sys/class/power_supply/AC0/online` to detect power state
- File contains `1` when AC connected, `0` when on battery
- Allows different behavior based on power source
- Prevents unwanted suspend during long tasks on AC power
- Conserves battery when running untethered

**Power-Aware Lid Handling:**
- systemd-logind natively detects AC power vs battery state
- `HandleLidSwitchExternalPower` overrides `HandleLidSwitch` when AC is connected
- `loginctl lock-session` triggers the lock command defined in hypridle
- No custom scripts needed - leverages built-in systemd capabilities
- Changes take effect system-wide for all sessions

**GPU Mode Detection:**
- supergfxctl provides reliable mode information via D-Bus
- Exit codes allow use in systemd conditions and scripts
- Enables mode-aware power management strategies

## Future Enhancements

Possible improvements:
- Hibernation support with resume kernel parameter
- Different power profiles per GPU mode
- Automatic service management on mode changes
- Integration with tlp or powertop for comprehensive power management

## References

- [Arch Wiki: Power Management](https://wiki.archlinux.org/title/Power_management)
- [Arch Wiki: Suspend and Hibernate](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate)
- [supergfxctl Documentation](https://gitlab.com/asus-linux/supergfxctl)
- [hypridle Documentation](https://github.com/hyprwm/hypridle)
