# Omarchy dotfiles

Personal configuration scoped to [Omarchy](https://omarchy.org/) (tested on
4.0.0.alpha, "Quattro"), kept separate from the plain-Arch configuration in the
repository root.

```bash
# 1. install Omarchy
# 2. clone this repo
git clone --recurse-submodules <repo> ~/dotfiles
# 3. run the installer
~/dotfiles/omarchy/install.sh
```

Preview first with `./install.sh --dry-run`. Undo everything with `./uninstall.sh`.

Requires `stow` and `imagemagick`:

```bash
omarchy pkg add stow imagemagick
```

## Why this is separate from the Arch config

Omarchy 4 replaced most of what the Arch setup provided:

| Arch config | Omarchy 4 |
|---|---|
| waybar, swaync, rofi/wofi, swayosd | the Omarchy shell (Quickshell): bar, notifications, menus, OSD |
| `hyprland.conf` (hyprlang) | `~/.config/hypr/*.lua`, user files loaded after the defaults |
| `themes/` Catppuccin switcher | `omarchy theme` across 23 themes |
| hyprpaper + `change_wallpaper.sh` | per-theme backgrounds with `omarchy theme bg` |

Stowing the Arch packages here would fight all of that, so this directory holds
Omarchy-native equivalents instead.

## Design rules

1. **Never touch `/usr/share/omarchy/`.** It belongs to the package and is
   overwritten on `omarchy update`.
2. **Only extend through Omarchy's documented seams:** user Lua files under
   `~/.config/hypr/`, user templates in `~/.config/omarchy/themed/`, menu
   extensions, and `~/.config/omarchy/backgrounds/`.
3. **Stay reversible.** Everything arrives as a stow symlink, and any real file
   Omarchy owned is backed up to `~/.local/state/omarchy-dotfiles/backups/`
   before being replaced. `uninstall.sh` puts it all back.

## Layout

Each subdirectory is a stow package mirroring a path under `$HOME`.

```
omarchy/
├── install.sh / uninstall.sh
├── hypr/     -> ~/.config/hypr/bindings.lua          personal ALT keybindings
├── shell/    -> ~/.config/omarchy/themed/*.tpl       themed config templates
│              ~/.config/omarchy/extensions/          menu additions
├── bin/      -> ~/.local/bin/omarchy-wallpapers-sync wallpaper classifier
├── ghostty/  -> ~/.config/ghostty/config
└── bat/      -> ~/.config/bat/config
```

## Keybindings

`hypr/.config/hypr/bindings.lua` ports the ALT-based scheme from the Arch setup,
which mirrors the aerospace bindings on macOS. It is an override layer: Omarchy's
defaults load first, and only `ALT + TAB` / `ALT + SHIFT + TAB` are unbound. Every
`SUPER` binding still works.

See everything currently bound with `omarchy menu keybindings --print`.

Two deliberate departures from the Arch config:

- **`ALT + J` (toggle split) was dropped.** Hyprland does not distinguish it from
  `ALT + j` (focus down), so the Arch config could only ever honour one. Focus
  wins; toggle split stays on Omarchy's `SUPER + J`.
- **Workspaces are global, not per-monitor.** The Arch setup used the
  `split-monitor-workspaces` Hyprland plugin for a 1-10 range per monitor. That
  plugin is not part of Omarchy, and carrying a compiled Hyprland plugin across
  updates is a standing maintenance cost.

Monitor bindings are directional (`ALT + CTRL + h/j/k/l`) rather than by output
name, so the same file works on the laptop alone or docked.

## Theming: personal configs that still retint

Omarchy re-renders every theme-dependent config on `omarchy theme set`. The trick
is that apps *include* a generated file rather than surrendering their config.

`omarchy-theme-set-templates` renders `~/.config/omarchy/themed/*.tpl` into
`~/.local/state/omarchy/current/theme/`, and **user templates take priority over
Omarchy's built-in ones**. Placeholders come from the theme's `colors.toml`:

```bash
omarchy-theme-color --file ~/.local/state/omarchy/current/theme/colors.toml --all
```

Available forms: `{{ background }}`, `{{ accent }}`, `{{ red }}`, `{{ bright_blue }}`,
the `_strip` (no `#`) and `_rgb` modifiers, plus `{{ mix a b 30% }}`.

Two integration styles, picked per app:

| App | How | Where |
|---|---|---|
| ghostty | `config-file = ?"…/theme/ghostty.conf"` — own config, colors included | `ghostty/` |
| bat | `--theme="ansi"` — follows the terminal, which Omarchy retints | `bat/` |
| starship | no include mechanism → the template *is* the config; `~/.config/starship.toml` symlinks to the rendered output | `shell/…/themed/starship.toml.tpl` |
| lazygit | same as starship (Omarchy ships an empty lazygit config, so nothing competes) | `shell/…/themed/lazygit.yml.tpl` |
| nvim, btop | Omarchy ships built-in templates already | — |

