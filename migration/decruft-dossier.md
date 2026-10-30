# De-cruft dossier — Week 1 / Step 3

Read-only usage evidence for each cleanup candidate, gathered 2026-08-30 on
branch `omarchy-quattro`. **Nothing here has been deleted.** Deletions happen
only after the backup `verify` passes, on a `cleanup` branch, per-item approved.

Legend: **Rec** = recommendation · risk noted where non-trivial.
Submodule removals need the full deinit procedure (see bottom).

---

## A. macOS-only modules (this is a Linux laptop)  → DELETE

| Item | Size | Git last-touched | Referenced by | Rec |
|---|---|---|---|---|
| `aerospace/` | 20K | 2026-06-05 | only **comments** ("parity with aerospace") in hypr/omarchy — not a runtime dep | **Delete** |
| `yabai/` | 16K | 2023-09-21 | only `skhd`/`mac_personal` (mac world) | **Delete** |
| `skhd/` | 16K | 2023-09-21 | only `yabai`/`mac_personal` | **Delete** |
| `mac_zsh/` | 12K | 2026-04-24 | `./mac`, `mac_personal` | **Delete** |
| `mac_personal/` (submodule) | 100K | 2026-06-05 | `./mac` | **Delete** (deinit) |
| `./mac` (bootstrap) | 4K | 2025-10-14 | stows the mac set above | **Delete** |

Evidence note: every `aerospace` mention in the live Hyprland config and the
omarchy `bindings.lua` is a *comment* documenting that the keymap mirrors the
macOS aerospace layout. The comments can stay; the `aerospace/` config dir is
dead weight.

## B. Superseded X11 / awesome desktop  → DELETE

| Item | Size | Git last-touched | Referenced by | Rec |
|---|---|---|---|---|
| `awesome/` (submodule) | 940K | 2024-12-14 | only `.gitmodules` | **Delete** (deinit) |
| `archived/` (anyrun, betterlockscreen, dunst, wezterm, wofi, ...) | 100K | 2025-10-17 | self-contained | **Delete** |
| `./arch` (bootstrap) | 4K | 2024-07-29 | stows `…,polybar,betterlockscreen,rofi` — references the **dangling** polybar + archived betterlockscreen | **Delete** |
| `./install`, `./clean-env` | 138B/149B | 2021-12-17 | generic stow loop, superseded by `install.sh` (Oct 2025) + `omarchy/install.sh` | **Delete** (confirm nothing else calls them) |

## C. Dead / empty / stale  → DELETE

| Item | Size | Note | Rec |
|---|---|---|---|
| `utilities/` | empty | no tracked files, empty on disk | **Delete** |
| `vim/.vimrc` | 4K | superseded by `nvim/` | **Delete** (or keep as tiny fallback — your call) |
| `bash/` (`.bashrc`,`.bash_profile`) | 12K | untouched since **2021**; you use zsh | **Delete** (or keep as fallback) |

## D. Dangling submodule  → FIX (not just delete)

- `.gitmodules` declares `polybar/.config/polybar/pomobar` → **dir does not exist**,
  not initialized, but a leftover `.git/modules/polybar` remains.
- Fix: remove the stanza from `.gitmodules`, `git config --remove-section`
  submodule.polybar (if present), `rm -rf .git/modules/polybar`.
- Also referenced by `./arch` and `awesome/rc.lua` — both themselves slated for deletion.

## E. Committed backup / example files  → DELETE

| Item | Note | Rec |
|---|---|---|
| `hyprland/.config/hypr/backups/hypr_backup_20250823_192745/` | a whole 9-file backup snapshot, **committed** into the repo | **Delete** |
| `hyprland/.config/hypr/hyprpaper.conf.example` | example file | **Delete** |
| `waybar/.config/waybar/config.jsonc.bak` | editor backup | **Delete** |

## F. Vendored plugin clones with nested `.git`  → BLOAT (handle with care)

Bigger than the plan flagged. **13** nested `.git` dirs (none are declared submodules):

- `tmux/.config/tmux/plugins/*/.git` — **12** TPM-managed plugins (tpm, catppuccin,
  resurrect, continuum, sessionx, thumbs, floax, yank, fzf, fzf-url, sensible,
  vim-tmux-navigator). The `tmux/` dir is **28M** — this is most of it.
- `hyprland/.config/hypr/plugins/split-monitor-workspaces/.git` — 1 (its files are
  **untracked** on disk; the plugin *is* referenced by live hyprland.conf/lua).

Rec: **don't hard-delete.** These are plugin-manager clones. Options: (a) let TPM /
the hypr plugin manager own them — remove from the repo and `.gitignore` the
`plugins/` dirs; (b) keep. Removing breaks the plugins until re-fetched. Needs a
tracked-vs-untracked check per dir first. **Lower priority than A–E.**

## G. Overlaps — the plan's assumptions, corrected by evidence

**Launchers — RESOLVED 2026-09-01: keep both (rofi + wofi).** You run Hyprland, wofi
powers live waybar popups; both stay for now. Expected to be sunset later once Omarchy's
Quickshell bar replaces them. Details below:
- `rofi` → the Hyprland app launcher: `$menu = rofi -show drun` (hyprland.conf:60),
  plus calc/emoji binds. **Keep.**
- `wofi` → dmenu-style popups from **waybar scripts**: audio-router, bluetooth-menu,
  fingerprint-manager, update-manager (all `wofi --dmenu`, styled from `~/.config/wofi/*.css`).
  **Keep** (unless you rewrite those scripts to rofi).
- Under Omarchy both are superseded by the Quickshell bar — but on the current /
  plain-Arch setup, deleting either breaks live functionality. **Recommend keep both for now.**

**Terminals — RESOLVED 2026-09-01: keep kitty, bring it into the repo + central theming.**
- Correction to earlier note: there was NOT "no kitty config". A working config existed
  but was **unmanaged** (live `~/.config/kitty/kitty.conf` + `current-theme.conf`, never in
  the repo) and **pinned to a static Catppuccin-Mocha**, disconnected from the central
  frappe/latte/macchiato theme switcher.
- Real live settings preserved: `SauceCodePro Nerd Font` 12, opacity 0.9, blur 10,
  `hide_window_decorations yes`.
- **DONE (additive, in repo):** new stow package `kitty/.config/kitty/kitty.conf` that
  preserves those settings and swaps static Mocha for `include ~/.config/themes/current.kitty`;
  4 new `catppuccin/*.kitty` palettes (faithful translations of the `.ghostty` ones);
  theme switcher now swings `current.kitty` + sends kitty `SIGUSR1` to live-reload; `.gitignore`
  updated for `current.kitty`. `$terminal = kitty` stays as-is.
- **GATED (touches live files):** deploying the package via `stow kitty` replaces the two
  unmanaged live files (`~/.config/kitty/kitty.conf`, `current-theme.conf`). Content is
  captured in the repo, but per the guardrail this live swap waits for you to run it.
- `alacritty` has no root config; only referenced by mac/personal submodules + 2 scripts →
  still a candidate to drop with the mac world (category A).

