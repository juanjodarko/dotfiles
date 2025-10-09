#!/usr/bin/env bash
#
# fix-razer-gpu.sh
#  Configure hybrid graphics on Razer Blade 2017 for optimal battery and hybrid switching.
#  Works on Arch Linux / Hyprland.
#

set -e

echo "🔧  Setting up hybrid GPU management with supergfxctl..."

# --- Ensure base dependencies ---
if ! command -v yay >/dev/null 2>&1; then
  echo "📦 Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay && makepkg -si --noconfirm && cd ..
  rm -rf yay
fi

# --- Install supergfxctl from AUR ---
if ! command -v supergfxctl >/dev/null 2>&1; then
  echo "📦 Installing supergfxctl from AUR..."
  yay -S --needed --noconfirm supergfxctl
else
  echo "✅ supergfxctl already installed."
fi

# --- Enable and start service ---
echo "⚙️  Enabling and starting supergfxd service..."
sudo systemctl enable --now supergfxd

# --- Create optimized config ---
echo "🧠  Writing optimized configuration to /etc/supergfxd.conf..."
sudo tee /etc/supergfxd.conf >/dev/null <<'EOF'
{
  "mode": "Integrated",
  "vfio_enable": false,
  "vfio_save": false,
  "always_reboot": false,
  "no_logind": false,
  "logout_timeout_s": 60,
  "hotplug_type": "None",
  "power_control": true,
  "runtime_pm": true,
  "runtime_pm_delay_s": 10
}
EOF

# --- Clear stale modes ---
echo "🧹  Clearing stale state files..."
sudo rm -f /etc/supergfxctl/saved_mode /etc/supergfxctl/pending_mode

# --- Mask mode-saving unit (prevent reverting) ---
echo "🚫  Preventing mode override on shutdown..."
sudo systemctl mask supergfxd-update-saved-mode.service || true

# --- Restart service to apply changes ---
echo "🔁  Restarting supergfxd..."
sudo systemctl restart supergfxd

# --- Verify mode ---
echo "🔍  Current GPU mode:"
if supergfxctl --get 2>/dev/null; then
  supergfxctl --get
else
  echo "⚠️  (supergfxctl output not available yet — reboot to verify)"
fi

echo
echo "✅  Done! System is now configured to boot in Integrated mode by default."
echo "🖥️  You can switch modes manually with:"
echo "   sudo supergfxctl --set Hybrid"
echo "   sudo supergfxctl --set Dedicated"
echo
echo "🔋  NVIDIA GPU will remain powered down until you explicitly enable it."

