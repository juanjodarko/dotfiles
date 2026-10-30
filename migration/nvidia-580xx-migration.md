# NVIDIA driver migration — `nvidia-open` → `nvidia-580xx` (Pascal fix)

**Status: GATED PROPOSAL. Nothing here has been run.** This is a real-laptop graphics-stack change.
Run it yourself, deliberately, when ready — ideally after the verified backup. It is reversible (see Rollback),
and because the **Intel iGPU is primary**, even a failed NVIDIA build never blocks boot/login — worst case the dGPU
just doesn't come up.

Goal: make the **GTX 1060 Mobile (Pascal)** actually usable in supergfx **Hybrid** mode, so the GPU switcher
(dossier §M, `gpu-switcher-design.html`) has something to switch to.

---

## Why (two independent blockers, both must be fixed)

- **A — driver.** Only `nvidia-open 610` is installed. The open kernel modules need a **GSP (Turing+)**; **Pascal is
  unsupported** → the 1060 won't initialize. Fix: the last Pascal-capable proprietary branch, **`nvidia-580xx`** (AUR).
- **B — a rogue leftover.** `/etc/modprobe.d/system76-power.conf` (from the uninstalled **system76-power** tool) does
  `alias nvidia off` + blacklists the nvidia modules — so nvidia can **never load**, even with the right driver.
  The file is **orphaned/unowned** (`system76-power` is not installed). Remove it.

## Verified pre-flight state (already checked, read-only)

| Fact | Value |
|---|---|
| dGPU | GeForce GTX 1060 Mobile (Pascal, `10de:1c20`) |
| Current driver | `nvidia-open 610.57.04` + `nvidia-utils` + `lib32-nvidia-utils` (+ `nvidia-prime`, `nvidia-settings`) |
| Kernel / headers | `linux 7.2.2` + `linux-headers 7.2.2` (match → DKMS can build) |
| Other kernels | none (no `linux-lts` fallback) |
| DKMS working | yes (`openrazer-driver` builds) |
| initramfs | `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)` → rebuild after swap |
| supergfx | 5.2.7, Integrated, `always_reboot:false` (→ logout, not reboot), `logout_timeout_s:60` |
| Rogue conf | `/etc/modprobe.d/system76-power.conf` (unowned, `alias nvidia off`) |
| AUR helper | `yay` present |

## AUR target packages (confirmed)

- `nvidia-580xx-dkms` `580.178.04` — provides/conflicts `nvidia`,`NVIDIA-MODULE`; deps `dkms`, `nvidia-580xx-utils`, `libglvnd`
- `nvidia-580xx-utils` `580.178.04` — provides `nvidia-utils`,`opengl-driver`,`vulkan-driver`; conflicts `nvidia-utils`
- `lib32-nvidia-580xx-utils` `580.178.04` — conflicts `lib32-nvidia-utils` (needed for Steam/Proton)
- `nvidia-580xx-settings` `580.178.04` — optional; conflicts `nvidia-settings`

---

## Optional safety net first (recommended on a rolling kernel)

`nvidia-580xx` is a **frozen** branch; a future `linux` bump could outrun it and fail the DKMS build. An LTS kernel is a
cheap fallback to boot into if that ever happens:

```sh
sudo pacman -S --needed linux-lts linux-lts-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg   # or your bootloader's regen; adds an LTS boot entry
```

DKMS will then build the nvidia module for **both** kernels automatically.

---

## Migration steps

> Do a **full** system sync first (never partial-upgrade on Arch). If the kernel bumps, reboot before building the driver
> so DKMS builds against the kernel you're running.

```sh
sudo pacman -Syu
# if the kernel changed: reboot now, then continue.
```

### 1. Remove the rogue system76-power leftover (Blocker B)

```sh
# Confirm it's truly unowned (should print nothing / an error), then remove it:
pacman -Qo /etc/modprobe.d/system76-power.conf 2>/dev/null || sudo rm -v /etc/modprobe.d/system76-power.conf
```

Leave the others alone: `supergfxd.conf` is managed by supergfxd; `nvidia.conf` (`modeset=1 fbdev=1`) is fine.

