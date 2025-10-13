# Centralized Theme System

> One-click theme switching across all applications using Catppuccin flavors

## Overview

The centralized theme system provides instant theme switching for all applications without needing to restart them (except Ghostty). This is achieved through symlinked configuration files and inter-process communication.

## Features

- **4 Catppuccin Flavors**: Mocha, Latte, Frappé, Macchiato
- **Instant Updates**: No application restarts needed (Neovim, Tmux, Waybar, Wofi, Rofi)
- **Single Source of Truth**: All theme files in `~/dotfiles/themes/`
- **Style Guide Compliant**: Follows [official Catppuccin style guide](https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md)
- **Menu Integration**: Access via `Alt+Space` → Settings → Theme

## Supported Applications

| Application | Format                  | Reload Method  | Restart Required |
| ----------- | ----------------------- | -------------- | ---------------- |
| Neovim      | `.lua` flavor detection | Server socket  | ❌ No            |
| Tmux        | `.tmux` config          | `source-file`  | ❌ No            |
| Waybar      | `.css`                  | SIGUSR2 signal | ❌ No            |
| Wofi        | `.css` import           | Next launch    | ❌ No            |
| Rofi        | `.rasi` theme           | Next launch    | ❌ No            |
| Ghostty     | `.ghostty` palette      | Config rewrite | ✅ New window    |

## Architecture

```
themes/
├── catppuccin/
│   ├── mocha.css          # Waybar/Wofi colors
│   ├── mocha.rasi         # Rofi theme
│   ├── mocha.ghostty      # Terminal palette (16 ANSI + base colors)
│   ├── mocha.tmux         # Tmux flavor setting
│   ├── latte.{css,rasi,ghostty,tmux}
│   ├── frappe.{css,rasi,ghostty,tmux}
│   └── macchiato.{css,rasi,ghostty,tmux}
├── current.css            # Symlink → catppuccin/{flavor}.css
├── current.rasi           # Symlink → catppuccin/{flavor}.rasi
├── current.ghostty        # Symlink → catppuccin/{flavor}.ghostty
├── current.tmux           # Symlink → catppuccin/{flavor}.tmux
└── current_flavor.txt     # Plain text: "mocha", "latte", "frappe", or "macchiato"
```

## Auto-Generated Files

The `current.*` symlinks and `current_flavor.txt` file are **automatically generated** and should not be manually edited or committed to git:

- **Created automatically** on first theme switch
- **Default theme:** Mocha (dark)
- **Git ignored** (listed in `.gitignore`)
- **Self-initializing** via theme switcher script

**What happens on first run:**

When the theme switcher runs for the first time, it checks if these files exist. If they don't, it creates them with Mocha defaults:

```bash
# Automatically created by wofi-theme-switcher.sh
~/dotfiles/themes/current.css → catppuccin/mocha.css
~/dotfiles/themes/current.rasi → catppuccin/mocha.rasi
~/dotfiles/themes/current.ghostty → catppuccin/mocha.ghostty
~/dotfiles/themes/current.tmux → catppuccin/mocha.tmux
~/dotfiles/themes/current_flavor.txt → contains "mocha"
```

**Manual initialization (if needed):**

If you need to manually initialize the theme system (e.g., after cloning the repo), run:

```bash
cd ~/dotfiles/themes
ln -sf catppuccin/mocha.css current.css
ln -sf catppuccin/mocha.rasi current.rasi
ln -sf catppuccin/mocha.ghostty current.ghostty
ln -sf catppuccin/mocha.tmux current.tmux
echo "mocha" > current_flavor.txt
```

Or simply open the theme switcher menu once (`Alt+Space` → Settings → Theme) and it will initialize automatically.

## Theme Files Explained

### CSS Files (Waybar/Wofi)

Contains `@define-color` declarations for all Catppuccin palette colors:

```css
/* catppuccin/mocha.css */
@define-color base   #1e1e2e;
@define-color text   #cdd6f4;
@define-color mauve  #cba6f7;
/* ... all other colors */
```

Applications import via:

```css
@import "/home/juanjo/.config/themes/current.css";
```

### RASI Files (Rofi)

Complete Rofi theme with colors and styling:

```rasi
/* catppuccin/mocha.rasi */
* {
    bg: #1e1e2e;
    fg: #cdd6f4;
    /* ... colors + styling rules */
}
window { /* ... */ }
inputbar { /* ... */ }
```

