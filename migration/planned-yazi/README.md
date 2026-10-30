# File-manager stack — yazi (PLANNED, not implemented)

**Status: planning only. Nothing here is deployed.** These are ready-to-use, schema-verified
configs staged for a future implementation step — they are NOT in the live `themes/` or a
`yazi/` stow package, and the theme switcher has NOT been modified. Deploy only after explicit
go-ahead, per the migration guardrails (VM first / per-item approval).

## The decision (mirrors Omarchy Quattro)

- **GUI (occasional, "just make it nice"): Nautilus** — Omarchy's default, `Super+Shift+F`.
  Support cast: `sushi` (spacebar preview), `gvfs-*` (mount phones/network), `udiskie` (automount).
  Note: GTK app → themed via GTK theme + icons, effectively **flavor-static** (won't track the
  Catppuccin switcher live).
- **TUI (daily driver): yazi** — Rust, fast, image previews via the **kitty graphics protocol**
  (pairs with your kitty terminal). **Follows the central switcher** (TOML theme, per flavor).

## What's staged here

| File | Destination when implemented |
|---|---|
| `themes/catppuccin/{mocha,latte,frappe,macchiato}.yazi` | `themes/.config/themes/catppuccin/` |
| `yazi/yazi.toml` | new stow package `yazi/.config/yazi/yazi.toml` |

Theme files are UI-chrome only (icons + syntax highlighting use yazi defaults; add the
catppuccin icon set / tmTheme later for the full look). Verified against yazi ≥ 25.x schema
(`[mgr]`, `[pick]`, `[app]`, …).

## Install deps (when implementing)

```sh
# TUI
yay -S yazi ffmpegthumbnailer p7zip jq poppler fd ripgrep fzf zoxide imagemagick resvg
# GUI
yay -S nautilus sushi gvfs gvfs-mtp gvfs-smb udiskie ffmpegthumbnailer
```

## Deploy steps (when implementing)

1. `mv migration/planned-yazi/themes/catppuccin/*.yazi themes/.config/themes/catppuccin/`
2. `mkdir -p yazi/.config/yazi && mv migration/planned-yazi/yazi/yazi.toml yazi/.config/yazi/`
3. `stow yazi` (creates `~/.config/yazi/`).
4. Apply the switcher edits below to `waybar/.config/waybar/scripts/wofi-theme-switcher.sh`.
5. `.gitignore`: add `themes/.config/themes/current.yazi` and `yazi/.config/yazi/theme.toml`.
6. Trigger the switcher once (or `cd ~/.config/themes && ln -sf catppuccin/<flavor>.yazi current.yazi`)
   and open a fresh yazi to confirm.

### Switcher edits (5 spots)

```diff
# variables block
  CURRENT_KITTY="$THEMES_DIR/current.kitty"
+ CURRENT_YAZI="$THEMES_DIR/current.yazi"
  CURRENT_TMUX="$THEMES_DIR/current.tmux"

# init_theme_files(): symlink block
  [ ! -L "$CURRENT_KITTY" ] && ln -sf "catppuccin/${default_theme}.kitty" current.kitty
+ [ ! -L "$CURRENT_YAZI" ] && ln -sf "catppuccin/${default_theme}.yazi" current.yazi
  [ ! -L "$CURRENT_TMUX" ] && ln -sf "catppuccin/${default_theme}.tmux" current.tmux

# init_theme_files(): after the flavor-file line, before the closing }
+ # yazi has no `include`; point its theme.toml at the central current.yazi.
+ # Absolute target so it resolves regardless of stow folding. Non-destructive.
+ if [ ! -e "$HOME/.config/yazi/theme.toml" ]; then
+     mkdir -p "$HOME/.config/yazi"
+     ln -sf "$CURRENT_YAZI" "$HOME/.config/yazi/theme.toml"
+ fi

# switch section
  ln -sf "catppuccin/${theme_file}.kitty" current.kitty
+ ln -sf "catppuccin/${theme_file}.yazi" current.yazi
  ln -sf "catppuccin/${theme_file}.tmux" current.tmux

# reload section (comment only — yazi has no live theme reload)
  pkill -SIGUSR1 kitty 2>/dev/null
+ # yazi reads theme.toml on launch; new instances pick up the flavor. Running
+ # sessions don't hot-reload the theme (reopen yazi).
```

## Caveats
- yazi does **not** hot-reload the theme — new instances get it; reopen a running yazi.
- `yazi.toml` openers point at `nvim`, `mpv`, `imv`, `xdg-open`, `nautilus`. Adjust to taste.
