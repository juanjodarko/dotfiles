#!/usr/bin/env bash

# Wofi-based Theme Switcher
# Switch between Catppuccin flavor themes using central theme system

WOFI_STYLE="$HOME/.config/wofi/theme-switcher.css"
THEMES_DIR="$HOME/.config/themes"
CURRENT_CSS="$THEMES_DIR/current.css"
CURRENT_RASI="$THEMES_DIR/current.rasi"
CURRENT_GHOSTTY="$THEMES_DIR/current.ghostty"
CURRENT_TMUX="$THEMES_DIR/current.tmux"
CURRENT_HYPR="$THEMES_DIR/current.conf"
CURRENT_STARSHIP="$THEMES_DIR/current.starship"
CURRENT_FLAVOR="$THEMES_DIR/current_flavor.txt"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Initialize theme files with defaults if they don't exist
function init_theme_files() {
    local default_theme="mocha"

    # Create symlinks if missing (using relative paths)
    cd "$THEMES_DIR"
    [ ! -L "$CURRENT_CSS" ] && ln -sf "catppuccin/${default_theme}.css" current.css
    [ ! -L "$CURRENT_RASI" ] && ln -sf "catppuccin/${default_theme}.rasi" current.rasi
    [ ! -L "$CURRENT_GHOSTTY" ] && ln -sf "catppuccin/${default_theme}.ghostty" current.ghostty
    [ ! -L "$CURRENT_TMUX" ] && ln -sf "catppuccin/${default_theme}.tmux" current.tmux
    [ ! -L "$CURRENT_HYPR" ] && ln -sf "../../../hyprland/.config/hypr/${default_theme}.conf" current.conf
    [ ! -L "$CURRENT_STARSHIP" ] && ln -sf "catppuccin/${default_theme}.starship" current.starship

    # Create flavor file if missing
    [ ! -f "$CURRENT_FLAVOR" ] && echo "$default_theme" > "$CURRENT_FLAVOR"
}

# Initialize on script start
init_theme_files

# Get current theme from symlink
current_link=$(readlink "$CURRENT_CSS")
current_theme=""

case "$current_link" in
    "catppuccin/mocha.css")
        current_theme="Mocha"
        ;;
    "catppuccin/latte.css")
        current_theme="Latte"
        ;;
    "catppuccin/frappe.css")
        current_theme="Frappé"
        ;;
    "catppuccin/macchiato.css")
        current_theme="Macchiato"
        ;;
esac

# Build menu options with current theme indicator
options=""
[ "$current_theme" == "Mocha" ] && options+="● " || options+="○ "
options+="Mocha (Dark)"$'\n'

[ "$current_theme" == "Latte" ] && options+="● " || options+="○ "
options+="Latte (Light)"$'\n'

[ "$current_theme" == "Frappé" ] && options+="● " || options+="○ "
options+="Frappé (Dark)"$'\n'

[ "$current_theme" == "Macchiato" ] && options+="● " || options+="○ "
options+="Macchiato (Dark)"

# Show wofi menu
selected=$(echo "$options" | wofi --dmenu --normal-window \
    --style "${WOFI_STYLE}" \
    --prompt "🎨 Select Theme (Current: $current_theme)" \
    --width 450 --height 280 --location 0)

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Extract theme name from selection
theme_name=$(echo "$selected" | sed 's/^[●○] //' | awk '{print $1}')

# Determine theme file names (lowercase for file paths)
case "$theme_name" in
    "Mocha")
        theme_file="mocha"
        ;;
    "Latte")
        theme_file="latte"
        ;;
    "Frappé")
        theme_file="frappe"
        ;;
    "Macchiato")
        theme_file="macchiato"
        ;;
    *)
        exit 1
        ;;
esac

# Check if already on this theme
if [ "$current_theme" == "$theme_name" ]; then
    notify-send "Theme" "Already using $theme_name theme" -i preferences-desktop-theme
    exit 0
fi

