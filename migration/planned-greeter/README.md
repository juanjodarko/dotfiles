# greetd + ReGreet login screen — spec (STAGED, VM-first, not installed)

**Status: design/spec only.** This replaces SDDM with a lighter, palette-templated login screen. It touches the **login
path**, so it is **strictly VM-first** and gated — keep SDDM installed and working until greetd is proven in a VM, then on
the real machine with a TTY fallback ready. Companion: dossier §N.

Goal (your ask): **blurred current wallpaper** (like hyprlock) + **user selector with a password**, Catppuccin-templated from
the system theme, light + easy to configure.

## Why this shape
- **greetd** = tiny login daemon; **ReGreet** = GTK4 greeter run inside **cage** (a single-output kiosk compositor). No Qt/KDE,
  no Xorg (your current SDDM greeter runs on X11 → this drops that). All three are in Arch **`extra`** (no AUR).
- **User selector + password + session picker are ReGreet built-ins** — nothing custom to build. It remembers the last user/session.
- **Blur:** the greeter runs *before* your session (as user `greeter`), so it can't blur live like hyprlock. Instead we
  **pre-render a blurred copy of `~/.cache/current_wallpaper`** and point ReGreet's `[background] path` at it. Regenerated on wallpaper change.
- **Theming:** the switcher writes `/etc/greetd/regreet.css` from the active Catppuccin palette — same "template from `current.json`"
  mechanism as the bar/kitty/yazi. One flavor flip → login screen re-tints too.

## Files here → destinations
| File | Deploy to |
|---|---|
| `greetd-config.toml` | `/etc/greetd/config.toml` |
| `regreet.toml` | `/etc/greetd/regreet.toml` |
| `regreet.css` | `/etc/greetd/regreet.css` (Mocha reference; normally generated) |
| `bin/update-greeter-bg` | `/usr/local/bin/update-greeter-bg` (root, +x) |
| `bin/update-greeter-theme` | `/usr/local/bin/update-greeter-theme` (root, +x) |
| `polkit/49-greeter.rules` | `/etc/polkit-1/rules.d/49-greeter.rules` |

Palettes come from `../planned-bar/palettes/catppuccin-<flavor>.json` (deploy those into the theme tree, e.g.
`themes/.config/themes/palettes/catppuccin/`).

## The blur pipeline (matches hyprlock's look)
`update-greeter-bg <wallpaper>` runs **ffmpeg** (already installed — no imagemagick needed):
```
gblur=sigma=18, eq=brightness=-0.09:contrast=0.90:saturation=1.08   → /usr/share/backgrounds/greeter/current-blur.png
```
That approximates your hyprlock `blur_passes=2 / blur_size=4 / brightness=0.82 / contrast=0.89 / vibrancy≈0.17` — tune `sigma`
to taste. Output lives in a **world-readable** system dir so the `greeter` user can read it. (imagemagick alt:
`magick in -blur 0x18 -brightness-contrast -9x-10 out.png`.)

## Switcher / wallpaper hooks (the "templated from system theme" part)
- **On wallpaper change** — add to `change_wallpaper.sh` (and `generate_hyprpaper_config.sh` seeding):
  ```sh
  pkexec /usr/local/bin/update-greeter-bg "$(readlink -f ~/.cache/current_wallpaper)"
  ```
- **On flavor change** — add to `wofi-theme-switcher.sh` (next to the existing `update-sddm-theme` call):
  ```sh
  pkexec /usr/local/bin/update-greeter-theme "$HOME/.config/themes/palettes/catppuccin/${theme_file}.json"
  ```
Both run passwordless via the polkit rule (wheel only), mirroring your `update-sddm-theme` pattern.

## Install (in a VM first)
```sh
sudo pacman -S greetd greetd-regreet cage           # + ensure: ffmpeg jq
sudo install -Dm644 greetd-config.toml /etc/greetd/config.toml
sudo install -Dm644 regreet.toml       /etc/greetd/regreet.toml
sudo install -Dm755 bin/update-greeter-bg    /usr/local/bin/update-greeter-bg
sudo install -Dm755 bin/update-greeter-theme /usr/local/bin/update-greeter-theme
sudo install -Dm644 polkit/49-greeter.rules  /etc/polkit-1/rules.d/49-greeter.rules
# seed the background + css once:
pkexec /usr/local/bin/update-greeter-bg    "$(readlink -f ~/.cache/current_wallpaper)"
pkexec /usr/local/bin/update-greeter-theme "$HOME/.config/themes/palettes/catppuccin/mocha.json"
# SWITCH the display manager (exactly one enabled):
sudo systemctl disable sddm
sudo systemctl enable  greetd
reboot
```

## Multi-user & "session already open"
- ReGreet lists users (respect a uid range like SDDM's MinimumUid/MaximumUid) + a session dropdown (your `hyprland`
  wayland-session). Password auth via PAM.
- **Switching users from a running session** = the bar's `core.syscontrol` "Switch user" → `SwitchToGreeter` (works with
  greetd too via logind) opens this greeter on a new VT; your session stays alive → `loginctl activate <session>` to jump back.
- ⚠ **One honest gap vs SDDM:** greetd has **no `ReuseSession`** (SDDM's "same user logs in twice → restore existing session").
  With greetd, re-entering *your own* locked session is **hyprlock's** job (that's the in-session lock); the greeter is for new
  logins / other users. If same-user auto-reuse matters a lot, that's the one reason to prefer modernized SDDM (dossier §N).

## Rollback (if anything's off)
```sh
sudo systemctl disable greetd && sudo systemctl enable sddm && reboot
```
If the greeter doesn't appear: **Ctrl+Alt+F2** → log in on the TTY → run the rollback. Keep SDDM installed until greetd is proven.

## Caveats / verify-on-install
- **cage is single-output** → the greeter shows on the primary monitor only (fine for login; a minimal sway/Hyprland greeter
  would do multi-monitor but is heavier).
- **ReGreet CSS path/keys vary by version** — confirm `/etc/greetd/regreet.css` is the loaded stylesheet and the `regreet.toml`
  keys against `regreet --help` + the shipped example for the installed `greetd-regreet`.
- The `greeter` user needs read access to the cursor/icon themes referenced in `regreet.toml` (system-wide themes are fine).
