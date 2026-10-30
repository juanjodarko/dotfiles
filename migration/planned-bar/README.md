# Quickshell bar — palette schema + plugin architecture (STAGED design, not deployed)

**Status: planning sketch.** Nothing here runs. Companion to `../quickshell-bar-design.html` and dossier §K.
Design pillars requested (2026-09-03): **empty-by-default bar → add plugins**; minimal core = **workspaces + system-control**;
**multi-user** switching (the reason we're not on Omarchy); and an **Omarchy-style plugin CLI** (clone a repo, one command installs it).

---

## 1. Palette schema (`palettes/catppuccin-<flavor>.json`)

Semantic-role palette in the spirit of Omarchy's `colors.toml`, mapped to your 4 real Catppuccin flavors. Each file has:
- `name`, `flavor`, `mode` (`dark`/`light`)
- **`roles`** (16) — what widgets bind to, so the bar is theme-agnostic:
  `accent` (=mauve), `accent_alt` (=lavender), `bg`/`bg_alt`/`bg_deep` (base/mantle/crust),
  `surface`/`surface_alt`, `overlay`, `fg` (text), `muted` (subtext0), `selection` (surface2),
  `urgent`/`error` (red), `success` (green), `warning` (yellow), `info` (blue).
- **`palette`** (26) — the full named Catppuccin set for widgets that want a specific color.

### Switcher integration (the P0 prerequisite)
Add ONE step to `wofi-theme-switcher.sh` (and the future headless `theme-set`): on switch, write
`~/.config/themes/current.json` as a **real file via atomic replace** (copy the active flavor's palette to a temp, then
`mv` over it). Atomic-rename reliably triggers Quickshell's `FileView` watcher; a symlink would not (Qt drops the watch on relink).

```sh
# in the switch section, after the symlinks:
install -Dm644 "$THEMES_DIR/palettes/catppuccin/${theme_file}.json" "$THEMES_DIR/.current.json.tmp"
mv -f "$THEMES_DIR/.current.json.tmp" "$THEMES_DIR/current.json"   # atomic
```
Ship the 4 palette files into the theme tree (`themes/.config/themes/palettes/catppuccin/`) and gitignore `current.json`.
The bar's `Theme` singleton reads `current.json`; flipping a flavor repaints the bar with everything else. **On Omarchy**,
point the same singleton at `~/.local/state/omarchy/current/theme/colors.toml` via a tiny toml→json step — same bar, both worlds.

---

## 2. Empty bar → plugins (the architecture)

The bar core renders **nothing but a slot host**. What appears is whatever `shell.json` lists, mounted from plugins.

```
shell.json  ─ modules: { left:["core.workspaces"], center:[], right:["core.syscontrol"] }
                                   │
                          PluginRegistry (host singleton)
       scans ~/.config/quickshell/plugins/<id>/  +  built-in core/  →  reads manifest.json
                                   │  instantiates entry QML by kind, injects host singletons
                                   ▼
        Bar RowLayout mounts the bar-widget instances named in shell.json (in order)
```

- **Plugin = a git repo** with `manifest.json` + QML:
  ```json
  { "id": "io.github.you.clock", "name": "Clock", "version": "0.1.0",
    "kind": "bar-widget", "entry": "Widget.qml", "author": "you", "description": "..." }
  ```
  `kind` ∈ `bar-widget` | `panel` | `service`. Installed to `~/.config/quickshell/plugins/<id>/`.
- **Host singletons injected** into every plugin (the contract): `Theme` (§1 palette), `Config` (shell.json), `Hyprland`.
  This is deliberately close to Omarchy's injected `Color`/`Style`/`shell` props → a **compat shim** can host *forked* Omarchy
  `bar-widget` plugins by mapping their imports to ours (dossier §K). Our plugin system and the Omarchy-fork goal are the same machine.
- **Only core.workspaces + core.syscontrol are built-in** (always available). Everything else — clock, battery, audio, tray,
  gpu-mode, cpu, media… — is a plugin, shipped as our own "first-party" plugin repos or third-party.

---

## 3. Minimal core (the simplest bar)

| id | what | source |
|---|---|---|
| `core.workspaces` | per-monitor workspaces (split-monitor-workspaces aware; filter by `monitor.name`) | built-in |
| `core.syscontrol` | session/power menu incl. **multi-user** (§4) | built-in |

A blank bar with just these two is the floor; you grow it with `bar plugin add …`.

---

## 4. `core.syscontrol` — session/power with multi-user

Click → popup with: **Lock · Logout · Switch user · Suspend · Hibernate · Reboot · Shutdown.** Reuses/extends
`bin/.local/bin/power-menu.sh`. Actions:

| Action | Command |
|---|---|
| Lock | `hyprlock` |
| Logout | `hyprctl dispatch exit` (or `loginctl terminate-session "$XDG_SESSION_ID"`) |
| Suspend / Hibernate | `systemctl suspend` / `systemctl hibernate` |
| Reboot / Shutdown | `systemctl reboot` / `systemctl poweroff` |
| **Switch user (new login)** | `busctl call org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat SwitchToGreeter` |
| **Switch to a logged-in user** | `loginctl list-sessions` → `loginctl activate <session>` |

**Multi-user is the Omarchy differentiator.** systemd-logind already supports concurrent sessions; SDDM implements the
freedesktop `org.freedesktop.DisplayManager` D-Bus API, so **`SwitchToGreeter` opens a fresh login on a new VT while your
current session stays alive** — switch back and forth via the DM/VT. Existing users' sessions are reachable with
`loginctl activate`.
⚠️ **Verify when implementing:** the exact SDDM seat path (`Seat0` vs another) and that SwitchToGreeter is wired in this SDDM
build; fallback = lock (`hyprlock`) + `chvt` to the greeter's VT. A small `session-control.sh` backend holds this logic (the
"one backend, thin frontend" pattern), so the QML widget just calls it.

