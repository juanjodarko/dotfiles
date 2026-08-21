#!/usr/bin/env bash
#
# Install the Omarchy-scoped dotfiles.
#
# Everything this script does is reversible with ./uninstall.sh: files Omarchy
# owns are backed up before being replaced, and nothing under /usr/share/omarchy
# is ever touched.
#
#   ./install.sh              # install
#   ./install.sh --dry-run    # report what would change, touch nothing
#   ./install.sh --no-wallpapers
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$HERE")"

STATE_DIR="$HOME/.local/state/omarchy-dotfiles"
MANIFEST="$STATE_DIR/manifest"
BACKUP_DIR="$STATE_DIR/backups/$(date +%Y%m%d_%H%M%S)"
SOURCES_FILE="$HOME/.config/omarchy/wallpaper-sources"
THEME_STATE="$HOME/.local/state/omarchy/current/theme"

# Stow packages inside this directory. Each mirrors a path under $HOME.
PACKAGES=(hypr shell bin ghostty bat)

# Configs whose apps have no include mechanism. Their template renders a whole
# config into the theme state directory, and these symlink to that output so a
# theme change retints them.
declare -A GENERATED=(
  ["$HOME/.config/starship.toml"]="$THEME_STATE/starship.toml"
  ["$HOME/.config/lazygit/config.yml"]="$THEME_STATE/lazygit.yml"
)

# Wallpaper sources, in priority order. Missing directories are skipped.
WALLPAPER_SOURCES=(
  "$DOTFILES/personal/wallpapers"
  "$DOTFILES/personal/Wallpapers"
  "$HOME/Wallpapers"
)

DRY_RUN=false
DO_WALLPAPERS=true

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'

step()  { echo -e "\n${BLUE}==>${NC} $*"; }
ok()    { echo -e "  ${GREEN}✓${NC} $*"; }
warn()  { echo -e "  ${YELLOW}!${NC} $*"; }
fail()  { echo -e "  ${RED}✗${NC} $*" >&2; }
plan()  { echo -e "  ${CYAN}would${NC} $*"; }

run() {
  if [[ $DRY_RUN == true ]]; then
    plan "$*"
  else
    "$@"
  fi
}

usage() {
  sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^#\s\?//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)       DRY_RUN=true ;;
    --no-wallpapers) DO_WALLPAPERS=false ;;
    -h|--help)       usage ;;
    *) fail "unknown option: $1"; exit 1 ;;
  esac
  shift
done

#------------------------------------------------------------------------------
# Preflight
#------------------------------------------------------------------------------
step "Checking the environment"

if [[ ! -d ${OMARCHY_PATH:-/usr/share/omarchy} ]]; then
  fail "Omarchy not found. These dotfiles are for Omarchy; use ../arch for plain Arch."
  exit 1
fi
ok "Omarchy $(cat "${OMARCHY_PATH:-/usr/share/omarchy}/version" 2>/dev/null || echo '(unknown version)')"

if ! command -v stow >/dev/null; then
  fail "GNU stow is required: omarchy pkg add stow"
  exit 1
fi
ok "stow present"

if [[ $DO_WALLPAPERS == true ]] && ! command -v magick >/dev/null; then
  warn "ImageMagick missing, skipping wallpapers (omarchy pkg add imagemagick)"
  DO_WALLPAPERS=false
fi

[[ $DRY_RUN == true ]] && echo -e "\n${CYAN}Dry run: nothing will be written.${NC}"

#------------------------------------------------------------------------------
# Back up the Omarchy-owned files we are about to replace
#------------------------------------------------------------------------------
step "Backing up files Omarchy owns"

# Every path a stow package would claim, plus the generated-config targets.
targets=()
for package in "${PACKAGES[@]}"; do
  [[ -d $HERE/$package ]] || continue
  while IFS= read -r file; do
    targets+=("$HOME/${file#"$HERE/$package/"}")
  done < <(find "$HERE/$package" -type f)
done
targets+=("${!GENERATED[@]}")

backed_up=0
for target in "${targets[@]}"; do
  # Only real files need rescuing. A symlink is either ours already or the
  # user's, and stow reports on those itself.
  [[ -f $target && ! -L $target ]] || continue

  relative="${target#"$HOME"/}"
  if [[ $DRY_RUN == true ]]; then
    plan "back up ~/$relative"
  else
    mkdir -p "$BACKUP_DIR/$(dirname "$relative")" "$STATE_DIR"
    cp -a "$target" "$BACKUP_DIR/$relative"
    # Append rather than replace: across repeated installs the FIRST recorded
    # copy of a path is the pristine Omarchy one, and that is what uninstall
    # restores.
    printf '%s\t%s\n' "$BACKUP_DIR" "$relative" >>"$MANIFEST"
    rm -f "$target"
  fi
  backed_up=$((backed_up + 1))
