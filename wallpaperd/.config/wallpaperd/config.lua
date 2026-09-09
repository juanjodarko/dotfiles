-- wallpaperd configuration.
-- Returns a table; edit and re-run `wallpaperd next` (or just relogin).
-- Paths may start with ~ or $HOME.

return {
  -- Where your wallpapers live. Default is inside this module so the package is
  -- self-contained and portable — symlink your real collection here, e.g.:
  --     ln -s ~/wallpapers ~/.config/wallpaperd/wallpapers
  wallpapers_dir = "~/.config/wallpaperd/wallpapers",

  -- Wallpaper backend. Only "hyprpaper" is implemented for now.
  backend = "hyprpaper",

  -- Assign a different random wallpaper per monitor (true) or the same one to
  -- all monitors (false).
  per_monitor = true,

  -- Keep this symlink pointing at the current (primary) wallpaper — hyprlock
  -- and other tools read it.
  current_symlink = "~/.cache/current_wallpaper",

  -- Update the greetd/ReGreet login background to match the current wallpaper
  -- (via /usr/local/bin/update-greeter-bg). Best-effort: skipped if that helper
  -- is absent. Needs the passwordless polkit rule to be silent (see README).
  update_greeter = true,

  -- (reserved for the ultrawide stitching feature, added later) monitors at or
  -- above this width will get a 2-wallpaper stitched image instead of one.
  ultrawide_min_width = 3440,
}
