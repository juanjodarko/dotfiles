# GPU switcher — backend + waybar module (STAGED, not deployed)

**Status: planning sketch.** Nothing here is installed. These are ready-to-drop files that turn your existing
supergfx **read layer** into an interactive Integrated⇄Hybrid switcher. Deploy only after the driver migration
(`../nvidia-580xx-migration.md`) verifies, and per the migration guardrails (per-item approval).

Usage target: **dGPU off by default; flip to Hybrid for the occasional road-trip game; flip back.**

## The shape — one backend, thin frontends (same as the theme switcher)

```
              gpu-mode-set <Integrated|Hybrid|toggle>   ← the ONE write path
              • validate mode           • confirm (logs you out)
              • capability guard        • supergfxctl -m        • notify
                        ▲                                   ▲
        on-click menu   │                                   │  (later)
   ┌────────────────────┴───────┐            ┌──────────────┴───────────────┐
   │ waybar custom/gpu (NOW)     │            │ Quickshell gpu-mode widget   │
   │  status.sh → icon+state     │            │  io.github.juanjodarko…      │
   │  menu.sh  → pick → backend  │            │  same backend, nicer surface │
   └─────────────────────────────┘            └──────────────────────────────┘
        ▲ live refresh via SIGRTMIN+8
   gpu-mode-monitor.sh (already yours) on supergfxd NotifyGfx
```

## Files here

| File | Deployed to | Role |
|---|---|---|
| `gpu-mode-set` | `bin/.local/bin/gpu-mode-set` | headless backend (validate → guard → confirm → `supergfxctl -m` → notify) |
| `waybar/gpu-mode-status.sh` | `~/.config/waybar/scripts/` | emits JSON `{text,tooltip,class}` from `supergfxctl -g` |
| `waybar/gpu-mode-menu.sh` | `~/.config/waybar/scripts/` | on-click menu → calls the backend `--no-confirm` |
| `waybar/config.jsonc` | merge into `~/.config/waybar/config` | the `custom/gpu` module block |
| `waybar/style.css` | merge into `~/.config/waybar/style.css` | off=green, Hybrid=peach "battery-warning" tint |

## Reuses what you already have
- `bin/.local/bin/gpu-mode-check.sh` — mode→exit-code (the read logic; status.sh mirrors it).
- `bin/.local/bin/gpu-mode-monitor.sh` + `systemd/.../gpu-mode-monitor.service` — watches supergfxd's D-Bus
  `NotifyGfx`. **Deploy step:** add `pkill -RTMIN+8 waybar` to its change handler so the bar refreshes live.
- Capability detection keys off the supergfx **mode name**, never live PCI-device counting → avoids Omarchy's
  bug #5428 (toggle disappearing once the dGPU leaves the bus in Integrated).

## Deploy steps (when implementing — after the driver migration passes)
1. `install -m755 gpu-mode-set ~/.local/bin/gpu-mode-set` (or into the `bin/` stow package).
2. `install -m755 waybar/gpu-mode-status.sh waybar/gpu-mode-menu.sh ~/.config/waybar/scripts/`.
3. Merge `waybar/config.jsonc` block + add `custom/gpu` to a modules array; merge `waybar/style.css`.
4. Add `pkill -RTMIN+8 waybar` to `gpu-mode-monitor.sh`'s on-change branch (live refresh).
5. Restart waybar. Click the icon → confirm → it switches + tells you to log out.

## Depends on the driver being fixed first
`gpu-mode-set` **refuses to switch to Hybrid while `nvidia-open` is installed** (it can't drive the Pascal GTX 1060),
pointing you at `../nvidia-580xx-migration.md`. So the build order is: **driver migration (gated) → this backend →
waybar module → Quickshell widget.** See the plan's "GPU switcher — build order" section.

## Notes / caveats
- Menu tool defaults to `wofi`; override with `GPU_MENU="rofi -dmenu -p GPU"` (or Vicinae later).
- Integrated⇄Hybrid **always requires a logout** (supergfxd, non-mux Razer) — the UX leans into that (confirm +
  "log out to apply" + a post-login "revert when done" nudge is a nice-to-add).
- Nerd Font glyphs in `status.sh` are placeholders — swap to taste.