**Duplicated `bin/` scripts — they're dead X11-era wrappers, not live dupes.**
- 39 scripts total. The "kernel ×7 / update ×3 / maintenance ×2" families are mostly
  thin wrappers that call `bspc rule` (**bspwm**) + `xfce4-terminal --title=… -e …` to
  pop the real script in a floating window. On Hyprland/Wayland `bspc` does nothing.
- Dead wrappers: `kernel_manage`, `kernel-installer`, `kernel-list`, `kernel-switcher`,
  `updater`, `system-maintain` (all bspc/xfce4).
- Real impls (usable standalone, keep or port): `k_manage.sh`, `kernel-installer-bin`,
  `update`, `system_maintain.sh`. `kernel.sh` is just a `uname -r` echo.
- Rec: **delete the bspwm wrappers**, keep the impls; audit the other ~27 bin scripts
  separately (they include live ones: gpu-mode-check, brightness/volume_notify, wifi, etc.).

**RESOLVED 2026-09-01 — approved for deletion (GATED on backup verify).**
Content-verified set of bspc/xfce4 duplicated wrappers to delete (each just floats a
real impl in an xfce4-terminal under a `bspc rule`):
- `kernel_manage`  → wraps `k_manage.sh`
- `kernel-installer` → wraps `kernel-installer-bin`
- `kernel-list`    → wraps `k_manage.sh`
- `updater`        → wraps `update`
- `system-maintain` → wraps `system_maintain.sh`
Keep the real impls: `k_manage.sh`, `kernel-installer-bin`, `update`, `system_maintain.sh`.
Correction: `kernel-switcher` is **NOT** a bspwm wrapper (standalone LegionOS switcher,
mostly commented-out) — excluded from this set; decide separately.
Also-bspc (NOT in this approved set, separate later audit): `bsp`, `alikred`, `ccm`,
`neofetch-legion`, `sxh`.

**DONE 2026-09-02 — commit `1012182` on `omarchy-quattro`** (deleted ahead of the
backup by explicit user go; safe because git-tracked = reversible via `git restore`).
Deleted the 5 wrappers; also repointed `system_maintain.sh` option 8 (`kernel-list`
→ `k_manage.sh` direct, since it already runs in a terminal).

**NEW finding surfaced during deletion — `bin/.local/bin/settings` (decide separately).**
A Python **rofi** "Settings Manager" menu. Not bound to anything live (no hypr/waybar
keybind launches it). Most entries point at dead X11 tools: `bsp` (bspwm), `sxh` (sxhkd),
`ccm`, `nitrogen` (X11 wallpaper), `neofetch-legion`, `alikred`; plus it referenced the 3
now-deleted wrappers (`updater`, `kernel_manage`, `system-maintain`) → those 3 entries are
now dangling. It's a half-dead X11-era artifact. Options: (a) **delete** it (likely — it's
X11-era and unbound); (b) rebuild for Wayland (repoint entries to real impls launched via
`kitty -e …`, drop bsp/sxh/ccm/nitrogen); (c) leave as-is. **Pending user decision.**

---

## H. Omarchy 4 architecture + adoption preferences (2026-09-03)

Researched from `omacom/omarchy@quattro` (package lists, `bin/omarchy-*` suite, manual,
`shell/plugins/`). Written up as `migration/omarchy-feature-migration-map.html` (feature
audit, ordered easiest→hardest to graft onto our existing Arch+Hyprland).

**Key finding — Omarchy 4 "Quattro" is `omarchy-shell`.** Quattro replaced the separate
waybar / walker / mako / swayosd / hyprlock / polkit-agent stack with ONE long-running
Quickshell (QML) process. Everything on screen is a plugin: `omarchy.bar`, `.menu`,
`.lock`, `.osd`, `.polkit`, `.notifications`, `.clipboard`, `.emojis`, `.panels`,
`.reminders`, `.background`, `.services`, `.agents`. First-party plugins live in
`$OMARCHY_PATH/shell/plugins/`; user plugins in `~/.config/omarchy/plugins/<id>/`.
Managed with `omarchy plugin list|enable|disable`, `omarchy-shell shell rescanPlugins`
(or menu → Setup → Plugins). base.packages confirms it: `quickshell` present; NO mako,
swaync, waybar, walker, swayosd, hyprlock.

**User preferences (2026-09-03):**
- **Likes → wants:** the top bar + the plugin system. These are the SAME thing — the bar
  is the `omarchy.bar` plugin, the plugin system IS `omarchy-shell`. Adopting them = adopting
  `omarchy-shell` as the desktop shell. This is the heaviest, most Omarchy-coupled swap in the
  whole migration (assumes `$OMARCHY_PATH`, `~/.config/omarchy/`, calls the `omarchy-*` bin
  suite). **→ VM-prototype first before any real-laptop consideration.**
- **Keeps → own notifications (swaync).** Cleanly satisfiable even under the shell:
  `omarchy plugin disable omarchy.notifications` and run swaync (only one daemon can own the
  freedesktop Notifications DBus name). Same lever for `omarchy.lock` (keep hyprlock),
  `omarchy.osd`, launcher — enable the plugins we want, disable where we keep our own tool.
- Corrects the map's first cut, which wrongly listed "Quickshell bar" and "Walker launcher"
  as two separate Tier-4 swaps; in Quattro they're one shell. Map updated same day.

**DECISION (2026-09-03): lean (b) — do NOT install/vendor `omarchy-shell`.** Go with a
standalone Quickshell bar instead, and harvest desirable Omarchy plugins as forks via a compat
shim. Rationale, the fork, and the shim feasibility → **section K**.

---

## I. Launcher / menu system → Vicinae (DECIDED direction, 2026-09-03)

**Decision (planning-level; NOT yet installed — VM first, per guardrails):** adopt
**Vicinae** as the preferred launcher / menu system. Vicinae = native C++/Qt Raycast-compatible
launcher for Linux; runs React/TS extensions via a Node host rendered to Qt; has its OWN store
(`vicinae.com/extensions`, PR monorepo `vicinaehq/extensions`) + a native superset API
(`@vicinae/api`) + Raycast-store compatibility (`raycast/compat.json` tracker).

**What it replaces / absorbs:**
- Primary launcher: replaces rofi's drun role — `$menu = rofi -show drun` (hyprland.conf:60)
  → `bind = SUPER, SPACE, exec, vicinae toggle`. (rofi calc/emoji binds can move to Vicinae too.)
- Over time can absorb the **wofi popup menus** (audio-router, bluetooth-menu, fingerprint-manager,
  update-manager, theme switcher) as Vicinae commands/extensions → this is the concrete path to
  **sunsetting wofi** (supersedes the earlier "sunset later once Quickshell replaces them" note —
  Vicinae is the more likely vehicle than a Quickshell rewrite).

**Interaction with the `omarchy-shell` decision (section H):** if we also adopt `omarchy-shell`
for the bar, its launcher/menu plugin OVERLAPS Vicinae. Resolve then, not now: likely
`omarchy plugin disable` the shell's launcher and keep Vicinae as the launcher, while
`omarchy.bar` stays for the bar. Two launchers must not both bind SUPER+SPACE.

