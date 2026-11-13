#!/usr/bin/env bash
#
# init_system.sh - Deploy system files (/etc, /usr/local) from system/<layer>/
# Idempotent: only differing files are copied; replaced files get a .bak-<date>.
#
# Layers: system/common, plus system/hardware-<hostname> when it exists.
# Files are COPIED (not linked): root services and the greeter user must not
# depend on files inside a user's home directory.
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step()    { echo -e "${BLUE}→${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_skip()    { echo -e "${YELLOW}⊙${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SYSTEM_DIR="$DOTFILES_DIR/system"
STAMP="$(date +%Y%m%d-%H%M%S)"

host="$(cat /etc/hostname 2>/dev/null || hostnamectl --static 2>/dev/null || hostname)"
host="${host,,}"
LAYERS=("common")
[ -d "$SYSTEM_DIR/hardware-$host" ] && LAYERS+=("hardware-$host")

changed_units=()
changed_udev=false
changed_modprobe=false
changed_greeter=false

echo ""
echo "🖥️  Deploying system files (layers: ${LAYERS[*]})..."
echo ""

for layer in "${LAYERS[@]}"; do
    root="$SYSTEM_DIR/$layer"
    while IFS= read -r -d '' src; do
        rel="${src#"$root"}"
        dest="$rel"
        if sudo test -f "$dest" && sudo cmp -s "$src" "$dest"; then
            continue
        fi
        if sudo test -e "$dest"; then
            sudo cp -a "$dest" "$dest.bak-$STAMP"
            print_step "Backed up $dest → $dest.bak-$STAMP"
        fi
        mode=644
        [[ "$dest" == /usr/local/bin/* ]] && mode=755
        sudo install -D -m "$mode" "$src" "$dest"   # follows repo-internal symlinks
        print_success "Installed $dest"
        case "$dest" in
            /etc/systemd/system/*.service) changed_units+=("$(basename "$dest")") ;;
            /etc/udev/rules.d/*)           changed_udev=true ;;
            /etc/modprobe.d/*)             changed_modprobe=true ;;
            /etc/greetd/*|/usr/local/bin/update-greeter-*|/etc/polkit-1/*) changed_greeter=true ;;
        esac
    done < <(find "$root" \( -type f -o -type l \) -print0 | sort -z)
done

# ---------------------------------------------------------------- units ----
sudo systemctl daemon-reload
for layer in "${LAYERS[@]}"; do
    for unit in "$SYSTEM_DIR/$layer"/etc/systemd/system/*.service; do
        [ -e "$unit" ] || continue
        name="$(basename "$unit")"
        if [ "$name" = libvirt-docker-forward.service ] && ! command -v docker &> /dev/null; then
            print_skip "$name: docker not installed, not enabling"
            continue
        fi
        if systemctl is-enabled -q "$name" 2>/dev/null; then
            print_skip "$name already enabled"
        else
            # --now only when the unit's dependencies can run here (it's WantedBy docker for the forward unit)
            sudo systemctl enable "$name" && print_success "Enabled $name"
        fi
    done
done

# ----------------------------------------------------------- udev/initrd ---
if [ "$changed_udev" = true ]; then
    sudo udevadm control --reload && print_success "udev rules reloaded"
fi
if [ "$changed_modprobe" = true ] && command -v mkinitcpio &> /dev/null; then
    print_step "modprobe.d changed — rebuilding initramfs..."
    sudo mkinitcpio -P > /dev/null && print_success "initramfs rebuilt" || print_error "mkinitcpio -P failed"
fi

# -------------------------------------------------------------- greeter ----
if command -v greetd &> /dev/null; then
    palette="$HOME/.config/themes/current.json"
    if [ "$changed_greeter" = true ] || ! sudo test -f /etc/greetd/regreet.css; then
        if [ -r "$palette" ]; then
            sudo /usr/local/bin/update-greeter-theme "$palette" && print_success "Greeter themed from $palette"
        else
            print_error "No $palette — greeter left unthemed (run theme-set <flavor>, then re-run setup)"
        fi
    fi
    wallpaper="$(readlink -f "$HOME/.cache/current_wallpaper" 2>/dev/null || true)"
    if [ -f "$wallpaper" ] && command -v ffmpeg &> /dev/null && [ ! -f /usr/share/backgrounds/greeter/current-blur.png ]; then
        sudo /usr/local/bin/update-greeter-bg "$wallpaper" > /dev/null && print_success "Greeter background rendered"
    fi
    current_dm="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
    if [[ "$current_dm" == */greetd.service ]]; then
        print_skip "greetd is already the display manager"
    else
        # -f replaces another display-manager.service link (sddm/lightdm); takes effect next boot
        sudo systemctl enable -f greetd.service && print_success "greetd enabled as display manager (next boot)"
    fi
else
    print_skip "greetd not installed, skipping login screen"
fi

# ----------------------------------------------------------------- GRUB ----
GRUB_CMDLINE='quiet splash loglevel=3 vt.global_cursor_default=0'
if [ -f /etc/default/grub ] && command -v grub-mkconfig &> /dev/null; then
    if grep -qxF "GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE\"" /etc/default/grub; then
        print_skip "GRUB cmdline already set"
    else
        sudo cp -a /etc/default/grub "/etc/default/grub.bak-$STAMP"
        sudo sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE\"|" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1 && print_success "GRUB cmdline set, grub.cfg regenerated"
    fi
fi

echo ""
echo "✅ System files deployed"
