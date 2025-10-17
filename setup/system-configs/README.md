# System Configuration Templates

This directory contains system configuration templates that are installed by setup scripts to enable fingerprint authentication and other system features.

## Configuration Files

### SDDM Display Manager

SDDM configuration templates for login screen appearance and behavior.

#### sddm.conf.d/theme.conf

**Installed to:** `/etc/sddm.conf.d/theme.conf`
**Applied by:** `setup/init_sddm.sh`

Configures SDDM login screen with:
- Catppuccin theme matching system theme
- Disabled auto-login (secure login required)
- User avatar support
- Theme synchronized with system theme switcher

**Key settings:**
- Current theme: catppuccin-macchiato (matches system default)
- Auto-login disabled for security
- Theme updates when switching system themes

**Required packages:**
- `catppuccin-sddm-theme-mocha`
- `catppuccin-sddm-theme-macchiato`
- `catppuccin-sddm-theme-frappe`
- `catppuccin-sddm-theme-latte`

### PAM Configuration Files

PAM (Pluggable Authentication Modules) configurations control system authentication behavior. These templates enable fingerprint authentication across different contexts.

### pam.d/system-auth

**Installed to:** `/etc/pam.d/system-auth`
**Applied by:** `setup/init_fingerprint.sh`

Enables fingerprint authentication for:
- System login (TTY and display manager)
- sudo commands
- Hyprlock screen unlock
- Any system service using PAM authentication

**Key settings:**
- Fingerprint tried first (before password)
- 30 second timeout for fingerprint placement
- 3 attempts allowed before falling back to password
- Uses stable NBIS (Bozorth3) matching algorithm

### pam.d/polkit-1

**Installed to:** `/etc/pam.d/polkit-1`
**Applied by:** `setup/init_fingerprint.sh`

Enables fingerprint authentication for polkit-protected operations:
- 1Password system authentication
- System settings requiring admin privileges
- Software installation/updates
- Any application using polkit for authorization

**Key settings:**
- Fingerprint authentication with same timeout/retry as system-auth
- Falls back to system-auth for password if fingerprint fails
- Inherits other PAM settings from system-auth

## Installation

These templates are installed automatically when running:

```bash
./setup/init_fingerprint.sh
```

The script will:
1. Check if fingerprint device exists
2. Install required packages (fprintd, libfprint)
3. Copy templates to system locations with sudo
4. Enroll your fingerprints
5. Test authentication

## Manual Installation

If you need to manually install these configs:

```bash
# Backup existing configs
sudo cp /etc/pam.d/system-auth /etc/pam.d/system-auth.backup
sudo cp /etc/pam.d/polkit-1 /etc/pam.d/polkit-1.backup 2>/dev/null || true

# Install templates
sudo cp setup/system-configs/pam.d/system-auth /etc/pam.d/system-auth
sudo cp setup/system-configs/pam.d/polkit-1 /etc/pam.d/polkit-1
```

## Testing

After installation, test fingerprint authentication:

```bash
# Test basic authentication
fprintd-verify $USER

# Test sudo (will prompt for fingerprint)
sudo echo "Fingerprint authentication works!"

# Test hyprlock
# Lock screen with Super+L, press Enter, then place finger

# Test 1Password
# Open 1Password and perform an action requiring authentication
```

## Troubleshooting

### Fingerprint not detected
```bash
# Check if device is recognized
fprintd-list $USER

# Check fprintd service
systemctl status fprintd.service
```

### Authentication fails immediately
- Ensure fingerprint is enrolled: `fprintd-enroll $USER`
- Check PAM logs: `journalctl -u fprintd.service -f`

### Password still required after fingerprint
- PAM is working correctly - fingerprint configured as "sufficient" (optional)
- If fingerprint fails/times out, password is normal fallback

## Technical Details

**Matching Algorithm:** NBIS (NIST Biometric Image Software)
**Threshold:** bz3_threshold = 25 (balanced security/usability)
**Supported Devices:** CS9711, egis0570, and other libfprint-compatible sensors

## References

- [libfprint Documentation](https://fprint.freedesktop.org/)
- [PAM Configuration Guide](https://wiki.archlinux.org/title/PAM)
- [fprintd Project](https://gitlab.freedesktop.org/libfprint/fprintd)
