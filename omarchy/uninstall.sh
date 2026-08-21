#!/usr/bin/env bash
#
# Remove the Omarchy-scoped dotfiles and restore what Omarchy shipped.
#
#   ./uninstall.sh              # remove and restore
#   ./uninstall.sh --dry-run    # report what would change, touch nothing
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STATE_DIR="$HOME/.local/state/omarchy-dotfiles"
MANIFEST="$STATE_DIR/manifest"
SOURCES_FILE="$HOME/.config/omarchy/wallpaper-sources"

PACKAGES=(hypr shell bin ghostty bat)
GENERATED_TARGETS=(
  "$HOME/.config/starship.toml"
  "$HOME/.config/lazygit/config.yml"
)

DRY_RUN=false

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'

step()  { echo -e "\n${BLUE}==>${NC} $*"; }
ok()    { echo -e "  ${GREEN}✓${NC} $*"; }
warn()  { echo -e "  ${YELLOW}!${NC} $*"; }
fail()  { echo -e "  ${RED}✗${NC} $*" >&2; }
plan()  { echo -e "  ${CYAN}would${NC} $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,7p' "${BASH_SOURCE[0]}" | sed 's/^#\s\?//'; exit 0 ;;
    *) fail "unknown option: $1"; exit 1 ;;
  esac
  shift
done

[[ $DRY_RUN == true ]] && echo -e "${CYAN}Dry run: nothing will be written.${NC}"

#------------------------------------------------------------------------------
step "Removing seeded wallpapers"

if command -v omarchy-wallpapers-sync >/dev/null || [[ -x $HERE/bin/.local/bin/omarchy-wallpapers-sync ]]; then
  sync_bin="$(command -v omarchy-wallpapers-sync || echo "$HERE/bin/.local/bin/omarchy-wallpapers-sync")"
  if [[ $DRY_RUN == true ]]; then
    "$sync_bin" --clean --dry-run || true
  else
    "$sync_bin" --clean || warn "could not clean wallpaper links"
    rm -f "$SOURCES_FILE"
  fi
else
  warn "omarchy-wallpapers-sync not found, skipping"
fi

#------------------------------------------------------------------------------
step "Unlinking generated configs"

for target in "${GENERATED_TARGETS[@]}"; do
  relative="${target#"$HOME"/}"
  if [[ -L $target ]]; then
    if [[ $DRY_RUN == true ]]; then
      plan "remove symlink ~/$relative"
    else
      rm -f "$target"
      ok "removed ~/$relative"
    fi
  fi
done

#------------------------------------------------------------------------------
step "Unstowing packages"

for package in "${PACKAGES[@]}"; do
  [[ -d $HERE/$package ]] || continue
  if [[ $DRY_RUN == true ]]; then
    stow --no --verbose=1 --delete --dir="$HERE" --target="$HOME" "$package" 2>&1 |
      sed 's/^/  /' || true
  else
    stow --delete --dir="$HERE" --target="$HOME" "$package" 2>/dev/null || warn "$package already unstowed"
    ok "$package"
  fi
done

#------------------------------------------------------------------------------
step "Restoring Omarchy's original files"

if [[ ! -f $MANIFEST ]]; then
  warn "no manifest at ${MANIFEST/#$HOME/\~}; nothing to restore"
  warn "reset individual files with: omarchy refresh config <path-under-.config>"
else
  restored=0
  missing=0
  # The manifest may hold several entries per path across repeated installs.
  # The first one is the pristine Omarchy copy, so later duplicates are ignored.
  declare -A seen=()
  while IFS=$'\t' read -r backup_dir relative; do
    [[ -n ${relative:-} ]] || continue
    [[ -z ${seen[$relative]:-} ]] || continue
    seen[$relative]=1

    source="$backup_dir/$relative"
    target="$HOME/$relative"

    if [[ ! -f $source ]]; then
      warn "backup missing for ~/$relative"
      missing=$((missing + 1))
      continue
    fi

    if [[ $DRY_RUN == true ]]; then
      plan "restore ~/$relative"
    else
      mkdir -p "$(dirname "$target")"
      # Anything still sitting here is ours; the backup is the authority.
      rm -f "$target"
      cp -a "$source" "$target"
    fi
    restored=$((restored + 1))
  done <"$MANIFEST"

  if [[ $DRY_RUN != true ]]; then
    ok "restored $restored file(s)"
    rm -f "$MANIFEST"
  fi
  [[ $missing -gt 0 ]] && warn "$missing file(s) had no backup; use 'omarchy refresh config <path>'"
fi

#------------------------------------------------------------------------------
step "Re-applying the theme"

if [[ $DRY_RUN == true ]]; then
  plan "omarchy theme set \"\$(omarchy theme current)\""
else
  current_theme="$(omarchy theme current 2>/dev/null || true)"
  if [[ -n $current_theme ]]; then
    omarchy theme set "$current_theme" && ok "re-applied '$current_theme'"
  else
    warn "could not read the current theme"
  fi
fi

#------------------------------------------------------------------------------
step "Reloading Hyprland"

if [[ $DRY_RUN == true ]]; then
  plan "hyprctl reload"
elif command -v hyprctl >/dev/null && hyprctl monitors >/dev/null 2>&1; then
  hyprctl reload >/dev/null && ok "reloaded"
else
  warn "Hyprland is not running"
fi

echo
if [[ $DRY_RUN == true ]]; then
  echo -e "${CYAN}Dry run complete.${NC} Re-run without --dry-run to apply."
else
  echo -e "${GREEN}Done.${NC} Stock Omarchy behaviour restored."
  echo "  Backups are kept in ${STATE_DIR/#$HOME/\~}/backups/"
fi
