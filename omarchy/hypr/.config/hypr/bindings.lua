-- Personal keybindings: ALT-based window management, for parity with the
-- aerospace setup on macOS.
--
-- This file is loaded by ~/.config/hypr/hyprland.lua AFTER Omarchy's defaults,
-- so everything here is an override layer. Omarchy's own files are never
-- touched, and removing this file restores stock behaviour completely.
--
-- Omarchy keeps SUPER for its own bindings and only claims a handful of ALT
-- combos. Those are unbound below; every other SUPER binding still works, so
-- the Omarchy menu, capture tools, and toggles remain available as documented.
--
-- See the current bindings with: omarchy menu keybindings --print

--------------------------------------------------------------------------------
-- UNBIND COLLIDING OMARCHY DEFAULTS
--------------------------------------------------------------------------------
-- ALT + TAB / ALT + SHIFT + TAB are Omarchy's window cycling (each is bound
-- twice upstream: cycle_next plus bring_to_top). Reclaimed below for workspace
-- back-and-forth, matching aerospace's alt-tab.
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")

--------------------------------------------------------------------------------
-- APPLICATIONS
--------------------------------------------------------------------------------
o.bind("ALT + RETURN", "Terminal", "omarchy-launch-terminal")
o.bind("ALT + Q", "Close window", hl.dsp.window.close())
o.bind("ALT + E", "File manager", "omarchy-launch-nautilus")
o.bind("ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")
o.bind("ALT + C", "Calculator", "omacalc")
o.bind("ALT + SEMICOLON", "Emojis", "omarchy-shell shell toggle omarchy.emojis")

--------------------------------------------------------------------------------
-- WINDOW STATE
--------------------------------------------------------------------------------
o.bind("ALT + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("ALT + F", "Maximize", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("ALT + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("ALT + P", "Pseudo window", hl.dsp.window.pseudo())

-- NOTE: the Arch config bound ALT + J to "toggle split" alongside ALT + j for
-- "focus down". Hyprland treats those as the same key, so only one could ever
-- win. Focus wins here (it is the vim-navigation half of the muscle memory);
-- toggle split stays on Omarchy's SUPER + J.

--------------------------------------------------------------------------------
-- FOCUS AND MOVEMENT (vim keys)
--------------------------------------------------------------------------------
o.bind("ALT + h", "Focus left", hl.dsp.focus({ direction = "l" }))
o.bind("ALT + j", "Focus down", hl.dsp.focus({ direction = "d" }))
o.bind("ALT + k", "Focus up", hl.dsp.focus({ direction = "u" }))
o.bind("ALT + l", "Focus right", hl.dsp.focus({ direction = "r" }))

o.bind("ALT + SHIFT + h", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("ALT + SHIFT + j", "Move window down", hl.dsp.window.move({ direction = "d" }))
o.bind("ALT + SHIFT + k", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("ALT + SHIFT + l", "Move window right", hl.dsp.window.move({ direction = "r" }))

--------------------------------------------------------------------------------
-- MONITORS
--------------------------------------------------------------------------------
-- Directional rather than by output name, so the same config works on the
-- laptop alone or with any external display attached.
o.bind("ALT + CTRL + h", "Focus monitor left", hl.dsp.focus({ monitor = "l" }))
o.bind("ALT + CTRL + j", "Focus monitor down", hl.dsp.focus({ monitor = "d" }))
o.bind("ALT + CTRL + k", "Focus monitor up", hl.dsp.focus({ monitor = "u" }))
o.bind("ALT + CTRL + l", "Focus monitor right", hl.dsp.focus({ monitor = "r" }))

o.bind("ALT + CTRL + SHIFT + h", "Move window to monitor left", hl.dsp.window.move({ monitor = "l" }))
o.bind("ALT + CTRL + SHIFT + j", "Move window to monitor down", hl.dsp.window.move({ monitor = "d" }))
o.bind("ALT + CTRL + SHIFT + k", "Move window to monitor up", hl.dsp.window.move({ monitor = "u" }))
o.bind("ALT + CTRL + SHIFT + l", "Move window to monitor right", hl.dsp.window.move({ monitor = "r" }))

o.bind("ALT + COMMA", "Focus previous monitor", hl.dsp.focus({ monitor = "-1" }))
o.bind("ALT + PERIOD", "Focus next monitor", hl.dsp.focus({ monitor = "+1" }))

--------------------------------------------------------------------------------
-- WORKSPACES
--------------------------------------------------------------------------------
-- Keycodes (code:10 = "1" ... code:19 = "0") instead of literal digits, so the
-- bindings survive a keyboard layout change. Same approach Omarchy uses.
--
-- NOTE: the Arch setup drove these through the split-monitor-workspaces
-- Hyprland plugin, giving each monitor its own 1-10 range. That plugin is not
-- part of Omarchy and pulling it in would mean managing a compiled Hyprland
-- plugin across updates, so these are plain global workspaces.
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("ALT + " .. key, "Switch to workspace " .. workspace,
    hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("ALT + SHIFT + " .. key, "Move window to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace) }))
end

o.bind("ALT + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))

o.bind("ALT + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("ALT + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Omarchy's special workspace is named "scratchpad"; reusing that name keeps
-- these interoperable with the stock SUPER + S binding.
o.bind("ALT + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("ALT + SHIFT + S", "Move window to scratchpad",
  hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

--------------------------------------------------------------------------------
-- MOUSE
--------------------------------------------------------------------------------
o.bind("ALT + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("ALT + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------------
-- SYSTEM
--------------------------------------------------------------------------------
-- Mapped onto Omarchy's native commands rather than the Arch stack
-- (swaync / hyprpaper / wpctl scripts), which Quattro no longer ships.
o.bind("ALT + N", "Notification history", "omarchy-shell notifications showHistory")
o.bind("ALT + SHIFT + W", "Next background", "omarchy-theme-bg-next")
o.bind("ALT + F8", "Cycle audio output", "omarchy-audio-output-switch")
o.bind("ALT + SHIFT + M", "Hardware menu", "omarchy-menu toggle hardware")
o.bind("ALT + CTRL + M", "Log out", "omarchy-system-logout")

--------------------------------------------------------------------------------
-- RESIZE SUBMAP (ALT + R to enter, ESC or RETURN to leave)
--------------------------------------------------------------------------------
o.bind("ALT + R", "Resize mode", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind("h", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
  hl.bind("l", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

  hl.bind("SHIFT + h", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
  hl.bind("SHIFT + l", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true })
  hl.bind("SHIFT + k", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })
  hl.bind("SHIFT + j", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true })

  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("return", hl.dsp.submap("reset"))
end)