For starship and lazygit, **edit the `.tpl`, not the file in `~/.config/`** — the
latter is a generated symlink. Re-render with:

```bash
omarchy theme set "$(omarchy theme current)"
```

### tmux is only partly retinted

`omarchy-theme-set-tmux` syncs environment, `window-style` and pane colors, and
the pane borders in `tmux.conf` use ANSI names that follow the terminal. But the
status line is drawn by the **catppuccin tmux plugin**, which paints Catppuccin
regardless of the active Omarchy theme. Making it retint means replacing that
plugin with a templated status line — a design change, not a port, so it is
left alone for now.

## Wallpapers

Omarchy resolves backgrounds per theme, merging two directories (see
`omarchy-theme-bg-next`):

```
~/.config/omarchy/backgrounds/<theme-slug>/       <- personal
~/.local/state/omarchy/current/theme/backgrounds/ <- shipped with the theme
```

Both are scanned with `find -L`, so symlinks work. There is no global pool: a
wallpaper only appears under themes it has been seeded into.

`omarchy-wallpapers-sync` does the seeding. It scores every wallpaper against
every installed theme's palette, then selects in **two directions** and unions
the results:

- **Per wallpaper** (`--top`, default 3) — each wallpaper goes to its best themes.
- **Per theme** (`--per-theme`, default 150) — each theme claims its own
  best-scoring wallpapers.

The second pass exists because the first one alone skews hard. Themes with
muted, "central" palettes win most duels, while distinctive ones are rarely
anybody's top pick: on a 1670-wallpaper collection, top-3-only gave miasma 590
wallpapers and Catppuccin 9. The per-theme floor guarantees every theme is
usable without weakening the per-wallpaper affinity.

Scoring combines three signals:

1. **Mode agreement** — the wallpaper's mean lightness against the theme's
   `dark`/`light`. Weighted highest: a bright wallpaper under a dark theme reads
   as broken however well the accents line up.
2. **Background affinity** — the dominant color against the theme background,
   i.e. whether the desktop feels continuous with the bar and gaps.
3. **Accent affinity** — the wallpaper's saturated colors against the theme's
   hues, weighted by image coverage. Near-grey pixels are excluded so monochrome
   wallpapers do not match everything equally.

Distances are computed in Oklab, where euclidean distance tracks perceived
similarity. Links are prefixed with their match rank (`1-`, `2-`, …) so
`omarchy theme bg next` reaches the best matches first.

```bash
omarchy-wallpapers-sync                      # seed from the recorded sources
omarchy-wallpapers-sync --dry-run            # score and report, write nothing
omarchy-wallpapers-sync --top 5              # more themes per wallpaper
omarchy-wallpapers-sync --per-theme 300      # bigger per-theme floor
omarchy-wallpapers-sync --per-theme 0        # disable the floor
omarchy-wallpapers-sync --theme gruvbox      # restrict to one theme
omarchy-wallpapers-sync --clean              # remove every seeded link
```

Palettes are cached in `~/.cache/omarchy/wallpaper-palettes.json`, keyed by path,
size and mtime, and cache misses are analysed in parallel across cores. The first
run over 1670 wallpapers took 5m27s; subsequent runs take about 11s.

Sources are read from `~/.config/omarchy/wallpaper-sources` (written by
`install.sh`, one path per line) or passed with `--source`. Created links are
recorded in `~/.local/state/omarchy/wallpapers-sync.json`, so re-running
re-seeds cleanly instead of stacking duplicates.

`ALT + SHIFT + W` cycles backgrounds; `SUPER + CTRL + SPACE` opens the picker.

## Not migrated from the Arch config

- `waybar/`, `wofi/`, `rofi/`, `swaync/` — superseded by the Omarchy shell. Their
  helper scripts have native equivalents: `omarchy-menu`, `omarchy-audio-*`,
  `omarchy-network-*`, `omarchy-update`.
- `themes/` — superseded by `omarchy theme`.
- `systemd/`, `udev/`, `wireplumber/`, `setup/` — tied to specific hardware
  (Razer/Legion, fingerprint, SDDM, supergfx). Omarchy has `omarchy-hw-*` and
  `omarchy setup security fingerprint`.
- `hyprland/` beyond the keybindings — monitors, look-and-feel and autostart are
  left at Omarchy's defaults. Add overrides in `~/.config/hypr/monitors.lua`,
  `looknfeel.lua` and `autostart.lua` if needed.

Portable packages (`nvim`, `zsh`, `bash`, `mise`, `eza`, `swayimg`, `toot`,
`personal`, `git`) are untouched by Omarchy and can be stowed from the repository
root as usual.
