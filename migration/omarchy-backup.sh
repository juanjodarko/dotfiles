#!/usr/bin/env bash
#
# omarchy-backup.sh — Week 1 / Step 1 of the Omarchy migration plan.
#
# Purpose: make a VERIFIED, restorable backup of this machine's irreplaceable
# state BEFORE any de-cruft deletion happens. "A backup you haven't restored
# from isn't a backup" — so this script has a `verify` mode that does a real
# test-restore and diffs it.
#
# Nothing here touches or deletes anything on your live system. It only reads
# your files and writes into a restic repository on an EXTERNAL drive.
#
# --------------------------------------------------------------------------
# USAGE
#   ./omarchy-backup.sh check           # environment + config sanity, no writes
#   ./omarchy-backup.sh dry-run         # show exactly what restic WOULD back up
#   ./omarchy-backup.sh run             # perform the backup (writes to $DEST)
#   ./omarchy-backup.sh verify          # test-restore a sample path + diff it
#   ./omarchy-backup.sh snapshots       # list snapshots in the repo
#
# TYPICAL FLOW
#   1. Plug in the external drive, note its mount path.
#   2. Edit the CONFIG block below (DEST + password file).
#   3. ./omarchy-backup.sh check
#   4. ./omarchy-backup.sh dry-run      # review the file set
#   5. ./omarchy-backup.sh run
#   6. ./omarchy-backup.sh verify       # <-- this is the gate the plan requires
# --------------------------------------------------------------------------

set -euo pipefail

# ==========================================================================
# CONFIG — edit these three things before running.
# ==========================================================================

# Where the restic repository lives. Point this at your mounted external drive.
# Example: /run/media/juanjo/BACKUP/omarchy-restic-repo
# Remote over SFTP also works, e.g. the Synology: sftp:homenas:/blade_backup/omarchy-restic-repo
DEST="${OMARCHY_BACKUP_DEST:-sftp:homenas:/blade_backup/omarchy-restic-repo}"

# Repository password. Create the file once with e.g.:
#   install -m600 <(head -c 32 /dev/urandom | base64) ~/.config/restic/omarchy-password
# and STORE A COPY SOMEWHERE SAFE (a lost password = an unrecoverable backup).
PASSWORD_FILE="${OMARCHY_BACKUP_PWFILE:-$HOME/.config/restic/omarchy-password}"

# Include the large media dirs? They may already live in Dropbox/Nextcloud/NAS.
#   1 = back them up (safest, but big: Pictures ~55G, Documents ~27G)
#   0 = skip them (assume they're replicated elsewhere)
INCLUDE_LARGE_MEDIA="${OMARCHY_INCLUDE_MEDIA:-1}"

# ==========================================================================
# WHAT GETS BACKED UP — the plan's path set, with real paths on this machine.
# Review this list; it is the "proposal" you approve. Comment lines out to skip.
# ==========================================================================
INCLUDE=(
  # -- the dotfiles repo itself (this very repo) --
  "$HOME/dotfiles"

  # -- irreplaceable secrets (tiny, most important) --
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/.password-store"
  "$HOME/.aws"
  "$HOME/.kube"
  "$HOME/.docker"
  "$HOME/.1password"          # local 1Password state (creds are in the cloud too)

  # -- user config + local app data (caches excluded below) --
  "$HOME/.config"
  "$HOME/.local/share"
  "$HOME/.local/bin"

  # -- browser profiles (bookmarks, history, logins; caches excluded below) --
  "$HOME/.mozilla"
  "$HOME/.config/google-chrome"
  "$HOME/.config/chromium"
  "$HOME/.config/BraveSoftware"

  # -- shells / tooling state worth keeping --
  "$HOME/.zsh_history"
  "$HOME/.oh-my-zsh"
  "$HOME/.tmux"
  "$HOME/.vim"

  # -- work / notes --
  "$HOME/zettelkasten"
  "$HOME/Snippets"
  "$HOME/workspace"
  "$HOME/go/src"             # source only; built artifacts excluded below
)

# Large media — appended only when INCLUDE_LARGE_MEDIA=1.
INCLUDE_MEDIA=(
  "$HOME/Pictures"
  "$HOME/Documents"
  "$HOME/Music"
  "$HOME/Videos"
)

