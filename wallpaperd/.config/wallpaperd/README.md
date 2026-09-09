# wallpaperd

A small, generic wallpaper module for Hyprland (hyprpaper): pick + apply a
wallpaper at login and on a keybind, keep a symlink to the current one for
hyprlock, and refresh the greetd/ReGreet login background so the next login
shows your last wallpaper.

Productized from a pair of ad-hoc `~/.config/hypr/*.sh` scripts.

## Commands

```
wallpaperd generate   # random pick + apply (run at session start)
wallpaperd next        # re-roll now (bound to Alt+Shift+W)
wallpaperd pick        # open the full-screen picker grid (bound to Super+W)
wallpaperd set <path>  # apply a specific wallpaper to every monitor
wallpaperd current     # print the current (primary) wallpaper
wallpaperd config      # print the resolved configuration
```

## Picker

`wallpaperd pick` opens a standalone, full-screen Quickshell **coverflow**
(`picker/picker.qml`), Omarchy-style: the selected wallpaper is expanded and in
full colour, the neighbours are skewed slices in greyscale, and colour animates
in over ~1s as you land on one. **Arrow keys** move, **type** to filter,
**Enter**/click sets, **Esc** clears the filter / cancels. Only nearby items are
loaded (lazy).

Thumbnails are cached with `vipsthumbnail` (960px) under
`~/.cache/wallpaperd/thumbnails/`, keyed by path+mtime, and generated **lazily**:
the picker opens instantly and a small worker pool renders thumbnails only for
the wallpapers you browse near, showing the full image until each one lands. So a
huge library never pays an up-front cost — only what you actually look at is
cached. `wallpaperd thumbs` optionally pre-generates them all in parallel.

## Configuration — `config.lua`

A Lua file returning a table (read via the system `lua`). Keys:

| key | default | meaning |
|---|---|---|
| `wallpapers_dir` | `~/.config/wallpaperd/wallpapers` | where wallpapers live (`~`/`$HOME` ok) |
| `backend` | `hyprpaper` | wallpaper backend (only hyprpaper for now) |
| `per_monitor` | `true` | different random wallpaper per monitor vs one everywhere |
| `current_symlink` | `~/.cache/current_wallpaper` | symlink kept pointing at the primary (hyprlock reads it) |
| `update_greeter` | `true` | refresh the ReGreet login background on change |
| `ultrawide_min_width` | `3440` | (reserved) monitors ≥ this get a stitched image — *not implemented yet* |

`WALLPAPERD_SKIP_GREETER=1` skips the greeter update for one run.

## Setup

1. **Stow** the package: `stow -d ~/dotfiles -t ~ wallpaperd`.
2. **Point it at your wallpapers** (kept out of git, per-machine):
   ```
   ln -s ~/wallpapers ~/.config/wallpaperd/wallpapers
   ```
3. **Hyprland** (`hyprland.lua` / `hyprland.conf`):
   - autostart: `~/.config/wallpaperd/bin/wallpaperd generate`
   - keybind:   `~/.config/wallpaperd/bin/wallpaperd next`
4. **Greeter sync (optional).** `update_greeter` calls `/usr/local/bin/update-greeter-bg`
   (part of the greetd/ReGreet setup) via `pkexec`. To make it passwordless, deploy the
   polkit rule for the `wheel` group:
   ```
   sudo install -m0644 <this-repo>/migration/planned-greeter/polkit/49-greeter.rules \
     /etc/polkit-1/rules.d/49-greeter.rules
   ```
   Without it, changing the wallpaper prompts for a password (or is skipped).

## Not here yet

Ultrawide 2-wallpaper stitching lands on a separate branch; for now an ultrawide
monitor gets a single wallpaper (a log line notes it).
