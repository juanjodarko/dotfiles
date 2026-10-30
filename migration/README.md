# Omarchy migration tooling

Working area for the move to **Omarchy 4 ("Quattro")**. Tracks the plan in
`../omarchy-migration-plan.html`. Nothing here touches the live system without
you running it deliberately.

## Contents

- `omarchy-backup.sh` — **Week 1 / Step 1.** Verified restic backup of
  irreplaceable state, with a real test-restore (`verify`) that satisfies the
  plan's "backup exists and is restorable" gate. Run `./omarchy-backup.sh` with
  no args for usage.
- `manifests/` — package lists captured 2026-08-24 so the system is
  reproducible from bare metal:
  - `pkglist-explicit.txt` — explicitly installed (231)
  - `pkglist-aur-foreign.txt` — AUR / foreign (54)
  - `pkglist-all.txt` — everything (1376)
  Restore later with: `pacman -S --needed - < pkglist-explicit.txt`
  (rebuild AUR ones with your helper).

## Backup: before you run it

1. `sudo pacman -S restic` (reversible).
2. Plug in an external drive with room for the set you choose
   (full set here is ~150 GB+; skip large media with `INCLUDE_LARGE_MEDIA=0`
   if Pictures/Documents already live in Dropbox/Nextcloud/NAS).
3. Create a repo password and **keep a copy somewhere safe** — a lost password
   is an unrecoverable backup:
   ```
   mkdir -p ~/.config/restic
   install -m600 <(head -c 32 /dev/urandom | base64) ~/.config/restic/omarchy-password
   ```
4. Edit the `CONFIG` block at the top of `omarchy-backup.sh` (`DEST`).
5. `./omarchy-backup.sh check` → `dry-run` → `run` → **`verify`**.

The include/exclude lists in the script are the *proposal* — review them as a
diff and comment out anything you disagree with before running.

## Status

- [x] Package manifests captured
- [x] Backup + verify script prepared
- [x] restic installed
- [x] Backup run → Synology `HomeNAS` (sftp:homenas:/blade_backup/omarchy-restic-repo), snapshot `425fd5d3`, 2026-10-30
- [x] **Test-restore verified** 2026-10-30 (`restic check` clean + ~/.ssh restore diff identical) ← the gate
- [ ] `pre-omarchy-2026` tag pushed
- [ ] `cleanup` branch (de-cruft, per-item approval)