---

## 5. The plugin CLI — `bar` (Omarchy-style)

A headless script `bin/.local/bin/bar` (mirrors `omarchy plugin …`; same shape as `theme-set`/`gpu-mode-set`):

```
bar plugin add <git-url>     # git clone → ~/.config/quickshell/plugins/<id>/, validate manifest, enable in shell.json
bar plugin list              # installed + enabled/disabled
bar plugin enable  <id>      # add to shell.json module list
bar plugin disable <id>      # remove from shell.json (keeps files)
bar plugin remove  <id>      # rm dir + drop from shell.json
bar plugin update  [<id>]    # git pull one/all
```
- `add` = `git clone <url> plugins/<tmp>` → read `manifest.json` → move to `plugins/<id>/` → append id to `shell.json`.
  PluginRegistry hot-reloads on the new dir; no bar restart.
- Because the manifest/kind vocabulary mirrors Omarchy's, `bar plugin add <omarchy-plugin-url>` can host a **forked** Omarchy
  widget once the compat shim maps its host imports (dossier §K).
- **Safety note (crib from Omarchy):** git-installed plugins run **unsandboxed** QML. Omarchy denylists `*.lua`/terminal
  configs/symlinks from cloned *themes*; we should at least validate the manifest and review third-party plugin QML before enabling.

---

## 6. How this maps to / differs from Omarchy

| | Omarchy | Ours |
|---|---|---|
| Runtime | one `omarchy-shell` process, plugins are `omarchy.*` | one `qs` process, plugins are `bar-widget`s |
| Install | `omarchy plugin add <url>` | `bar plugin add <url>` (same idea) |
| Theming | central `colors.toml` → `Color`/`Style` singletons | `current.json` roles → `Theme` singleton |
| Default bar | ~7 slots (menu/ws/media/clock/audio/power) | 2 (workspaces + syscontrol), grow by plugins |
| **Multi-user** | **not exposed** | **switch-user built into core.syscontrol** ✅ |
| Marketplace | omarchyplugins.com (host-locked) | any git URL; can fork Omarchy plugins via shim |

---

*Files here: `palettes/catppuccin-{mocha,latte,frappe,macchiato}.json` (16 roles + 26 colors, your exact hex). Design only; nothing deployed.*