Applications import via:

```rasi
@theme "/home/juanjo/.config/themes/current.rasi"
```

### Ghostty Files (Terminal)

ANSI palette (0-15) + base colors:

```
# catppuccin/mocha.ghostty
palette = 0=#45475a  # Black
palette = 1=#f38ba8  # Red
# ... 0-15
background = 1e1e2e
foreground = cdd6f4
cursor-color = f5e0dc
selection-background = f5e0dc
```

### Tmux Files

Simple flavor setting for catppuccin-tmux plugin:

```bash
# catppuccin/mocha.tmux
set -g @catppuccin_flavour 'mocha'
```

## Usage

### Interactive Theme Switching

1. Press `Alt+Space` (Rofi launcher)
2. Select "Settings" (cog icon)
3. Select "Theme"
4. Choose from 4 flavors with visual indicators:
   ```
   ● Mocha (Dark)      - Currently active
   ○ Latte (Light)
   ○ Frappé (Dark)
   ○ Macchiato (Dark)
   ```

### Command Line

**View current theme:**

```bash
cat ~/.config/themes/current_flavor.txt
```

**Manual theme switch:**

```bash
cd ~/dotfiles/themes
ln -sf catppuccin/latte.css current.css
ln -sf catppuccin/latte.rasi current.rasi
ln -sf catppuccin/latte.ghostty current.ghostty
ln -sf catppuccin/latte.tmux current.tmux
echo "latte" > current_flavor.txt
```

**Reload applications:**

```bash
pkill -SIGUSR2 waybar                        # Waybar
tmux source ~/.config/tmux/tmux.conf         # Tmux
# Neovim reloads automatically via server sockets
# Ghostty: open new terminal window
```

## How It Works

### Theme Switcher Script

Located at: `waybar/.config/waybar/scripts/wofi-theme-switcher.sh`

**Flow:**

1. User selects theme from wofi menu
2. Script updates all 5 files (4 symlinks + flavor file):
   ```bash
   ln -sf "catppuccin/${flavor}.css" current.css
   ln -sf "catppuccin/${flavor}.rasi" current.rasi
   ln -sf "catppuccin/${flavor}.ghostty" current.ghostty
   ln -sf "catppuccin/${flavor}.tmux" current.tmux
   echo "$flavor" > current_flavor.txt
   ```
3. Ghostty config updated (between markers)
4. Reload commands sent:
   - Waybar: `pkill -SIGUSR2 waybar`
   - Tmux: `tmux source-file ~/.config/tmux/tmux.conf`
   - Neovim: `nvim --server {socket} --remote-send ":colorscheme catppuccin-{flavor}<CR>"`

### Application Integration

**Neovim:**

- Reads `current_flavor.txt` at startup via `lua/user/theme.lua`
- Server mode enabled in `lua/user/settings.lua` for live updates
- Theme switcher sends colorscheme commands to all running instances

**Tmux:**

- Sources `~/.config/themes/current.tmux` before plugin loading
- Sets `@catppuccin_flavour` variable for catppuccin-tmux plugin

**Waybar:**

- Imports `~/.config/themes/current.css` in `theme.css`
- Reloads on SIGUSR2 signal

**Wofi:**

- All 7 menu styles import `~/.config/themes/current.css`
- Changes apply on next menu open

**Rofi:**

- Config loads `@theme "~/.config/themes/current.rasi"`
- Changes apply on next launch

**Ghostty:**

- Config has managed section between `# === THEME COLORS START/END ===` markers
- Theme switcher rewrites this section with new palette

## Adding New Themes

### 1. Create Theme Files

Create 4 files in `themes/catppuccin/`:

**`mytheme.css`:**

```css
@define-color base   #hexcode;
@define-color text   #hexcode;
/* ... all Catppuccin colors */
```

**`mytheme.rasi`:**

```rasi
* {
    bg: #hexcode;
    fg: #hexcode;
    /* ... colors + complete Rofi styling */
}
window { /* styling */ }
inputbar { /* styling */ }
/* ... all UI elements */
```

**`mytheme.ghostty`:**

```
palette = 0=#hexcode
palette = 1=#hexcode
# ... 0-15
background = hexcode
foreground = hexcode
cursor-color = hexcode
selection-background = hexcode
```

**`mytheme.tmux`:**