### 2. Swap the driver (Blocker A)

```sh
yay -S nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils
# Optional but recommended (keeps nvidia-settings version-matched):
yay -S nvidia-580xx-settings
```

When prompted, **accept removal of the conflicting packages**: `nvidia-open`, `nvidia-utils`, `lib32-nvidia-utils`
(and `nvidia-settings` if you take the optional one). yay resolves this in one transaction.

**Watch the DKMS build** at the end of the install — this is the make-or-break step. It must report a successful build
for `nvidia/580.178.04` against `7.2.2-arch1-1`.

### 3. Rebuild the initramfs (drivers changed, and nvidia is in MODULES)

```sh
sudo mkinitcpio -P
```

### 4. (Optional cleanup) drop the Turing-only power option

`/etc/modprobe.d/nvidia-pm.conf` sets `NVreg_DynamicPowerManagement=0x02` (fine-grained RTD3) — a **Turing+** feature that
does nothing on Pascal. Optional:

```sh
sudo rm -v /etc/modprobe.d/nvidia-pm.conf      # or set the value to 0x00
```

### 5. Verify the module built

```sh
dkms status                     # expect: nvidia/580.178.04, 7.2.2-arch1-1, x86_64: installed
supergfxctl -s                  # modes still listed
```

---

## Verify the dGPU actually works

### 6. Switch to Hybrid (this logs you out)

```sh
supergfxctl -m Hybrid
# supergfxd will require a logout to apply (~60s timeout). Save work, then log out and back in.
# First time, a full reboot is the safest way to be sure early KMS/initramfs is clean.
```

### 7. After re-login (now in Hybrid) — the decisive checks

```sh
nvidia-smi -L                                   # MUST list: GPU 0: NVIDIA GeForce GTX 1060 ...
lspci -k | grep -A3 -Ei 'vga|3d'                # nvidia line → "Kernel driver in use: nvidia"
prime-run __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep -i "OpenGL renderer"   # needs mesa-utils → shows NVIDIA
```

- **Games:** launch with `prime-run <game>` (Steam launch option: `prime-run %command%`).
- **Local LLMs / CUDA:** no `prime-run` needed — `nvidia-smi` seeing the card means ollama / llama.cpp / PyTorch will use it.

### 8. Back to daily driver (dGPU off, best battery)

```sh
supergfxctl -m Integrated       # logout to apply
```

---

## Rollback (revert to the open driver)

```sh
sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils   # removes the 580xx set via conflicts
sudo mkinitcpio -P
# (the dGPU goes back to non-working, but the system/iGPU is unaffected)
```

To fully undo: also reinstall `nvidia-settings`, and note the removed `system76-power.conf` was junk — don't restore it.

---

## Ongoing maintenance & honest risks

- **Every kernel update rebuilds the DKMS module automatically.** If a future `linux` is too new for the frozen 580
  branch, the build **fails** → the dGPU is unavailable until the AUR package is patched (check its AUR comments) or you
  boot `linux-lts`. **The iGPU and your normal session are never affected** — this is the low-stakes side of running the
  dGPU as secondary.
- **AUR ≠ pacman.** These three packages update via `yay`, not plain `pacman -Syu`. Re-run `yay -Sua` periodically.
- **580xx is a legacy support branch** — limited security fixes, and it will eventually stop supporting new kernels. That's
  the real long-term cost of keeping a Pascal dGPU alive; the alternative is leaving the 1060 dark and using the iGPU only.
- **VM can't validate this** (no passthrough dGPU), so it's inherently a real-hardware step — mitigated by the trivial
  rollback and iGPU-primary safety.
- Leftover orphans after the swap are harmless but can be tidied: `pacman -Qdtq` (e.g. `linux-firmware-nvidia`,
  `libva-nvidia-driver` were pulled by the open stack; keep or remove as you like).

---

*Companion: `gpu-switcher-design.html` (the switcher this unblocks) · `decruft-dossier.md` §M · `omarchy-migration-plan.html`.*