**Prerequisite refactor (do regardless):** extract a headless `bin/.local/bin/theme-set <flavor>`
out of `wofi-theme-switcher.sh` so wofi (now), Vicinae, and any future bar all call one backend.
Backend/frontend split — same principle as the launcher-ecosystem discussion.

**First native extension — SKETCH created:** `vicinae-extensions/hyprland/`
(`@vicinae/api`, TypeScript). Two commands: **Switch Window** (`hyprctl clients -j` → focus/close)
and **Switch Theme** (calls the headless `theme-set`). Not installed; a liftable prototype for the VM.

**Gating:** install + bind-swap happen in the VM first; on the real laptop only after the verified
backup + deliberate cutover. rofi/wofi stay live and untouched until Vicinae is proven.

**Open decision:** sequencing — is Vicinae an early VM experiment (it's low-risk, self-contained,
doesn't require the heavy `omarchy-shell` swap), or batched with the shell prototype? Leaning:
do Vicinae EARLY and independently; it's the cheapest high-value win and de-risks the launcher
question before the big shell decision.

---

## J. File-manager stack → Nautilus (GUI) + yazi (TUI) — PLANNED, not implemented (2026-09-03)

Mirrors Omarchy Quattro's choice: **Nautilus** as the GUI file manager (Omarchy default,
`Super+Shift+F`; + `sushi` preview, `gvfs-*`, `udiskie`) and **yazi** as the TUI daily driver
(Rust, fast, kitty-graphics image previews). Omarchy kept Nautilus default and blessed yazi as
the alternative — same split fits the "TUI daily, nice GUI sometimes" preference.

