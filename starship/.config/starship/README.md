# Starship Configuration

Beautiful Catppuccin Mocha themed cross-shell prompt with powerline-style segments and intelligent context awareness.

## Features

- **Catppuccin Mocha Theme** - Full color palette integration
- **Powerline Style** - Seamless segment transitions with Nerd Font arrows
- **Multi-Segment Layout** - OS, user, directory, git, languages, docker, time
- **Language Detection** - Automatic version display for 9+ languages
- **Git Integration** - Branch, status, and staging indicators
- **Docker Awareness** - Shows active docker context
- **Vim Mode Indicators** - Different symbols for normal/insert/visual modes
- **Smart Directory Substitutions** - Icons for common folders
- **Fast** - Typically <10ms prompt rendering

## Dependencies

**Required:**
- `starship` - Cross-shell prompt
- Nerd Font - For icons (JetBrainsMono Nerd Font recommended)

**Optional (for language detection):**
- `node` - Node.js version display
- `python` - Python version display
- `rustc` - Rust version display
- `go` - Go version display
- `gcc` - C version display
- `php` - PHP version display
- `java` - Java version display
- `kotlinc` - Kotlin version display
- `ghc` - Haskell version display
- `docker` - Docker context display

## Configuration Files

```
starship/
└── .config/
    └── starship.toml  # Main configuration
```

## Prompt Layout

### Visual Structure

```
┌──[OS][username][directory][git][languages][docker][time]
└─❯
```

**Example:**
```
┌──[󰣇 juanjo][~/dotfiles/nvim][  main ✓][  v18.0.0][ 14:30]
└─❯
```

### Segment Breakdown

**Powerline segments (left to right):**

1. **OS Icon** - Operating system indicator
2. **Username** - Current user
3. **Directory** - Current path (truncated)
4. **Git Branch** - Current branch + status
5. **Language** - Detected language version(s)
6. **Docker** - Active docker context
7. **Time** - Current time (HH:MM)

**Command indicator (new line):**
- ❯ - Success (green)
- ❯ - Error (red)
- ❮ - Vim normal mode (green)
- ❰R❱ - Vim replace mode (purple)
- ❰V❱ - Vim visual mode (lavender)

## Color Scheme

### Catppuccin Mocha Palette

**Segment colors:**

| Segment | Background | Foreground | Hex |
|---------|------------|------------|-----|
| OS/Username | Surface0 | Text | `#313244` / `#cdd6f4` |
| Directory | Peach | Mantle | `#fab387` / `#181825` |
| Git | Green | Base | `#a6e3a1` / `#1e1e2e` |
| Languages | Teal | Base | `#94e2d5` / `#1e1e2e` |
| Docker | Blue | Base | `#89b4fa` / `#1e1e2e` |
| Time | Purple | Mantle | `#cba6f7` / `#181825` |

**Powerline arrows:**
- Use foreground color of previous segment
- Use background color of current segment
- Creates seamless transitions

### Alternative Palette

**Gruvbox Dark** (included but not active):

Edit `starship.toml`:
```toml
palette = 'gruvbox_dark'  # Change from catppuccin_mocha
```

## Modules

### OS Icon

**Purpose:** Shows operating system

**Symbols:**
- 󰣇 Arch Linux
- 󰕈 Ubuntu
-  macOS
-  Fedora
- 󰣚 Debian
- 󰌽 Generic Linux

**Configuration:**
```toml
[os]
disabled = false
style = "bg:surface0 fg:text"
```

### Username

**Purpose:** Shows current user

**Display:** Always visible

**Format:** ` username `

**Styling:**
- User: Text on Surface0
- Root: Same (security consideration)

**Configuration:**
```toml
[username]
show_always = true
style_user = "bg:surface0 fg:text"
style_root = "bg:surface0 fg:text"
```

### Directory

**Purpose:** Shows current path

**Truncation:**
- Max depth: 3 directories
- Symbol: `…/` for truncated path

**Substitutions:**
- `~/Documents` → 󰈙
- `~/Downloads` →
- `~/Music` → 󰝚
- `~/Pictures` →
- `~/Developer` → 󰲋

**Examples:**
- `/home/user/dotfiles/nvim` → `~/dotfiles/nvim`
- `/home/user/very/deep/path/here` → `…/deep/path/here`
- `~/Documents/notes` → `󰈙 /notes`

**Configuration:**
```toml
[directory]
style = "fg:mantle bg:peach"
truncation_length = 3
truncation_symbol = "…/"
```

### Git Branch

**Purpose:** Shows current git branch

**Symbol:**

**Format:** ` branch-name`

**Only visible in git repositories**

**Configuration:**
```toml
[git_branch]
symbol = ""
format = '[[ $symbol $branch ](fg:base bg:green)]($style)'
```

### Git Status

**Purpose:** Shows repository status