```bash
set -g @catppuccin_flavour 'mytheme'
```

### 2. Update Theme Switcher

Edit `waybar/.config/waybar/scripts/wofi-theme-switcher.sh`:

**Add to menu options:**

```bash
[ "$current_theme" == "MyTheme" ] && options+="● " || options+="○ "
options+="MyTheme (Dark)"$'\n'
```

**Add to case statements:**

```bash
"catppuccin/mytheme.css")
    current_theme="MyTheme"
    ;;

"MyTheme")
    theme_file="mytheme"
    ;;
```

### 3. Update Neovim Detection

Edit `nvim/.config/nvim/lua/user/theme.lua`:

```lua
local valid_flavors = {
    mocha = true,
    latte = true,
    frappe = true,
    macchiato = true,
    mytheme = true  -- Add new theme
}
```

## Catppuccin Colors Reference

### Mocha (Dark)

- Base: `#1e1e2e` | Text: `#cdd6f4` | Mauve: `#cba6f7`
- Blue: `#89b4fa` | Green: `#a6e3a1` | Red: `#f38ba8`

### Latte (Light)

- Base: `#eff1f5` | Text: `#4c4f69` | Mauve: `#8839ef`
- Blue: `#1e66f5` | Green: `#40a02b` | Red: `#d20f39`

### Frappé (Dark)

- Base: `#303446` | Text: `#c6d0f5` | Mauve: `#ca9ee6`
- Blue: `#8caaee` | Green: `#a6d189` | Red: `#e78284`

### Macchiato (Dark)

- Base: `#24273a` | Text: `#cad3f5` | Mauve: `#c6a0f6`
- Blue: `#8aadf4` | Green: `#a6da95` | Red: `#ed8796`

**Full palette:**

- Rosewater, Flamingo, Pink, Mauve, Red, Maroon, Peach, Yellow
- Green, Teal, Sky, Sapphire, Blue, Lavender
- Text, Subtext1, Subtext0, Overlay2, Overlay1, Overlay0
- Surface2, Surface1, Surface0, Base, Mantle, Crust

## Troubleshooting

### Neovim not updating

**Check server mode enabled:**

```vim
:echo v:servername
```

Should show: `/run/user/1000/nvim.{pid}.sock`

**Manually reload:**

```vim
:colorscheme catppuccin-latte
```

### Tmux not updating

**Reload manually:**

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

**Check if tmux is running:**

```bash
pgrep tmux
```

### Waybar not updating

**Check symlink:**

```bash
ls -la ~/.config/themes/current.css
```

**Manual reload:**

```bash
pkill -SIGUSR2 waybar
```

### Ghostty showing old colors

**Solution:** Open a new terminal window (Ghostty only reads config at startup)

**Check config updated:**

```bash
grep -A 5 "THEME COLORS START" ~/.config/ghostty/config
```

### Symlinks broken

**Recreate symlinks:**

```bash
cd ~/dotfiles/themes
ln -sf catppuccin/mocha.css current.css
ln -sf catppuccin/mocha.rasi current.rasi
ln -sf catppuccin/mocha.ghostty current.ghostty
ln -sf catppuccin/mocha.tmux current.tmux
echo "mocha" > current_flavor.txt
```

## Related Files

- Theme switcher: `waybar/.config/waybar/scripts/wofi-theme-switcher.sh`
- Settings menu: `waybar/.config/waybar/scripts/wofi-settings-menu.sh`
- Neovim theme util: `nvim/.config/nvim/lua/user/theme.lua`
- Neovim plugin config: `nvim/.config/nvim/lua/plugins/catppuccin.lua`
- Neovim server setup: `nvim/.config/nvim/lua/user/settings.lua`
- Waybar theme: `waybar/.config/waybar/theme.css`
- Rofi config: `rofi/.config/rofi/config.rasi`
- Ghostty config: `~/.config/ghostty/config`
- Tmux config: `tmux/.config/tmux/tmux.conf`

## Credits

- [Catppuccin](https://github.com/catppuccin/catppuccin) - Soothing pastel theme
- [Catppuccin Style Guide](https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md)
- [catppuccin/nvim](https://github.com/catppuccin/nvim)
- [catppuccin/tmux](https://github.com/catppuccin/tmux)
- [omerxx/catppuccin-tmux](https://github.com/omerxx/catppuccin-tmux)