# ==========================================================================
# WHAT GETS EXCLUDED — regenerable caches and huge reinstallable blobs.
# Each pattern is here on purpose; remove any you'd rather keep.
# ==========================================================================
EXCLUDES=(
  # generic caches / trash
  "$HOME/.cache"
  "**/.cache"
  "**/Cache"
  "**/Cache_Data"
  "**/Code Cache"
  "**/GPUCache"
  "**/ShaderCache"
  "**/CacheStorage"
  "**/Service Worker/CacheStorage"
  "$HOME/.local/share/Trash"
  "**/.Trash-*"
  "**/*.tmp"

  # thumbnails
  "$HOME/.thumbnails"
  "$HOME/.cache/thumbnails"

  # reinstallable game / container / VM blobs (huge)
  "$HOME/.steam"
  "$HOME/.local/share/Steam"
  "$HOME/.local/share/containers"
  "$HOME/.local/share/docker"
  "$HOME/.var/app/*/cache"
  "$HOME/.wine"
  "**/*.qcow2"
  "**/*.vdi"
  "**/*.vmdk"

  # language / package caches (reconstructible from lockfiles)
  "$HOME/.npm"
  "$HOME/.node-gyp"
  "$HOME/.nvm/.cache"
  "$HOME/.cargo/registry"
  "$HOME/.rustup/toolchains"
  "$HOME/.gradle/caches"
  "$HOME/.gem/ruby/*/cache"
  "$HOME/.m2/repository"
  "**/node_modules"
  "**/__pycache__"
  "**/*.pyc"
  "$HOME/go/pkg"
  "$HOME/go/bin"

  # cloud-sync working copies already replicated (their providers are the backup)
  "$HOME/Dropbox/.dropbox.cache"
  "$HOME/.dropbox-dist"

  # Docker container-owned DB volumes (postgres/mysql/redis) — unreadable as the user,
  # and raw live DB files are not a consistent backup anyway (use pg_dump/mysqldump if needed).
  "$HOME/workspace/amuebladostehuantepec.com.mx/data"
  "$HOME/workspace/amuebladostehuantepec.com.mx/database"
  "$HOME/workspace/basair6/database"
  "$HOME/workspace/codementor/tracking-app/database"
  "$HOME/workspace/courses/nestjs/database"
  "$HOME/workspace/courses/rapb/databse"
  "$HOME/workspace/courses/tcrordc/databse"
  "$HOME/workspace/doctorvital-back/doctorvital/database"
  "$HOME/workspace/emergencyqr.mx/database"
  "$HOME/workspace/evaluador/database"
  "$HOME/workspace/flow-tech-services/flow-postgres-12"
  "$HOME/workspace/flow-tech-services/pg12"
  "$HOME/workspace/juanjose/database"
  "$HOME/workspace/juanjose/database1"
  "$HOME/workspace/juanjose/redis/dump.rdb"
  "$HOME/workspace/kolau/database"
  "$HOME/workspace/kolau/database10"
  "$HOME/workspace/kolau/data/dump.rdb"
  "$HOME/workspace/kolau/dataOLD2/dump.rdb"
  "$HOME/workspace/kolau/new-db"
  "$HOME/workspace/pms/database"
  "$HOME/workspace/pons-card/database"
  "$HOME/workspace/realitat/database2"
  "$HOME/workspace/realitat/database-old-docker"
  "$HOME/workspace/runa/test/timechecker/database"
  "$HOME/workspace/runa/test/timechecker/tmp/ng-*"
  "$HOME/workspace/runa/timechecker/database"
  "$HOME/workspace/saas-evaluaciones/database"
  "$HOME/workspace/test-calendar/database"
  "$HOME/workspace/tests/timechecker/database"
  "$HOME/workspace/tierra_fracturada/database2"
  "$HOME/workspace/time-manager/database"
  "$HOME/workspace/time-manager/redis/dump.rdb"
  "$HOME/workspace/viviendas/database"
  "$HOME/workspace/viviendas/database-old-docker"
  "$HOME/workspace/viviendas/redis2/dump.rdb"
  "$HOME/workspace/viviendas/redis/dump.rdb"
)

# ==========================================================================
# Implementation — you shouldn't need to edit below here.
# ==========================================================================

export RESTIC_REPOSITORY="$DEST"
export RESTIC_PASSWORD_FILE="$PASSWORD_FILE"