**Indicators:**
- `?` - Untracked files
- `+` - Added files
- `!` - Modified files
- `✘` - Deleted files
- `»` - Renamed files
- `⇡` - Ahead of remote
- `⇣` - Behind remote

**Examples:**
- ` main ✓` - Clean repository
- ` main +2 !1` - 2 added, 1 modified
- ` main ⇡3` - 3 commits ahead

**Configuration:**
```toml
[git_status]
format = '[[($all_status$ahead_behind )](fg:base bg:green)]($style)'
```

### Languages

**Purpose:** Auto-detect and show language versions

**Supported languages:**

| Language | Symbol | Detection |
|----------|--------|-----------|
| Node.js |  | `package.json`, `.nvmrc` |
| Python |  | `.py` files, `requirements.txt` |
| Rust |  | `Cargo.toml` |
| Go |  | `go.mod` |
| C |  | `.c`, `.h` files |
| PHP |  | `.php` files |
| Java |  | `.java`, `pom.xml` |
| Kotlin |  | `.kt` files |
| Haskell |  | `.hs` files |

**Display:** Only shows if language detected in current directory

**Format:** ` v18.0.0`

**Configuration:**
```toml
[nodejs]
symbol = ""
format = '[[ $symbol( $version) ](fg:base bg:teal)]($style)'
```

### Docker Context

**Purpose:** Shows active docker context

**Symbol:**

**Format:** ` context-name`

**Only visible when:**
- Inside a directory with `docker-compose.yml`
- Or non-default docker context is active

**Configuration:**
```toml
[docker_context]
symbol = ""
format = '[[ $symbol( $context) ](fg:base bg:blue)]($style)'
```

### Time

**Purpose:** Shows current time

**Format:** HH:MM (24-hour)

**Symbol:**

**Always visible**

**Configuration:**
```toml
[time]
disabled = false
time_format = "%R"  # %R = HH:MM
format = '[[  $time ](fg:mantle bg:purple)]($style)'
```

### Command Character

**Purpose:** Indicates command success/failure and vim mode

**Symbols:**

| Mode | Symbol | Color | Meaning |
|------|--------|-------|---------|
| Success | ❯ | Green | Last command succeeded |
| Error | ❯ | Red | Last command failed |
| Vim Normal | ❮ | Green | Vim normal mode |
| Vim Replace | ❰R❱ | Purple | Vim replace mode |
| Vim Visual | ❰V❱ | Lavender | Vim visual mode |

**Configuration:**
```toml
[character]
success_symbol = '[](bold fg:green)'
error_symbol = '[](bold fg:red)'
vimcmd_symbol = '[](bold fg:green)'
vimcmd_replace_symbol = '[](bold fg:purple)'
vimcmd_visual_symbol = '[](bold fg:lavender)'
```

## Shell Integration

### ZSH

**Setup (already configured in dotfiles):**

`.zshrc`:
```bash
eval "$(starship init zsh)"
```

**Vim Mode Support:**

```bash
# Enable vim mode
bindkey -v

# Starship automatically detects and shows vim mode
```

### Bash

**Setup:**

`.bashrc`:
```bash
eval "$(starship init bash)"
```

### Fish

**Setup:**

`~/.config/fish/config.fish`:
```fish
starship init fish | source
```

## Customization

### Change Colors

Edit `starship.toml`:

```toml
# Change directory color from peach to blue
[directory]
style = "fg:mantle bg:blue"  # Was bg:peach

# Change git segment to lavender
[git_branch]
style = "bg:lavender"
[git_status]
style = "bg:lavender"
```

### Add/Remove Modules

**Current format:**
```toml
format = """
[](surface0)\
$os\
$username\
[](bg:peach fg:surface0)\
$directory\
[](fg:peach bg:green)\
$git_branch\
$git_status\
[](fg:green bg:teal)\
$nodejs\  # Language modules
$python\
# ... more languages
[](fg:teal bg:blue)\
$docker_context\
[](fg:blue bg:purple)\
$time\
[ ](fg:purple)\
$line_break$character"""
```

**Remove time module:**
```toml
# Delete these lines:
# [](fg:blue bg:purple)\
# $time\
# [ ](fg:purple)\

# Change last arrow:
[](fg:blue)\  # No bg:purple
$line_break$character"""
```

**Add new module (example: battery):**
```toml
# After time module:
[](fg:purple bg:yellow)\
$battery\
[ ](fg:yellow)\

# Configure battery:
[battery]
format = '[[ $symbol $percentage ](fg:base bg:yellow)]($style)'
[[battery.display]]
threshold = 20
style = "bg:red"
```

### Change Truncation

**Longer paths:**
```toml
[directory]
truncation_length = 5  # Show 5 levels instead of 3
```

**No truncation:**
```toml
[directory]
truncation_length = 0  # Show full path
```

### Custom Directory Substitutions

```toml
[directory.substitutions]
"Projects" = "󰲋 "
"Work" = " "
".config" = " "
"node_modules" = " "
```

