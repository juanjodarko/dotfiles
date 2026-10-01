# Vicinae × Hyprland — native extension

**Status: BUILT & INSTALLED.** Built with `vici build` into
`~/.local/share/vicinae/extensions/hyprland/` and verified live under
`vicinae-bin` 0.29.1 (`@vicinae/api` 0.29, React 19 types). Commands load as
`@jjruiz/hyprland:switch-window`, `:switch-theme` and `:capture`. Not a stow
package — the built output, not this source, is what Vicinae loads.

A minimal native `@vicinae/api` extension for this Arch + Hyprland setup, meant to prove out
two things: (1) how a Vicinae-native command is structured, and (2) that the Raycast component
model (`List` / `ActionPanel` / `Action` / React hooks) carries over unchanged — only the
import (`@vicinae/api`) and the *capabilities* (shelling out to `hyprctl`) are Linux-native.

## Commands

| Command | What it does | Native bit |
|---|---|---|
| **Switch Window** (`src/switch-window.tsx`) | Lists open windows MRU-first, focus / close on select | `hyprctl clients -j`, `hyprctl dispatch 'hl.dsp.focus({window=…})'` (Lua config; legacy `focuswindow` fallback) |
| **Capture** (`src/capture.tsx`) | Screenshot / record / OCR / QR / color picker menu | runs `~/.local/bin/capture-*` (ported from Omarchy) detached, after closing the launcher |
| **Switch Theme** (`src/switch-theme.tsx`) | Swaps the Catppuccin flavor | calls headless `theme-set <flavor>` |

## Backend split (done)

`Switch Theme` calls a **headless** `theme-set <flavor>`, now living at
`bin/.local/bin/theme-set` — extracted out of the old wofi switcher so every
frontend shares one backend:

```
wofi popup  ─┐
Vicinae      ├──►  theme-set <flavor>   (single source of truth)
DockShell    ─┘        (swaps symlinks + current.json, reloads apps, syncs Vicinae's own theme)
```

## Build & install

The dev CLI is `vici` (from `@vicinae/api`, in `node_modules/.bin`), not the
`vicinae` launcher binary:

```sh
cd vicinae-extensions/hyprland
npm install
npx vici build          # compiles + installs into ~/.local/share/vicinae/extensions/hyprland
#   npx vici develop    # hot-reload dev session instead
```

`assets/icon.png` (512×512) is required by the manifest.

## Invoking / binds

Vicinae loads the commands as `@jjruiz/hyprland:switch-window` /
`@jjruiz/hyprland:switch-theme` (`vicinae cmd ls`). Launch or bind them via:

```
vicinae cmd launch '@jjruiz/hyprland:switch-window'
vicinae cmd launch '@jjruiz/hyprland:switch-theme'
```

They're also reachable from inside the launcher (SUPER+SPACE → search "Switch…").

## Notes / TODO
- `focusHistoryID` gives MRU order (0 = focused). Could add `Move to Current Workspace`
  (`hyprctl dispatch movetoworkspace`) and special-workspace (scratchpad) actions.
- Swap the `execFile("hyprctl", …)` calls for a native `@vicinae/api` WM/D-Bus binding
  if/when one lands upstream — that's exactly the "better Linux plugins" contribution.
- Publishing target: the Vicinae store monorepo (`vicinaehq/extensions`, PR-reviewed).