HOSTTAG="$(uname -n 2>/dev/null || echo host)"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR="$SELF_DIR/manifests"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx \033[0m %s\n' "$*" >&2; exit 1; }

need_restic() {
  command -v restic >/dev/null 2>&1 || die \
"restic is not installed. Install it first:  sudo pacman -S restic
(reversible — you can 'sudo pacman -Rns restic' afterwards)."
}

refresh_manifests() {
  mkdir -p "$MANIFEST_DIR"
  if command -v pacman >/dev/null 2>&1; then
    pacman -Qqe > "$MANIFEST_DIR/pkglist-explicit.txt"
    pacman -Qqm > "$MANIFEST_DIR/pkglist-aur-foreign.txt"
    pacman -Qq  > "$MANIFEST_DIR/pkglist-all.txt"
    log "Refreshed package manifests in $MANIFEST_DIR"
  fi
}

build_include_list() {
  local f="$1"; : > "$f"
  local p
  for p in "${INCLUDE[@]}"; do [ -e "$p" ] && printf '%s\n' "$p" >> "$f"; done
  if [ "$INCLUDE_LARGE_MEDIA" = "1" ]; then
    for p in "${INCLUDE_MEDIA[@]}"; do [ -e "$p" ] && printf '%s\n' "$p" >> "$f"; done
  fi
}

build_exclude_list() {
  local f="$1"; : > "$f"
  printf '%s\n' "${EXCLUDES[@]}" >> "$f"
}

check_env() {
  need_restic
  log "restic:        $(restic version | head -1)"
  log "Repository:    $RESTIC_REPOSITORY"
  log "Password file: $RESTIC_PASSWORD_FILE"
  case "$DEST" in *CHANGE_ME*) die "DEST still points at CHANGE_ME — edit the CONFIG block first.";; esac
  [ -r "$PASSWORD_FILE" ] || die "Password file not readable: $PASSWORD_FILE (see CONFIG block for how to create it)."
  case "$DEST" in
    *:*) log "Remote repository backend — skipping local mount check." ;;
    *) local parent; parent="$(dirname "$DEST")"
       [ -d "$parent" ] || die "Backup destination parent does not exist: $parent — is the external drive mounted?" ;;
  esac
  log "Include large media: $([ "$INCLUDE_LARGE_MEDIA" = 1 ] && echo yes || echo no)"
  local inc; inc="$(mktemp)"; build_include_list "$inc"
  log "Paths that exist and will be backed up:"; sed 's/^/     /' "$inc"; rm -f "$inc"
  log "Environment looks OK."
}

ensure_repo() {
  if ! restic snapshots >/dev/null 2>&1; then
    log "No repository yet at $RESTIC_REPOSITORY — initializing."
    restic init
  fi
}

do_backup() {
  local dry="$1"
  check_env
  refresh_manifests
  ensure_repo
  local inc exc; inc="$(mktemp)"; exc="$(mktemp)"
  build_include_list "$inc"; build_exclude_list "$exc"
  local args=( backup --files-from "$inc" --exclude-file "$exc"
               --tag omarchy-migration --tag "host:$HOSTTAG"
               --one-file-system --exclude-caches )
  [ "$dry" = "1" ] && args+=( --dry-run --verbose )
  log "restic ${args[*]}"
  restic "${args[@]}"
  rm -f "$inc" "$exc"
  [ "$dry" = "1" ] || { log "Backup complete. Now VERIFY:  $0 verify"; }
}

do_verify() {
  check_env
  log "restic check (repository integrity)…"
  restic check
  # Pick a small, always-present path to test-restore: the ssh dir.
  local sample="$HOME/.ssh"
  local out; out="$(mktemp -d)"
  log "Test-restoring $sample into $out …"
  restic restore latest --target "$out" --include "$sample"
  log "Diffing restored copy against the live original…"
  if diff -rq "$sample" "$out$sample" ; then
    log "VERIFIED ✔  test-restore of $sample matches the original bit-for-bit."
    log "Backup is restorable. This satisfies the plan's Week-1 backup gate."
  else
    warn "Differences found between original and restored copy — investigate before trusting this backup."
  fi
  rm -rf "$out"
}

# Long runs must not be cut off by suspend: re-exec under a sleep/lid inhibitor.
case "${1:-}" in
  run|verify)
    if [ -z "${OMARCHY_BACKUP_INHIBITED:-}" ] && command -v systemd-inhibit >/dev/null 2>&1; then
      OMARCHY_BACKUP_INHIBITED=1 exec systemd-inhibit --what=sleep:idle:handle-lid-switch \
        --who=omarchy-backup --why="restic $1 in progress" "$0" "$@"
    fi ;;
esac

case "${1:-}" in
  check)     check_env ;;
  dry-run)   do_backup 1 ;;
  run)       do_backup 0 ;;
  verify)    do_verify ;;
  snapshots) check_env; restic snapshots ;;
  *) grep -E '^#( |$)' "$0" | sed -E 's/^# ?//' | sed -n '1,40p'; exit 1 ;;
esac