done

if [[ $backed_up -eq 0 ]]; then
  ok "nothing to back up"
elif [[ $DRY_RUN != true ]]; then
  ok "$backed_up file(s) saved to ${BACKUP_DIR/#$HOME/\~}"
fi

#------------------------------------------------------------------------------
# Deploy
#------------------------------------------------------------------------------
step "Stowing packages"

for package in "${PACKAGES[@]}"; do
  if [[ ! -d $HERE/$package ]]; then
    warn "$package not found, skipping"
    continue
  fi
  if [[ $DRY_RUN == true ]]; then
    stow --no --verbose=1 --dir="$HERE" --target="$HOME" "$package" 2>&1 |
      sed 's/^/  /' || true
  else
    stow --restow --dir="$HERE" --target="$HOME" "$package"
    ok "$package"
  fi
done

#------------------------------------------------------------------------------
# Render templates, then point the include-less configs at the output
#------------------------------------------------------------------------------
step "Rendering themed templates"

current_theme="$(omarchy theme current 2>/dev/null || true)"
if [[ -z $current_theme ]]; then
  warn "could not read the current theme; skipping render"
else
  # Re-applying the active theme is what runs omarchy-theme-set-templates over
  # the new user templates in ~/.config/omarchy/themed/.
  run omarchy theme set "$current_theme"
  [[ $DRY_RUN == true ]] || ok "re-applied '$current_theme' to render templates"
fi

for target in "${!GENERATED[@]}"; do
  generated="${GENERATED[$target]}"
  relative="${target#"$HOME"/}"

  if [[ $DRY_RUN == true ]]; then
    plan "link ~/$relative -> ${generated/#$HOME/\~}"
    continue
  fi

  if [[ ! -f $generated ]]; then
    warn "~/$relative: ${generated/#$HOME/\~} was not generated, skipping"
    continue
  fi

  mkdir -p "$(dirname "$target")"
  ln -sfn "$generated" "$target"
  ok "~/$relative -> ${generated/#$HOME/\~}"
done

#------------------------------------------------------------------------------
# Wallpapers
#------------------------------------------------------------------------------
if [[ $DO_WALLPAPERS == true ]]; then
  step "Seeding wallpapers"

  available=()
  for source in "${WALLPAPER_SOURCES[@]}"; do
    [[ -d $source ]] && available+=("$source")
  done

  if [[ ${#available[@]} -eq 0 ]]; then
    warn "no wallpaper directory found (looked in: ${WALLPAPER_SOURCES[*]/#$HOME/\~})"
    warn "run 'git submodule update --init personal', then: omarchy-wallpapers-sync"
  else
    if [[ $DRY_RUN == true ]]; then
      plan "record sources in ${SOURCES_FILE/#$HOME/\~}: ${available[*]}"
      "$HERE/bin/.local/bin/omarchy-wallpapers-sync" \
        "${available[@]/#/--source=}" --dry-run --quiet || true
    else
      mkdir -p "$(dirname "$SOURCES_FILE")"
      printf '%s\n' "${available[@]}" >"$SOURCES_FILE"
      ok "sources: ${available[*]/#$HOME/\~}"
      "$HOME/.local/bin/omarchy-wallpapers-sync" --quiet || warn "wallpaper sync failed"
    fi
  fi
fi

#------------------------------------------------------------------------------
# Validate
#------------------------------------------------------------------------------
step "Validating Hyprland config"

if [[ $DRY_RUN == true ]]; then
  plan "hyprctl reload && hyprctl configerrors"
elif command -v hyprctl >/dev/null && hyprctl monitors >/dev/null 2>&1; then
  hyprctl reload >/dev/null
  errors="$(hyprctl configerrors 2>&1)"
  if [[ $errors == *"no errors"* || -z $errors ]]; then
    ok "no config errors"
  else
    fail "Hyprland reported config errors:"
    echo "$errors" | sed 's/^/    /'
  fi
else
  warn "Hyprland is not running; bindings apply on next login"
fi

#------------------------------------------------------------------------------
echo
if [[ $DRY_RUN == true ]]; then
  echo -e "${CYAN}Dry run complete.${NC} Re-run without --dry-run to apply."
else
  echo -e "${GREEN}Done.${NC} Personal ALT bindings, themed templates and wallpapers are live."
  echo "  Keybindings:      omarchy menu keybindings --print"
  echo "  Cycle wallpaper:  ALT + SHIFT + W  (or: omarchy theme bg next)"
  echo "  Re-sync after adding wallpapers:  omarchy-wallpapers-sync"
  echo "  Undo everything:  $HERE/uninstall.sh"
fi