- **yazi follows the central switcher** (TOML theme per flavor) — same treatment as kitty.
  GUI Nautilus is GTK → effectively flavor-static (won't track the switcher live).
- **Configs are staged, NOT deployed:** `migration/planned-yazi/` holds 4 schema-verified
  `catppuccin/*.yazi` themes + a `yazi.toml` (openers wired to nvim/mpv/imv/xdg-open/nautilus)
  + a README with the exact 5 switcher edits, install deps, and deploy steps.
- **Integration mechanism:** yazi has no `include`, so `~/.config/yazi/theme.toml` becomes a
  symlink → `~/.config/themes/current.yazi` (absolute target; created non-destructively by the
  switcher's init). Switcher swaps `current.yazi` per flavor like the other apps.

**Process note (2026-09-03):** first pass I *implemented* this (edited the live-symlinked
`wofi-theme-switcher.sh` + created `themes/*.yazi` and a `yazi/` package). User stopped it —
we're planning, not implementing. Reverted the switcher (`git checkout`), moved the work into
`migration/planned-yazi/`. Nothing deployed; live dotfiles packages untouched.

**Gating:** deploy (stow + switcher edits + `yay -S`) only after explicit go-ahead — ideally
in the VM first, or as an approved additive change on the real setup like the kitty item was.

---

## K. Bar / desktop shell → standalone Quickshell, NOT omarchy-shell (leaning, 2026-09-03)

Refines section H into a fork, after confirming how omarchy-shell is packaged + coupled
(`docs/omarchy-shell.md`, `shell/README.md`, DeepWiki plugin-architecture):

- **omarchy-shell is just a Quickshell config dir**, launched by Hyprland as
  `quickshell -p $OMARCHY_PATH/shell` (wrapper `omarchy-launch-shell`; the `omarchy-shell`
  command is only an IPC forwarder, NOT the launcher). So it *can* run on plain Arch — but it's
  tightly coupled: assumes `$OMARCHY_PATH`, `~/.config/omarchy/` (plugins + `shell.json`), and
  the `omarchy-*` bin suite for nearly every bar action + IPC. No standalone package exists.
- **The marketplace (omarchyplugins.com) is omarchy-shell-specific.** Anyone can browse it, but
  plugins only *run* inside omarchy-shell — they need its PluginRegistry, `barWidgetRegistry`
  (`putBarWidget`/ModuleSlot), the `shell` IPC verbs (`summon/toggle/call/rescanPlugins/
  listPlugins`), `~/.config/omarchy/plugins/`, and `shell.json`. Plugins run **unsandboxed**.

**THE FORK (decision lean):**
- **(a) Vendor omarchy-shell** → the bar + marketplace, but pull in `$OMARCHY_PATH` + the
  `omarchy-*` suite = effectively running Omarchy's shell without the installer. **Rejected as
  default** — too coupled, against the "adaptable modules, no Omarchy install" stance.
- **(b) Standalone Quickshell bar** ← **LEAN.** Our own / a community Quickshell config (e.g.
  `bjarneo/quickshell`) on plain Hyprland. Quickshell aesthetic + QML skill, zero Omarchy
  coupling. Cost: no transparent access to the omarchy marketplace — hence the shim below.

**Forking Omarchy plugins to run OUTSIDE Omarchy — the compat-shim idea (feasible, medium effort):**
A plugin = `manifest.json` (schemaVersion, id, kinds, entryPoints) + QML entry files. What
omarchy-shell provides that plain Quickshell doesn't, and a shim must reproduce:
1. a **PluginRegistry-lite** — scan a plugins dir, read `manifest.json`, instantiate the
   entryPoint QML by `kind`, hot-reload on change;
2. **bar-widget slot injection** — a bar with ModuleSlots that mount `bar-widget` entryPoints
   (the `putBarWidget` equivalent);
3. a **summon/toggle** path for `panel`/`overlay`/`menu` kinds (Quickshell has its own
   `IpcHandler` + `LazyLoader` to build this on);
4. **host singletons** the plugin QML imports — above all a `Theme`/`Config` singleton, which we
   map to our Catppuccin `current.*`. (Exact import lines need a per-plugin source audit; the
   READMEs don't list them.)
Plain Quickshell already gives the runtime, QML modules, layer-shell, `Process`/exec, and its
own IPC — so the shim is a management layer, not a rewrite.

Then each marketplace plugin becomes **forkable**: fork the repo, repoint its imports to the
shim namespace. "Run a script → show output" bar-widgets (cpu-ram, netrate, battery, vpn,
agents) port nearly verbatim; overlay/menu kinds need more shim surface.

**Verdict:** harvest the good widgets as forks; don't try to run the whole marketplace
transparently. No upstream compat guarantee (Omarchy can change its plugin API); we own the
shim; plugins are unsandboxed. Scope as a **VM experiment, Week 3 stretch**, AFTER a standalone
bar exists.

**Sub-decision (2026-09-03): lean FROM SCRATCH.** The deciding criterion — "a community config
that aims to *free* Omarchy plugins AND has super-easy config" — is NOT met: no community
Quickshell project targets running Omarchy marketplace plugins outside Omarchy (that goal is ours
alone). Several DO nail easy config + theming, so we don't start from zero — **crib patterns**
from them rather than fork wholesale:
- `end-4/dots-hyprland` — the FileView + JsonAdapter → QML `shell.json` binding (clean, reactive
  config; the pattern to copy for our easy-config goal).
- `doannc2212/quickshell-config` — modular "each piece works on its own, take what you like"
  layout + a 206-theme switcher.
- `ekremx25/quickshell` — in-app Settings dashboard (edit config without touching files).
- `x86kernel/HyprQuick` — JSON + i18n config, HyprPanel-style popups.
Build our own bar on Quickshell's declarative framework, borrow those config/theming patterns,
and add the plugin-loader/shim (above) that none of them have.

**North star (LATER — explicitly not now):** our bar goes beyond Omarchy's deliberately-basic style:
- **Richer theming** driven by our central Catppuccin switcher (a `Theme` singleton reading
  `current.*`), not a static palette.
- **TUI integrations** — launch/surface TUIs from the bar (btop, yazi, lazygit) via a
  scratchpad/drop-down terminal panel, and/or render TUI data natively through `Process`.
Aspirational; sequenced after a minimal bar + Vicinae + the file-manager stack land.

**Concrete bar design (2026-09-03): `migration/quickshell-bar-design.html`.** Quickshell 0.3.1 (Arch `extra`, `qs`, Qt6,
hot-reload). Architecture: `shell.qml` → `Scope` + `Variants{model:Quickshell.screens}` → one `PanelWindow` (layer-shell)
per monitor, bound via `Hyprland.monitorFor(modelData)`. **Live theming = the keystone:** a `Theme` singleton using
`FileView{watchChanges:true}` + `JsonAdapter` reading `~/.config/themes/current.json`; every widget binds `Theme.<role>` and
repaints on flavor flip. **One prereq to the switcher:** emit `current.json` as a REAL file via atomic `mv` (not a symlink —
Qt's watcher misses symlink relinks); ship `catppuccin/<flavor>.json` palettes. **Module map:** ~half are Quickshell built-in
service singletons (Hyprland workspaces/window/submap, UPower battery, Pipewire volume, Mpris media, SystemTray SNI host +
QsMenuAnchor menus, Networking, Bluetooth, SystemClock, idle-inhibit), ~half are thin `Process` wrappers over EXISTING repo
scripts (cpu-temp/cpu-usage/brightness-control/audio-device-cycle/checkUpdates/fingerprint/power-menu/swaync-client) — plus
the new GPU-mode widget on the `gpu-mode-set` backend. **Per-monitor workspaces (split-monitor-workspaces):** filter
`Hyprland.workspaces.values` by `monitor.name`, key on `id`, DISPLAY `name` (plugin offsets ids ≠ label). **Hard constraints:**
keep swaync → do NOT enable Quickshell's `NotificationServer` (widget just toggles swaync); one SNI host; use the repo
`quickshell` pkg not `-git` (breaks on Qt ABI bumps); single-process (one QML error kills the bar → isolate widgets, keep
waybar as instant fallback). **Crib (license-aware):** reimplement caelestia's FileView+JsonAdapter reactive `shell.json` +
`shell-tokens.json` split (GPL — don't copy); copy freely from **bjarneo/quickshell** (MIT, live-palette restyle) and
**ekremx25/quickshell** (MIT, in-app Settings dashboard + ModuleRegistry/ModuleCatalog split, ships Catppuccin). **Build
phases:** P0 hello-bar+switcher json → P1 Theme singleton + Hyprland core → P2 built-in service widgets → P3 script widgets +
**GPU-mode ships here** → P4 per-monitor polish + parity cutover (swap `exec-once`, keep waybar one release) → Later: settings
GUI + TUI integrations + plugin shim. Additive/reversible: `qs` runs beside/instead of waybar; nothing replaces waybar until parity.

**What we take from Omarchy (2026-09-03 research).** Omarchy is **MIT** (DHH), so theme data AND bar code are legally
reusable. **Reuse (portable data/patterns):** (1) the `colors.toml` **semantic-role palette format** (~22 keys:
accent/background/foreground/selection/muted/urgent + named) — adopt as our palette schema so the bar binds to ROLES and is
theme-agnostic + portable (off-Omarchy the switcher writes it from Catppuccin; on-Omarchy read
`~/.local/state/omarchy/current/theme/colors.toml` — note v4 moved it from `~/.config/omarchy/current/` in v3); (2) the **22
bundled theme palettes** (Catppuccin+latte, Tokyo Night, Gruvbox, Nord, Everforest, Kanagawa, Rose Pine, Matte Black, …) as a
future multi-theme library; (3) the **`.tpl` template** idea (palette→per-app configs with `mix`/`_strip`/`_rgb` helpers) if
we ever theme more apps from one palette; (4) **`bjarneo/quickshell`** (MIT) = the copyable reference of a STANDALONE bar
watching a live `colors.toml` and re-tinting on theme change — our theming mechanism, our source. **NOT reusable (omarchy-shell
runtime only):** `Bar.qml`/`BarModel.js` engine, the plugin manifest/registry, IPC (summon/toggle/call/reloadConfig), the
`Color`/`Style` singletons in `qs.Commons`, injected props — every `omarchy.*` widget is a plugin *to* the host.
**Omarchy's DEFAULT bar is minimal — ~7 slots:** L: menu, spacer, workspaces · C: media, clock · R: audio, power. (Opt-in
catalogue: tray, network, bluetooth, weather, mic, system-update, indicators, tailscale, agents, monitor/brightness.) Our
~20-module waybar is already far richer, so the Quickshell bar loses nothing vs Omarchy's default.
**Unified-theming answer:** the "module that themes the bar with the whole system" = the `Theme` singleton (§4 bar design)
reading the switcher's emitted palette — structurally identical to Omarchy (central palette + reactive singleton + file
watch), driven by our OWN `wofi-theme-switcher.sh` instead of `omarchy theme set`. Refinement: emit the palette in Omarchy's
semantic `colors.toml` shape (not raw Catppuccin names) for portability + future multi-theme.

**Bar shape decided (2026-09-03) — empty-by-default + plugins + multi-user.** Design record: `migration/planned-bar/`
(README + 4 palette JSONs). (1) **Palette schema:** `palettes/catppuccin-<flavor>.json` for all 4 flavors, exact user hex,
**16 semantic roles** (accent=mauve, accent_alt=lavender, bg/bg_alt/bg_deep, surface/surface_alt, overlay, fg, muted,
selection, urgent/error/success/warning/info) + **26 named** Catppuccin colors. Switcher P0 prereq: emit `current.json` as a
REAL file via atomic `mv` (copy of the active flavor palette). (2) **Empty bar → plugins:** core renders only a slot host;
what shows is what `shell.json` lists. Plugin = git repo with `manifest.json` (id/name/version/kind∈bar-widget|panel|service/
entry) + QML, installed to `~/.config/quickshell/plugins/<id>/`; a `PluginRegistry` singleton scans + injects host singletons
(Theme/Config/Hyprland) — mirrors Omarchy's injected Color/Style/shell so the SAME registry hosts **forked Omarchy widgets**
(§K shim). (3) **Minimal core = 2 built-ins:** `core.workspaces` (per-monitor) + `core.syscontrol`. Everything else (clock,
battery, audio, tray, gpu-mode…) is a plugin. (4) **Plugin CLI** `bin/.local/bin/bar` — `bar plugin add|list|enable|disable|
remove|update` (headless, Omarchy-style: clone → validate manifest → enable in shell.json → hot-reload). (5) **Multi-user (the
reason NOT Omarchy):** `core.syscontrol` popup = Lock/Logout/**Switch user**/Suspend/Hibernate/Reboot/Shutdown; switch-user via
`busctl … org.freedesktop.DisplayManager … SwitchToGreeter` (SDDM implements it — new login on a new VT, current session stays
alive) + `loginctl activate <session>` for existing users. Backend `session-control.sh` (⚠ verify SDDM seat path; fallback
hyprlock+chvt). Omarchy's default bar is ~7 slots and has NO multi-user; ours starts at 2 and adds it as core.

**DockShell created + basic bar RENDERS (2026-09-03).** The bar is now its own repo: **`github.com/juanjodarko/dockshell`**
(private, MIT), tracked as a **submodule** at `quickshell/.config/quickshell/` (dotfiles commit `959dcad`; `stow quickshell`
will symlink it to `~/.config/quickshell`). Scaffold: `shell.qml` (Scope + Variants(screens) → PanelWindow top bar,
per-monitor workspaces filtered by `monitor.name`, clock) + `Theme.qml` (Singleton, FileView-watches
`~/.config/themes/current.json`, Frappe fallback) + README + LICENSE. Installed `quickshell 0.3.1` (Arch extra).
**Test-run verified** (`quickshell -p … ` + grim): config loads with **zero QML errors**, the `Theme` singleton resolves, and
the bar renders — workspaces `1…10` + clock `Thu 03 Sep 22:50`, Frappe-themed. Only warning: `current.json` doesn't exist yet
(switcher not wired → fallback used). **Next:** wire the switcher to emit `current.json` (P0 prereq); then P1 core widgets
(syscontrol) + the PluginRegistry + `bar` CLI. waybar stays the daily driver until parity.

---

## L. Hyprland core / ecosystem / plugin audit (2026-09-03)

Full research (3 parallel agents) + live-config verification. Deliverable:
`migration/hyprland-ecosystem-audit.html`. Headline user question: *"do we still need the
split-screen plugin from hyprpm?"*

**Verified from the running session (not memory):**
- Hyprland **0.56.2** (built 2026-08-05) = **the latest stable** (0.57 ~20% done, unreleased). Nothing to chase.
- `hyprland.log` shows `[cfg] Using lua config found at …/hyprland.lua` → **hyprland.lua is authoritative;
  hyprland.conf is silently ignored.** Hyprland loads one *instead of* the other, chosen once at startup.
- `hyprctl plugins list` → **none**. `split-monitor-workspaces` loads as a **Lua `require()` package**
  (`[Lua] [split-monitor-workspaces] Initializing…`), **not hyprpm**. So we run **zero hyprpm plugins**.
- All hyprpm references (`permission = …hyprpm…`, `exec-once = hyprpm reload -n`) live **only in the dead
  hyprland.conf**.

**THE SPLIT-MONITOR VERDICT → KEEP AS-IS (decided):**
1. It isn't "from hyprpm" — it's a Lua package. The premise is already outdated in our favour.
2. Still *needed*: Hyprland 0.56 has **no native** independent per-monitor workspace sets (only static
   `workspace=N,monitor:` binding). The plugin does real work.
3. On the *right* version: repo moved `Duckonaut → zjeffer/split-monitor-workspaces` (788★, last commit
   2026-08-23, `release/0.56.x`); our `v0.56.0` matches 0.56.2. The C++ `.so` path is **deprecated and dropped
   at Hyprland 0.57.0** — we're already on the surviving Lua path. hy3-interop built in.
   Alternative `hyprsplit` (shezdy) = same job, no reason to switch (we're on the more popular, hy3-compatible one).
   Maintenance on a major bump = re-point one branch (one-line pull), not an ABI rebuild.

**Config hygiene findings (all PROPOSALS — nothing implemented):**
- **H1 — dead `hyprland.conf`**: silently ignored, holds the only hyprpm cruft + drift (`keep_focused=0` vs Lua `true`),
  and is on borrowed time (hyprlang deprecated 0.55, likely dropped ~0.57/0.58). → OPEN: keep as *marked* rollback /
  move to `migration/` / delete.
- **H2 — `pcall`-guard the plugin require** in hyprland.lua: a Lua error **aborts the whole file**, so a plugin break
  on a Hyprland bump would kill *all* keybinds, not just per-monitor workspaces. → resilience fix (needs go-ahead).
- **H3 — stale docs**: `CLAUDE.md` ("split-monitor via hyprpm", "locks after 30 min") + `README.md` hyprpm section
  describe a workflow we no longer run (actual idle: dim@10/lock@15/suspend@20). → doc fix.
- **H4 — `keep_focused` drift** (Lua `true` wins) → confirm intentionally.
- **H5 — `hyprland-guiutils` is a HARD DEP of the `hyprland` package** → pin "keep — never de-cruft" (also
  `hyprland-qt-support`, `hyprtoolkit`, `hyprwire` are transitive deps of the ecosystem's Qt→native rewrite).

**Ecosystem tools:** hyprpaper 0.8.4 / hyprlock 0.9.6 / hypridle 0.1.8 all current — keep. No first-party
notification/clipboard tool exists → **swaync + cliphist are correct, not gaps**. Worth adding (first-party, no ABI tax):
**hyprpicker** (color picker — easy yes) and **hyprsunset** (blue-light/temp for the laptop; needs own systemd-timer
schedule; could hook the Catppuccin switcher).

**Plugin philosophy (decided):** Lua-package plugins survive updates; hyprpm `.so` plugins are ABI-locked (rebuild via
`hyprpm update` every bump, can stall upgrades). **Skip cosmetic `.so`** (hyprbars/hyprtrails/borders-plus-plus/
hyprfocus/dynamic-cursors). **hy3 / hyprscrolling** only if changing the tiling paradigm (hyprscrolling = what Omarchy
uses). **hyprexpo** = the one defensible `.so` for dual-monitor, but **defer** (the future Quickshell bar may add its
own overview). Avoid abandoned `dawsers/hyprscroller` + `cpiber` fork.

**FLAG → DIAGNOSED (2026-09-03): benign log noise, no action required.** Live log repeats
`aquamarine [EGL] eglQueryDevicesEXT … EGL_BAD_ALLOC — Failed to allocate device list` (6×/boot, in pairs before
each `Creating CDRMRenderer on gpu /dev/dri/renderD128`). Root cause proven with a compiled EGL probe registering an
`EGL_KHR_debug` callback (like aquamarine does):
- Machine is hybrid Intel iGPU (HD 630) + NVIDIA dGPU; currently **supergfx `Integrated` → dGPU off, no `nvidia` kmod,
  only Intel on the PCI bus** (`drm: Found 1 GPUs`).
- `nvidia-utils` registers `/usr/share/glvnd/egl_vendor.d/10_nvidia.json`. glvnd's `libEGL` dispatches
  `eglQueryDevicesEXT` to **every** registered vendor; the NVIDIA ICD, with its GPU off, fails to allocate a device
  list → emits `EGL_BAD_ALLOC` **through the KHR_debug callback**. The aggregate call still returns `EGL_SUCCESS` with
  mesa's 2 devices, and aquamarine renders on Intel `renderD128`. **Zero functional impact.**
- Repro/fix confirmed: probe with default vendors → 1 callback msg (the exact error); with
  `__EGL_VENDOR_LIBRARY_FILENAMES=…/50_mesa.json` → 0 msgs. Probe lives in the session scratchpad (throwaway).

**Options (nothing implemented):** (1) **leave it** — cosmetic; recommended. (2) Silence *only in Integrated mode* by
exporting `__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json` in the Hyprland session env —
**must be conditional on `supergfxctl -g`**, since forcing mesa-only would hide the NVIDIA EGL device in Hybrid/dGPU
mode and break prime render-offload. Not a one-liner → propose, don't hard-code. `AQ_DRM_DEVICES` does NOT help (it
pins the DRM render node, not the EGL vendor enumeration).

---

## M. Hybrid-GPU switcher — design + driver blocker (2026-09-03)

User goal: dGPU **off by default** (battery), flip to **Hybrid** occasionally to play a game on the road, then back off.
"GUI switcher to enable/disable the NVIDIA GPU at ease." Full design: `migration/gpu-switcher-design.html`.

**Hardware (verified):** Razer Blade, Intel Kaby Lake-H (HD 630) + **NVIDIA GTX 1060 Mobile** (Pascal, PCI `10de:1c20`,
seen at `0000:01:00.0` in prior-boot `journalctl -k`). supergfxctl **5.2.7** (daemon active+enabled), modes
`[Integrated, Hybrid, NvidiaNoModeset]`. Boot cmdline has `nvidia-drm.modeset=1`.

**★ BLOCKER (verify before building anything):** only **`nvidia-open 610.57.04`** is installed (+ `nvidia-utils 610`,
`nvidia-prime`) — **no proprietary/legacy driver.** The open kernel modules need a **GSP (Turing+)**; **Pascal is
unsupported** (and NVIDIA 590 dropped Pascal from main packages). → the **GTX 1060 almost certainly will NOT initialize
in Hybrid** (no CUDA, no game offload). Unnoticed because default is Integrated (dGPU removed → `nvidia-smi` silent there
anyway). Confidence high (architectural); not watched succeed live (needs a Hybrid logout on the real laptop).
- **Fix:** swap to the last Pascal-capable proprietary branch, in AUR: **`nvidia-580xx-dkms` + `nvidia-580xx-utils` +
  `lib32-nvidia-580xx-utils`** (`580.178.04`). Frozen branch (watch on kernel bumps). **Verify:** Hybrid → logout/in →
  `nvidia-smi -L` lists the 1060. GATED: real-laptop graphics-stack change → explicit go-ahead / VM.

**Mode reality (source-verified):**
- **Integrated ⇄ Hybrid each requires a LOGOUT** (session restart, not reboot) on this non-mux Razer. No live path.
- **Pascal can't RTD3-idle** (Turing+ only; also needs Coffee-Lake+ host — Kaby Lake fails both) → Hybrid idles ~10–15 W.
  So "just stay in Hybrid" is NOT a battery option; a real Integrated off-switch is genuinely needed → validates the toggle
  AND the user's "keep it off" default.
- **NvidiaNoModeset** = red herring: powers the dGPU OFF (same as Integrated, no CUDA/games), only difference is live
  switching — and it isn't even offered because `modeset=1`. Ignore.
- **LLM/CUDA = Hybrid, no prime-run** (prime-run only sets GL/Vulkan offload; CUDA sees the card directly). **Games =
  Hybrid + `prime-run`.**

**Design (decided direction): one headless backend, two surfaces** — mirrors the theme-switcher shape.
- Reuse existing `bin/.local/bin/gpu-mode-check.sh` (mode→state) + `gpu-mode-monitor.sh` (D-Bus `NotifyGfx`) + its user
  service. Add a WRITE path only.
- **`gpu-mode-set <Integrated|Hybrid>`** headless script: validate → **confirm (logs you out)** → `supergfxctl -m` →
  `notify-send "log out to apply"`. Both UIs call it.
- **Surface A (NOW): waybar custom module** — icon from gpu-mode-check.sh, on-click → wofi/rofi/Vicinae menu → confirm →
  gpu-mode-set. Crib `theo-donacik/supergfxctl-waybar-module`.
- **Surface B (LATER): the planned Quickshell `io.github.juanjodarko.gpu-mode` widget** (roadmap "first QML plugin"),
  upgraded indicator→toggle; lands with the standalone bar.
- **Robust capability detection**: key off the supergfx **mode name** (gpu-mode-check.sh already does), NOT live PCI-device
  counting — this is Omarchy's bug (#5428: toggle vanishes in Integrated because the dGPU left the bus).
- UX for the road pattern: confirm dialog; post-login "NVIDIA is ON, revert when done" nudge with one-click back-to-Integrated;
  make "return to Integrated" as prominent as "enable".

**Watch (future):** supergfxctl is now **deprecated/archived**; Omarchy is evaluating **`cardwire`** (eBPF+LSM, block/unblock
dGPU **without logout/reboot**) as successor (Omarchy discussion #5982). Evaluate later if logout-free switching matters;
not today (new, would replace supergfx). No ready GUI applies (rog-control-center ASUS-only; optimus-manager-qt X11-only;
envycontrol CLI+reboot; switcheroo-control GNOME-only + broken on Wayland+NVIDIA).

**★ SECOND BLOCKER (found during runbook write-up):** `/etc/modprobe.d/system76-power.conf` — an **orphaned, unowned
leftover** from the uninstalled `system76-power` tool — does `alias nvidia off` + blacklists the nvidia modules, so nvidia
can **never load even with the right driver**, independent of Blocker A. Must be removed. (The other nvidia modprobe confs
are hand-made/unowned; `supergfxd.conf` is managed by supergfxd — leave it. `nvidia-pm.conf` sets Turing-only
`NVreg_DynamicPowerManagement=0x02` — a no-op on Pascal, optional to drop.)

**Exact driver-migration runbook written:** `migration/nvidia-580xx-migration.md` — gated, copy-pasteable: remove the
system76 leftover → `yay -S nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils` (accept removal of nvidia-open
/nvidia-utils/lib32) → `mkinitcpio -P` → verify `dkms status` → Hybrid (logout) → `nvidia-smi -L` lists the 1060 → back to
Integrated. Includes optional `linux-lts` safety net, rollback (`pacman -S nvidia-open …`), and maintenance/risk notes
(DKMS rebuild on every kernel bump; frozen legacy branch; iGPU-primary so a failed build never blocks boot). AUR metadata
confirmed: `nvidia-580xx-dkms 580.178.04` provides/conflicts `nvidia`+`NVIDIA-MODULE` (cleanly replaces nvidia-open);
`linux-headers 7.2.2` matches the kernel so DKMS can build.

**Sequencing:** §0a remove system76 leftover + §0b driver swap (both gated, per the runbook) → 1 `gpu-mode-set` backend →
2 waybar module (now) → 3 Quickshell widget (later).

**OUTCOME — live migration run (2026-09-03):** Driver migration EXECUTED and **succeeded**: system76-power.conf moved to
`~/gpu-migration-backup/`, nvidia-pm.conf moved aside, `nvidia-open`→`nvidia-580xx-dkms/utils/lib32/settings 580.178.04`
installed, DKMS built for kernel 7.2.2, initramfs rebuilt. `NVRM: loading NVIDIA UNIX x86_64 Kernel Module 580.178.04`
confirms the right driver loads.

**BUT a THIRD blocker surfaced — power-manager conflict (the dGPU still won't init in Hybrid):** After `supergfxctl -m
Hybrid` + reboot, the dGPU is on the bus + nvidia modules load + `/dev/nvidia0` exists, yet `nvidia-smi` = "No devices
found" and no driver binds in sysfs. Kernel log: `nvidia-modeset: ERROR: Failed to open GPU` + `NVRM: Attempting to remove
device 0000:01:00.0 with non-zero usage count!`, then **`task tlp:1104` and a udev-worker blocked >245s in
`nv_pci_remove` (os_delay loop)** — a hung kernel task that wedged supergfxd (supergfxctl hangs). Link stuck at 2.5 GT/s
(Gen1). Root cause: **TLP (active) runtime-suspends/removes the NVIDIA GPU by default**; on this Optimus/Pascal box the
GPU fails to init and the removal hangs. Machine also has **auto-cpufreq** installed (overlaps TLP on CPU scaling) and had
the **system76-power** leftover — i.e. 3–4 overlapping power managers.

**FIX PLAN (next session, after reboot to safe Integrated):**
1. Exclude the dGPU from TLP runtime PM: `RUNTIME_PM_DENYLIST="01:00.0 01:00.1"` in `/etc/tlp.conf` (or a drop-in in
   `/etc/tlp.d/`), so TLP never touches the nvidia GPU (supergfxd owns its power).
2. Consolidate power tools — pick ONE CPU/power stack: TLP **or** auto-cpufreq, not both (they conflict); with supergfxd
   handling the GPU. Likely keep TLP (+ deny the GPU) and drop auto-cpufreq, or vice-versa.
3. Optional: drop `fbdev=1` from `/etc/modprobe.d/nvidia.conf` (nvidia-drm fbdev on a display-less Optimus dGPU throws
   `No compatible format`/`Cannot find any crtc`).
4. Then retry `supergfxctl -m Hybrid` + reboot → verify `nvidia-smi -L` lists the 1060.
Note: recovery from the wedged state needs a reboot (persisted mode already `Integrated`, so it returns to safe iGPU-only);
`reboot` may hang on the stuck task → force with `systemctl reboot -ff` / SysRq if needed. Backups of the moved confs are in
`~/gpu-migration-backup/`.

**RESOLVED — dGPU working in Hybrid (2026-09-03).** `nvidia-smi -L` lists `NVIDIA GeForce GTX 1060` (driver 580.178.04,
6 GB), `Kernel driver in use: nvidia`, no errors/hangs. The real fix sequence (four blockers, not the two we started with):
1. **Driver (Blocker A):** `nvidia-open`→`nvidia-580xx` (Pascal needs the legacy proprietary branch). ✓
2. **Rogue leftover (Blocker B):** moved `/etc/modprobe.d/system76-power.conf` (`alias nvidia off`) to `~/gpu-migration-backup/`. ✓
3. **Boot-race (Blocker C — the real killer):** `nvidia` was force-loaded from **initramfs `MODULES=()`** + `nvidia-drm.modeset=1`,
   so at every boot nvidia grabbed the dGPU and then supergfxd's Integrated removal hung in `nv_pci_remove` (wedging
   supergfxd, TLP, udev — TLP was a *victim* blocked on supergfxd's mutex, not the cause). This was masked before because
   nvidia-open silently failed on Pascal and never held the GPU. Fix: **removed nvidia from `/etc/mkinitcpio.conf` MODULES →
   `MODULES=()` + `mkinitcpio -P`** (nvidia now loads via udev only when the dGPU is present in Hybrid; nouveau stays
   blacklisted). ✓
4. **Switch never committed (Blocker D):** supergfxd's default **logout-based** apply timed out (`WaitLogout` → "Time (30s)
   for logout exceeded") because this setup always has 2 sessions (user + manager) so a clean logout never happens → it
   aborted, staying Integrated on every logout AND reboot. Fix: **set `"always_reboot": true` in `/etc/supergfxd.conf`** +
   `systemctl restart supergfxd` → `supergfxctl -m Hybrid` now commits `"mode":"Hybrid"` to config and applies on reboot. ✓
Plus TLP hygiene: `/etc/tlp.d/10-nvidia-denylist.conf` → `RUNTIME_PM_DENYLIST="01:00.0 01:00.1"`.

**Daily workflow now:** default **Integrated** (`sudo supergfxctl -m Integrated` + reboot) for battery; **Hybrid**
(`sudo supergfxctl -m Hybrid` + reboot) for a game (then `prime-run <game>`) or local LLMs (CUDA works directly). Switching
is **reboot-based** now (not logout). Backups of every moved/edited conf are in `~/gpu-migration-backup/`.

**Switcher sketches now deployable** — update their wording from "log out" → "reboot" (done in the sketch), and `gpu-mode-set`
should trigger/await a reboot rather than a logout. The whole GPU-switcher build order (dossier §M / plan) is now unblocked.

---

## N. Login screen / display manager (2026-09-03)

**Current (verified):** **SDDM** (running, enabled) with the prebuilt **`catppuccin-sddm-theme-{mocha,latte,frappe,macchiato}`**
packages (~14 accents each); active = `catppuccin-macchiato-mauve`. Themed by `/usr/local/bin/update-sddm-theme <flavor>
<accent>` (pkexec from the switcher) which just flips `Current=catppuccin-<flavor>-<accent>` in `/etc/sddm.conf.d/`. Key facts:
- **Greeter runs on X11** (`DisplayServer=x11`, `CompositorCommand=weston --shell=kiosk` present but unused) → pulls Xorg *just
  for login* on a Wayland system. Weight/optimization angle.
- **Multi-user + session-aware ALREADY satisfied:** SDDM shows a user picker + avatars (`EnableAvatars=true`), and
  **`ReuseSession=true`** already restores an existing same-user session ("when a session is already open"). So those wants are met.
- Pain points (the user's): config is **multi-file + confusing** (`default.conf` Current='' vs `theme.conf`
  Current=catppuccin-macchiato-mauve vs the script's `99-theme.conf`), and theming **picks a prebuilt theme**, not templated colors.

**Clarification — DM vs hyprlock (separate concerns):** the display manager = the login screen (multi-user pick, new logins);
**hyprlock** = in-session lock (re-enter YOUR session). Switching to ANOTHER user while your session is open goes via the DM
greeter — `SwitchToGreeter` (from the bar's `core.syscontrol`, dossier §M/§K) opens a new login on a fresh VT, your session
stays alive; `loginctl activate <session>` jumps to a running user's session. hyprlock is not a user-switcher.

**Options (2026 research):**
- **(A) Modernize SDDM — lowest risk (same DM).** Switch greeter to **Wayland** (`DisplayServer=wayland` + a compositor →
  drop the Xorg dep, lighter; note SDDM 0.21 Wayland greeter is still "experimental"). **Consolidate** the sddm.conf.d files
  into one. For real templating, adopt **`sddm-astronaut-theme`** (Keyitdev) — a single QML theme whose `theme.conf` exposes
  color keys the switcher can WRITE from `current.json` (true palette templating vs today's prebuilt-picking). Keeps
  ReuseSession + built-in multi-user. Con: still Qt-heavy.
- **(B) greetd + a GTK greeter — lighter, simpler, best templating. LEAN for the stated priorities.** greetd = minimal login
  daemon (Hyprland wiki: "works flawlessly, especially with ReGreet"). Greeter choices:
  - **ReGreet** (rharish101, GTK4/Rust, runs under `cage`) — config `/etc/greetd/regreet.toml` + **GTK CSS
    `/etc/greetd/regreet.css`**; multi-user + session selector + remember-last; well-maintained, Hyprland-blessed.
  - **nwg-hello** (nwg-piotr — *same author as the `nwg-displays` the user already uses*, GTK3, runs in a minimal sway/Hyprland
    instance) — config `/etc/nwg-hello/config.json` + **`/etc/nwg-hello/style.css`**; multi-monitor (gtk-layer-shell),
    multi-user, auto last user/session, background, i18n.
  - Both are **CSS-themeable → the switcher writes a Catppuccin CSS from `current.json`** (the semantic palette we built) =
    the Omarchy-style per-app templating the user most values, and much lighter (no Qt/KDE/Xorg). Con: DM swap = **login-path
    change → VM-first** per guardrails; greetd has no exact `ReuseSession` (same-user reuse) — mitigate with hyprlock for
    re-entry; cross-user switching still works via SwitchToGreeter + loginctl.
- **(C) Ly / greetd+tuigreet — lightest, but TUI/text-only.** Multi-user + session select, minimal config, but **no graphical
  Catppuccin templating** (colors only, no background/theme) → sacrifices the feature the user values most. Not recommended.

**Lean:** **(B) greetd + ReGreet** (or **nwg-hello** for nwg-ecosystem symmetry) — hits light + easy-config + palette-templated
theming + multi-user; VM-test first (login path). **(A) modernize SDDM** is the zero-risk fallback that keeps ReuseSession.
**Templating for whichever:** add a `login`/`greeter` target to the switcher (like kitty/yazi) that writes the greeter's
CSS (ReGreet/nwg-hello) or `theme.conf` colors (sddm-astronaut) from `current.json` — one palette, login screen included.
**OPEN DECISION:** (A) modernize SDDM vs (B) greetd+ReGreet/nwg-hello. Gated (login path) → VM-first regardless.

**greetd + ReGreet spec WRITTEN + verified (2026-09-03): `migration/planned-greeter/`.** Packages all in Arch `extra`
(`greetd 0.10.3`, `greetd-regreet`, `cage` — no AUR). Files: `greetd-config.toml` (`cage -s -- regreet`), `regreet.toml`
(background=blurred bg, GTK cursor/font, reboot/poweroff), `regreet.css` (Mocha reference, GTK4, styles user-selector/entry/
buttons), `bin/update-greeter-bg` (ffmpeg blur), `bin/update-greeter-theme` (jq palette→css), `polkit/49-greeter.rules`
(passwordless pkexec for wheel). **Blur = the ask:** greeter runs pre-session (user `greeter`) so it can't blur live like
hyprlock → pre-render a blurred copy of `~/.cache/current_wallpaper` to `/usr/share/backgrounds/greeter/current-blur.png`
(world-readable) on wallpaper change. **VERIFIED:** `bash -n` clean; ffmpeg `gblur=sigma=18,eq=brightness=-0.09:contrast=0.90:
saturation=1.08` produced a valid 1920×1080 PNG from the real wallpaper and visually matches the hyprlock look
(blur+darken+slight desat, ~ hyprlock blur_passes=2/blur_size=4/brightness=0.82/contrast=0.89); jq CSS-gen from
`catppuccin-mocha.json` produces valid GTK CSS. **User selector + password + session picker = ReGreet built-ins** (remembers
last). **Switcher hooks:** `change_wallpaper.sh` → `pkexec update-greeter-bg …`; `wofi-theme-switcher.sh` → `pkexec
update-greeter-theme …<flavor>.json` (beside the existing update-sddm-theme call). **Gaps/flags:** cage = single-output
(greeter on primary only); ReGreet CSS path/keys vary by version (verify against installed `greetd-regreet`); greetd has NO
SDDM `ReuseSession` (same-user reuse) → re-entering your own session is hyprlock's job, cross-user via SwitchToGreeter+
loginctl. **Rollback:** `systemctl disable greetd && enable sddm`; keep SDDM installed until proven; TTY (Ctrl+Alt+F2) fallback.
Still VM-first before the real machine.

**DEPLOYED + WORKING on the real machine (2026-09-03).** Installed `greetd 0.10.3` + `greetd-regreet 0.5.0` + `cage` (Arch
`extra`); `greeter` user created; configs/scripts/polkit rule deployed; blurred bg + frappe CSS seeded. Previewed live with
`cage -- regreet --demo` (blur + user selector + session picker + Catppuccin card all render correctly) BEFORE flipping the
DM. Switched `systemctl disable sddm && enable greetd`, rebooted → greeter shows. Session now `Service=greetd Type=wayland
Active=yes`, Hyprland + waybar up. **GOTCHA hit + resolved:** the greeter defaulted to `hyprland-uwsm.desktop`
(`Exec=uwsm start …`) but **`uwsm` is not installed** → that session exits instantly (first login "didn't start Hyprland").
Fix: pick the plain **`hyprland.desktop`** session (`Exec=/usr/bin/start-hyprland`); **ReGreet now remembers it**
(`/var/lib/regreet/state.toml`: `juanjo = "Hyprland"`) so it defaults correctly henceforth. SDDM **disabled but still
installed** + `~/rollback-to-sddm.sh` present (instant rollback). CSS `:invalid` pseudo-class warning fixed in the generator
(GTK4 has no `:invalid`). **Still TODO:** (1) wire the switcher/wallpaper hooks so flavor-flip retints the greeter CSS +
wallpaper-change regenerates the blur (currently seeded manually as frappe); (2) deploy palette files to the theme tree for the
hook; (3) optional: remove/hide the broken uwsm session, or install+configure uwsm. Source of truth for the greeter configs:
`migration/planned-greeter/` (deployed to `/etc/greetd/` + `/usr/local/bin/`).

---

## Submodule removal procedure (for `awesome/`, `mac_personal/`)
```
git submodule deinit -f <path>
git rm -f <path>                      # removes from .gitmodules + index
rm -rf .git/modules/<path>
```

## Suggested deletion order (after backup verifies, on `cleanup` branch)
1. E (backup/example files) — zero risk
2. D (fix dangling polybar submodule)
3. A + B (macOS + X11/awesome worlds) — self-contained
4. C (dead/empty)
5. G-terminals decision (kitty→ghostty) + G-bin dead wrappers
6. F (vendored plugin .git) — last, most care
   (leave G-launchers alone: both rofi & wofi are live)
```
