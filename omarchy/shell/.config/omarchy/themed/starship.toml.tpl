# Starship prompt, themed by Omarchy.
#
# This is a TEMPLATE, not a config: omarchy-theme-set-templates renders it to
#   ~/.local/state/omarchy/current/theme/starship.toml
# on every theme change, and ~/.config/starship.toml symlinks to that output.
#
# Starship has no include mechanism, so the whole prompt lives here and only
# the palette below is substituted. Edit this file, not ~/.config/starship.toml
# (which is a generated symlink), then run `omarchy theme set "$(omarchy theme current)"`
# to re-render.
#
# Placeholders come from the active theme's colors.toml. See the full list with:
#   omarchy-theme-color --file ~/.local/state/omarchy/current/theme/colors.toml --all

"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](surface0)\
$os\
$username\
[](bg:peach fg:surface0)\
$directory\
[](fg:peach bg:green)\
$git_branch\
$git_status\
[](fg:green bg:teal)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:teal bg:blue)\
$docker_context\
[](fg:blue bg:purple)\
$time\
[ ](fg:purple)\
$line_break$character"""

# === THEME PALETTE START ===
# Selects the palette rendered from the active Omarchy theme.
palette = 'omarchy'
# === THEME PALETTE END ===

[palettes.gruvbox_dark]
color_fg0 = '#fbf1c7'
color_bg1 = '#3c3836'
color_bg3 = '#665c54'
color_blue = '#458588'
color_aqua = '#689d6a'
color_green = '#98971a'
color_orange = '#d65d0e'
color_purple = '#b16286'
color_red = '#cc241d'
color_yellow = '#d79921'

# === THEME COLORS START ===
# Rendered from the active theme's colors.toml on every `omarchy theme set`.
[palettes.omarchy]
rosewater = "{{ bright_foreground }}"
flamingo = "{{ bright_red }}"
pink = "{{ bright_magenta }}"
orange = "{{ orange }}"
red = "{{ red }}"
maroon = "{{ bright_red }}"
peach = "{{ orange }}"
yellow = "{{ yellow }}"
green = "{{ green }}"
teal = "{{ cyan }}"
sky = "{{ bright_cyan }}"
sapphire = "{{ bright_blue }}"
blue = "{{ blue }}"
lavender = "{{ accent }}"
text = "{{ foreground }}"
subtext1 = "{{ light_foreground }}"
subtext0 = "{{ dark_foreground }}"
overlay2 = "{{ muted }}"
overlay1 = "{{ muted }}"
overlay0 = "{{ dark_foreground }}"
surface2 = "{{ muted }}"
surface1 = "{{ selection }}"
surface0 = "{{ lighter_background }}"
base = "{{ background }}"
mantle = "{{ dark_background }}"
crust = "{{ darker_background }}"
purple = "{{ magenta }}"
# === THEME COLORS END ===

[os]
disabled = false
style = "bg:surface0 fg:text"

[os.symbols]
Windows = "󰍲"
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = ""
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
Arch = "󰣇"
Artix = "󰣇"
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

[username]
show_always = true
style_user = "bg:surface0 fg:text"
style_root = "bg:surface0 fg:text"
format = '[ $user ]($style)'

[directory]
style = "fg:mantle bg:peach"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:green"
format = '[[ $symbol $branch ](fg:base bg:green)]($style)'

[git_status]
style = "bg:green"
format = '[[($all_status$ahead_behind )](fg:base bg:green)]($style)'

[nodejs]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[c]
symbol = " "
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[rust]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[golang]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[php]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[java]
symbol = " "
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[kotlin]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[haskell]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[python]
symbol = ""
style = "bg:teal"
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'

[docker_context]
symbol = ""
style = "bg:mantle"
format = '[[ $symbol( $context) ](fg:base bg:blue)]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:peach"
format = '[[  $time ](fg:mantle bg:purple)]($style)'

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[](bold fg:green)'
error_symbol = '[](bold fg:red)'
vimcmd_symbol = '[](bold fg:green)'
vimcmd_replace_one_symbol = '[](bold fg:purple)'
vimcmd_replace_symbol = '[](bold fg:purple)'
vimcmd_visual_symbol = '[](bold fg:lavender)'
