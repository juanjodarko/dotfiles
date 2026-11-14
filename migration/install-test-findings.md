# install.sh on a fresh Arch VM — findings (run 2026-11-04)

Setup: `vm-rebuild` (unattended archinstall base, 267 pkgs) → `git clone -b omarchy-quattro` (public, https) →
submodules supplied as bundles → `./install.sh --non-interactive`. Run 1 died at `chsh`; run 2 (shell pre-set via
`sudo chsh`) reported "Installation Complete!". Result: a terminal setup, **not** a usable desktop.

| # | Severity | Finding | Evidence | Fix direction |
|---|---|---|---|---|
| 1 ✅ | High | Submodules use SSH URLs; a fresh machine has no GitHub key. `personal` + `dockshell` are private. | `git submodule update --init` → "Could not read from remote repository" | Bootstrap step: `gh auth login`/SSH key before submodules; https URLs for the public ones |
| 2 ✅ | Medium | `personal` submodule is 3.2 GB (wallpapers) | bundle size; filled the VM's tmpfs `/tmp` | Shallow clone, or split wallpapers out / make them optional |
| 3 ✅ | High | Module list is stale: still deploys waybar + rofi; never deploys `quickshell` (DockShell), `kitty`, `bin`, `vicinae`, `yazi`. `wofi` checked but not installed | stow log; `NOT LINKED` for quickshell/kitty/bin | Rebuild the module list from what the laptop actually stows |
| 4 ✅ | High | `chsh` prompts for a password → `--non-interactive` aborts the whole install | run 1: `chsh: Authentication token manipulation error`, `EXIT=1` | `sudo chsh -s … "$USER"` (or `usermod -s`), never block in non-interactive |
| 5 ✅ | **Critical** | On a fresh machine stow *folds* `~/.local/share` into `personal/.local/share` → every app's data lands in the git repo | `~/.local/share -> ../dotfiles/personal/.local/share`; mise + nvim data untracked in `personal` | Create `~/.local/share` (and other shared dirs) before stowing, or `stow --no-folding` |
| 6 ✅ | High | Packages: VM has 66 explicit vs laptop 253 — **206 missing**, 39 of them AUR. No AUR helper is bootstrapped, so AUR is impossible. Missing desktop pieces: quickshell, kitty, vicinae-bin, greetd/greetd-regreet, hyprpolkitagent, gpu-screen-recorder, tesseract(+eng), zbar, whisper-cpp, wofi, yay … | `comm` of `pacman -Qqe` laptop vs VM | Curated package manifest split by layer (base / desktop / laptop-hardware / personal apps) + yay bootstrap |
| 7 ✅ | **Critical** | Hyprland config does not load: `hyprland.lua:211` `require`s split-monitor-workspaces, whose clone is gitignored and never fetched. Also VM got Hyprland **0.57.1** while the plugin is pinned to `release/0.56.x` (laptop 0.56.2) | `Hyprland --verify-config` → `no file './split-monitor-workspaces.so'` | Install step clones the plugin on the branch matching installed Hyprland (dotfiles-upstream already knows `branchTracksPkg`) |
| 8 ✅ | High | Theme init nests the link: `~/.config/themes/themes -> repo` instead of `~/.config/themes -> repo` | `ls -la ~/.config/themes` | Don't `mkdir ~/.config/themes` before linking (setup/init dirs) |
| 9 ✅ | Medium | System layer not covered: greetd/ReGreet configs, polkit rule, supergfxd/TLP confs, Docker↔libvirt forward unit — all hand-deployed on the laptop | no install step touches `/etc` for these | A root-level step (or archiso airootfs) for `/etc` configs |
| 10 | Low | mise reinstalled every run (`~/.local/bin` not on PATH); `Tmux: unknown option` in version check | run 2 log | PATH fix; `tmux -V` |

**Graphical session — PASS (2026-11-12).** VM-only greetd autologin → `start-hyprland`: Hyprland 0.57.2 with
`Renderer: virgl (Mesa Intel HD Graphics 630)`, no config errors; DockShell bar (workspaces, indicators, clock, tray),
swaync, Vicinae (`vicinae-server`), hypridle, hyprpolkitagent and a wallpaper all up.

## Status

- **2026-11-05 — #4 #5 #7 #8 FIXED** (commit `36e28c0`), verified on a fresh VM with
  `migration/planned-iso/vm-install-test`: all 8 checks PASS (exit 0, zsh login shell, real ~/.config /
  ~/.local/share / ~/.local/bin, clean `personal`, `~/.config/themes` link, `Hyprland --verify-config`).
- Test-infra fixes found on the way: GRUB installed `removable` (UEFI NVRAM entry broke between rebuilds);
  `vm-rebuild` forgets the old host key; harness accepts the new one.
- **2026-11-12 — #3 #6 FIXED** (commits `d95087a` … `f63fe51`): layered `packages/` manifests (base/desktop/apps/dev +
  `hardware-<hostname>`), multilib + yay-bin bootstrap, module lists mirroring the laptop/Mac. Fresh VM: all 16 checks
  PASS — 163 layer packages installed, waybar/rofi absent, DockShell/kitty/swaync/bin linked, Hyprland config verifies.
- Fixed on the way: a TPM clone blip aborted `init_plugins.sh` before the Hyprland plugin (clones now retry, non-fatal);
  `vm-rebuild` starts libvirt's network itself and tolerates a half-finished previous run.
- **2026-11-12 — #1 #2 #9 FIXED.** #9: `system/{common,hardware-<host>}` + `setup/init_system.sh` (greetd/ReGreet,
  polkit, units, udev, modprobe, GRUB). #1: `bootstrap.sh` (gh device login + HTTPS; the login itself needs a human, so
  it is not exercised by the harness). #2: wallpapers on HomeNAS (`wallpapers-sync`), `personal` shallow. Fresh-VM
  harness: all 23 checks PASS. Also fixed: fresh machines never generated `current.json`/`current.kitty`
  (init_themes now runs theme-set), and `theme-set` hung forever headless on `swaync-client` (now guarded + timeout).
- **2026-11-13/14 — own ISO, end to end.** `dotfiles-arch` ISO: archinstall + the whole desktop in the chroot
  (~23 min), first boot = ReGreet → Hyprland; `vm-iso-test` 21/21 PASS. Phase 2 (`dotfiles-finish`) verified by hand:
  GitHub token from 1Password (Private / "GitHub Personal Access Token" / token), 4 private submodules, links, DockShell
  up. Browser login abandoned as the primary path: Chrome crashed in the VM.
- Open: #10, plus:
  - #13 Low — AUR `cliamp` fails to build (exit status 4) on a fresh install.
  - #14 Fixed — fresh machines folded `~/.config/toot`, so toot wrote its Mastodon token into the repo.
  - #11 Low — fresh machine shows Vicinae's first-run onboarding and Docker Desktop's subscription dialog at first
    login (Docker Desktop's user service is active on the laptop too, so this matches today's behavior).
  - #12 Low — on the laptop `systemctl --user is-enabled docker-desktop.service` fails with "Too many levels of
    symbolic links" (likely a loop between stowed `~/.config/systemd/user` links).
