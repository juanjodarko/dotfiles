#!/usr/bin/env bash
#
# bootstrap.sh — first step on a fresh Arch install (after the archinstall base).
#
#   curl -fsSL https://raw.githubusercontent.com/juanjodarko/dotfiles/omarchy-quattro/bootstrap.sh | bash
#
# 1. installs git + github-cli
# 2. GitHub device login (gh auth login: type a one-time code in any browser) and
#    gh as git's credential helper — the private submodules (personal, dockshell)
#    then clone over HTTPS with no SSH key
# 3. rewrites git@github.com: URLs to https:// (~/.config/git/config) so the SSH
#    URLs in .gitmodules keep working
# 4. clones the repo + submodules into ~/dotfiles and runs install.sh
#
# Env: DOTFILES_DIR (default ~/dotfiles), DOTFILES_BRANCH (default omarchy-quattro
# until it is merged to main), extra args are passed to install.sh.
#
set -euo pipefail

REPO="https://github.com/juanjodarko/dotfiles.git"
DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-omarchy-quattro}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mxx \033[0m %s\n' "$*" >&2; exit 1; }

command -v pacman >/dev/null || die "bootstrap.sh is for Arch Linux (on macOS use ./mac)"
[ "$(id -u)" -ne 0 ] || die "run as your user, not root (sudo is used where needed)"

log "Installing git + github-cli"
sudo pacman -S --needed --noconfirm git github-cli

if gh auth status >/dev/null 2>&1; then
  log "Already logged in to GitHub"
else
  log "GitHub login: on any device, open https://github.com/login/device and enter the code shown below"
  # No graphical session (fresh install, TTY): don't try to launch a browser —
  # GH_BROWSER=echo just prints the URL, and gh keeps polling for the code.
  [ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ] || export GH_BROWSER=echo
  # stdin from the terminal even when this script is piped from curl
  gh auth login --hostname github.com --git-protocol https --web </dev/tty
fi
# Credential helper + https rewrite go to ~/.config/git/config, NOT ~/.gitconfig:
# the `git` module stows ~/.gitconfig, and a real file there would block it.
xdg_git="$HOME/.config/git/config"; mkdir -p "$(dirname "$xdg_git")"
git config --file "$xdg_git" --replace-all credential.https://github.com.helper ''
git config --file "$xdg_git" --add credential.https://github.com.helper '!/usr/bin/gh auth git-credential'
git config --file "$xdg_git" url.https://github.com/.insteadOf git@github.com:

if [ -d "$DIR/.git" ]; then
  log "$DIR already exists — updating"
  git -C "$DIR" fetch -q origin
  git -C "$DIR" switch -q "$BRANCH"
  git -C "$DIR" pull -q --ff-only
else
  log "Cloning $REPO ($BRANCH) into $DIR"
  git clone -q -b "$BRANCH" "$REPO" "$DIR"
fi
log "Fetching submodules"
git -C "$DIR" submodule update --init --recursive --recommend-shallow

log "Running install.sh"
cd "$DIR"
exec ./install.sh "$@" </dev/tty