### Change Time Format

```toml
[time]
time_format = "%I:%M %p"  # 12-hour with AM/PM
# or
time_format = "%T"        # HH:MM:SS
```

### Disable Modules

**Hide username:**
```toml
[username]
disabled = true
```

**Hide OS icon:**
```toml
[os]
disabled = true
```

**Hide git status (keep branch):**
```toml
[git_status]
disabled = true
```

## Performance

**Typical render time:** < 10ms

**Benchmark your prompt:**
```bash
time starship prompt
```

**Optimization tips:**

1. **Disable unused language modules:**
   ```toml
   [nodejs]
   disabled = true  # If you don't use Node.js
   ```

2. **Reduce git status checks:**
   ```toml
   [git_status]
   disabled = true  # Only show branch
   ```

3. **Cache directory scans:**
   Starship automatically caches directory scans

## Troubleshooting

### Icons not showing

**Problem:** Boxes or missing symbols

**Solution:**
```bash
# Install Nerd Font
yay -S ttf-jetbrains-mono-nerd

# Set terminal font to JetBrainsMono Nerd Font
# In ghostty config:
font-family = JetBrainsMono Nerd Font
```

### Colors wrong

**Problem:** Colors look different than expected

**Solution:**
```bash
# Check terminal supports 24-bit color
echo $COLORTERM  # Should show "truecolor"

# Test colors
starship print-config
```

### Prompt too slow

**Problem:** Noticeable lag before prompt appears

**Solution:**
```bash
# Benchmark to find slow module
starship timings

# Disable slow modules
# Common culprits: git_status in large repos
[git_status]
disabled = true
```

### Git status not showing

**Problem:** Branch shows but no status indicators

**Solution:**
```bash
# Check if in git repo
git status

# Verify git_status module enabled
starship print-config | grep git_status

# Re-enable if disabled
[git_status]
disabled = false
```

### Language version not showing

**Problem:** Language installed but version not displayed

**Solution:**
```bash
# Check language in PATH
which node
node --version

# Verify detection files exist
ls package.json  # For Node.js
ls Cargo.toml    # For Rust

# Test module directly
starship module nodejs
```

### Vim mode indicator not working

**Problem:** Vim mode doesn't change prompt symbol

**Solution:**

For ZSH:
```bash
# Ensure vim mode enabled in .zshrc
bindkey -v

# Export STARSHIP_SHELL
export STARSHIP_SHELL="zsh"
```

For Bash:
```bash
# Enable vim mode
set -o vi
```

## Advanced Configuration

### Conditional Modules

**Show module only in specific directories:**

```toml
[nodejs]
detect_extensions = ['js', 'mjs', 'cjs', 'ts']
detect_files = ['package.json', '.nvmrc']
detect_folders = ['node_modules']
```

### Custom Commands

**Add custom module:**

```toml
format = """
# ... existing modules
$custom.uptime\
# ... rest of format
"""

[custom.uptime]
command = "uptime -p | sed 's/up //'"
when = true
format = "[[ $output ](fg:base bg:pink)]($style)"
```

### Environment Variables

**Show environment variables:**

```toml
[env_var.EDITOR]
format = "[[ $env_value ](fg:base bg:yellow)]($style)"
```

### AWS/GCloud Context

**Add cloud context:**

```toml
format = """
# ... after docker
$aws\
$gcloud\
# ...
"""

[aws]
format = '[[ $symbol($profile )(\($region\) )](fg:base bg:yellow)]($style)'
symbol = "☁️ "

[gcloud]
format = '[[ $symbol$account(@$domain)(\($project\)) ](fg:base bg:blue)]($style)'
```

## Preset Configurations

Starship includes many presets. To use one:

```bash
# List available presets
starship preset -l

# Preview a preset
starship preset nerd-font-symbols -o - | less

# Apply a preset
starship preset nerd-font-symbols > ~/.config/starship.toml
```

**Popular presets:**
- `nerd-font-symbols` - Uses Nerd Font icons
- `bracketed-segments` - Segments with brackets
- `plain-text-symbols` - No special fonts needed
- `no-runtime-versions` - Hides language versions
- `pure-preset` - Minimal pure-style prompt

**Note:** Applying a preset will overwrite your current config!

## Configuration Reference

**Full documentation:**
```bash
# Open Starship docs
starship config

# Or visit:
https://starship.rs/config/
```

**List all modules:**
```bash
starship module --list
```

**Test a module:**
```bash
starship module <module-name>
# Example:
starship module directory
```

**Explain config:**
```bash
starship explain
```

## Links

- [Starship Official Site](https://starship.rs/)
- [Starship GitHub](https://github.com/starship/starship)
- [Starship Configuration Docs](https://starship.rs/config/)
- [Catppuccin Starship](https://github.com/catppuccin/starship)
- [Nerd Fonts](https://www.nerdfonts.com/)

---

_Last Updated: 2025-10-10_