# Update central theme symlinks (using relative paths)
cd "$THEMES_DIR"
ln -sf "catppuccin/${theme_file}.css" current.css
ln -sf "catppuccin/${theme_file}.rasi" current.rasi
ln -sf "catppuccin/${theme_file}.ghostty" current.ghostty
ln -sf "catppuccin/${theme_file}.tmux" current.tmux
ln -sf "../../../hyprland/.config/hypr/${theme_file}.conf" current.conf
ln -sf "catppuccin/${theme_file}.starship" current.starship

# Update Neovim flavor file
echo "$theme_file" > "$CURRENT_FLAVOR"

# Update ghostty config with new theme colors
if [ -f "$GHOSTTY_CONFIG" ] && [ -f "$CURRENT_GHOSTTY" ]; then
    # Extract theme colors from the current.ghostty file
    theme_colors=$(cat "$CURRENT_GHOSTTY")

    # Create temporary file with updated theme
    temp_file=$(mktemp)

    # Use awk to replace content between markers
    awk -v theme="$theme_colors" '
        /^# === THEME COLORS START ===/ {
            print
            print "# This section is automatically managed by the theme switcher"
            print "# Do not manually edit between THEME COLORS START and END markers"
            print theme
            skip=1
            next
        }
        /^# === THEME COLORS END ===/ {
            skip=0
        }
        !skip
    ' "$GHOSTTY_CONFIG" > "$temp_file"

    # Replace config file
    mv "$temp_file" "$GHOSTTY_CONFIG"
fi

# Update starship config with new theme
if [ -f "$STARSHIP_CONFIG" ] && [ -f "$CURRENT_STARSHIP" ]; then
    # Extract theme colors from the current.starship file
    theme_colors=$(cat "$CURRENT_STARSHIP")

    # Capitalize first letter for palette name
    theme_palette="catppuccin_${theme_file}"

    # Create temporary file with updated theme
    temp_file=$(mktemp)

    # First, update the palette reference line
    awk -v palette="$theme_palette" '
        /^# === THEME PALETTE START ===/ {
            print
            print "# This line is automatically managed by the theme switcher"
            print "# Do not manually edit this line"
            print "palette = '\''" palette "'\''"
            skip=1
            next
        }
        /^# === THEME PALETTE END ===/ {
            skip=0
            print
            next
        }
        !skip
    ' "$STARSHIP_CONFIG" > "$temp_file.step1"

    # Second, update the palette colors section
    awk -v theme="$theme_colors" '
        /^# === THEME COLORS START ===/ {
            print
            print "# This section is automatically managed by the theme switcher"
            print "# Do not manually edit between THEME COLORS START and END markers"
            print theme
            skip=1
            next
        }
        /^# === THEME COLORS END ===/ {
            skip=0
        }
        !skip
    ' "$temp_file.step1" > "$temp_file"

    # Replace config file
    mv "$temp_file" "$STARSHIP_CONFIG"
    rm -f "$temp_file.step1"
fi

# Reload waybar
pkill -SIGUSR2 waybar

# Reload swaync (notification daemon)
if command -v swaync-client &> /dev/null; then
    swaync-client -rs 2>/dev/null &
fi

# Reload tmux if running
if [ -n "$TMUX" ]; then
    # Running inside tmux, reload config
    tmux source-file "$TMUX_CONFIG" 2>/dev/null
elif pgrep -x tmux > /dev/null; then
    # Tmux is running but we're not inside it, reload all sessions
    tmux source-file "$TMUX_CONFIG" 2>/dev/null
fi

# Reload Neovim if running (find all server sockets)
NVIM_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
for nvim_socket in "$NVIM_RUNTIME_DIR"/nvim.*.sock; do
    if [ -S "$nvim_socket" ]; then
        # Send colorscheme change command to running Neovim instance
        nvim --server "$nvim_socket" --remote-send ":colorscheme catppuccin-${theme_file}<CR>" 2>/dev/null &
    fi
done

# Reload Hyprland if running
if pgrep -x Hyprland > /dev/null; then
    hyprctl reload 2>/dev/null &
fi

# Notify user
notify-send "Theme Changed" "Switched to Catppuccin $theme_name\nWaybar, SwayNC & Starship updated\nRestart Ghostty for terminal colors" -i preferences-desktop-theme

exit 0
