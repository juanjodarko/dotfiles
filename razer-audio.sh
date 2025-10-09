#!/usr/bin/env bash
#
# fix-razer-audio.sh
#   Auto-repair script for Razer Blade 2017 (ALC298, GTX 1060) audio on Arch/Hyprland
#   Run with:  sudo bash fix-razer-audio.sh
#

set -e

echo "🔧  Installing required audio packages..."
sudo pacman -S --needed --noconfirm alsa-utils sof-firmware alsa-firmware alsa-ucm-conf pipewire pipewire-pulse wireplumber

echo "🧠  Applying Realtek ALC298 quirk (Razer Blade 2017 fix)..."
sudo mkdir -p /etc/modprobe.d
sudo bash -c 'cat > /etc/modprobe.d/alsa-base.conf <<EOF
options snd-hda-intel model=dell-headset-multi index=0
EOF'

echo "💾  Reloading ALSA configuration..."
if lsmod | grep -q snd_hda_intel; then
  echo "🔁  Module in use, will reload on next boot."
else
  sudo modprobe snd_hda_intel
fi

echo "🎛️  Reinitializing ALSA and restarting audio services..."
sudo alsactl init || true
systemctl --user restart pipewire wireplumber || true

echo "✅  Current driver parameter:"
cat /sys/module/snd_hda_intel/parameters/model || echo "(will appear after reboot)"

echo "🔊  Checking available sinks..."
pactl list short sinks || echo "PipeWire not fully started yet."

echo
echo "🎶  Testing audio output (you should hear 'Front Center')..."
paplay /usr/share/sounds/alsa/Front_Center.wav || echo "If silent, reboot and test again."

echo
echo "✅  Done. Reboot to apply changes if no audio yet."

