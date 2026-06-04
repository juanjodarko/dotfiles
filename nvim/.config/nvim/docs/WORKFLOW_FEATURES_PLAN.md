# Workflow Features — Implementation Plan

Three features to build, in priority order. Derived from the workflow-reshape grilling
session. Cleanup removals (avante, pomodoro, goto-preview, markdown-preview, diagram,
image, stale docs) are already done; this covers what's left to **add**.

Workflow axes these serve:
- **Claude sessions across tmux** → Feature 1 (session tracker)
- **Reviewing tickets on GitLab** → Feature 2 (gitlab.nvim)
- **Standup / memory in Obsidian** → Feature 3 (standup command)

---

## Feature 1 — Claude session tracker (the meaty one)

**Goal:** From inside Neovim, see every Claude Code session running in other tmux panes,
with a visual/animated cue when one is **waiting for my input**, and a Telescope picker to
**jump straight to that pane**.

**Spans two repos:**
- `~/workspace/claude-collab` — the Lua modules (it already owns a lualine statusline
  component and is the agreed home for this).
- `dotfiles` — hook config, keymaps, lualine wiring.

### 1a. The status-dir contract (the seam)

The producer of session state is a **Claude Code hook today**, swappable for the
**metadata-filesystem project later**. Neovim only ever reads this directory — keep the
contract stable and both sides stay decoupled.

```
Location:  $XDG_STATE_HOME/claude-sessions/   (fallback ~/.local/state/claude-sessions/)
One file per session, named <session_id>.json:

{
  "id":           "<claude session id>",
  "pane":         "%17",            // $TMUX_PANE at session start
  "session":      "work",           // tmux session name
  "window":       "3",              // tmux window index
  "cwd":          "/home/juanjo/projects/app",
  "title":        "fix auth bug",   // optional: first prompt / summary
  "state":        "waiting",        // working | waiting | idle | done
  "updated_at":   1733300000
}
```

State transitions (which hook sets what):
| Hook event         | state     | meaning                                  |
|--------------------|-----------|------------------------------------------|
| `SessionStart`     | `working` | session began; capture pane/cwd/id       |
| `UserPromptSubmit` | `working` | actively processing                      |
| `Notification`     | `waiting` | **needs my input / permission** (the cue)|
| `Stop`             | `idle`    | finished responding, awaiting next prompt|
| `SessionEnd`       | (delete)  | remove the file                          |

### 1b. The hook (producer, dotfiles side)

Add a small writer script + register it in Claude Code settings (`~/.claude/settings.json`).
Hooks receive a JSON payload on stdin (includes `session_id`, `cwd`); `$TMUX_PANE` is in env.

- Script: `~/.claude/hooks/session-status.sh <state>` — reads stdin JSON, merges with
  `$TMUX_PANE` / `tmux display-message -p` for session/window, writes/updates the JSON file.
  On `SessionEnd`, `rm` the file.
- Register `SessionStart`, `UserPromptSubmit`, `Notification`, `Stop`, `SessionEnd` → call
  the script with the matching state arg.
- Use the **update-config skill** to edit `~/.claude/settings.json` safely.

> Note: this is the "simple way to hook it" you asked for. When the metadata-fs project
> lands, point Neovim at its directory/socket instead — no nvim changes needed if it emits
> the same schema.

### 1c. Neovim consumer (`claude-collab` repo)

New module `lua/claude-collab/sessions.lua`:
- `scan()` → read all JSON in the status dir; cross-check liveness with
  `tmux list-panes -a -F '#{pane_id} #{session_name} #{window_index} #{pane_current_command} #{pane_current_path}'`
  (drop stale files whose pane is gone or no longer running `claude`).
- `jump(entry)` → `tmux switch-client -t <session>` ; `select-window -t <window>` ;
  `select-pane -t <pane>`. (If nvim itself is inside tmux, this moves focus to the pane.)
- `pick()` → Telescope picker (you already depend on telescope): each row shows a state
  icon (⚙ working / ⏳ waiting / ✓ idle), cwd basename, and title; `<CR>` = jump,
  `<C-d>` = delete stale entry.
- `watch()` → `vim.uv.new_fs_event()` on the status dir; on change, recompute
  `has_waiting` and refresh the statusline; fire one `nvim-notify` ping (via noice) when a
  session **transitions into** `waiting`.

Extend `lua/claude-collab/statusline.lua`:
- Add a component segment: if any session is `waiting`, render an animated spinner
  (cycle frames on a timer) + count, e.g. `⏳2`. Reuse the existing lualine hook in
  `dotfiles/.../lualine.lua` (already wired to `claude-collab.statusline`).

### 1d. Keymaps (dotfiles, `claude-collab.lua` spec `keys`)
- `<leader>cj` → `require('claude-collab.sessions').pick()` — "Claude: jump to session"
- (optional) `<leader>cJ` → focus the next `waiting` session directly.
> Verify no collision in the `<leader>c` group (claudecode uses cc/cf/cr/cC/cm/cb/cs/cS/ca/cd;
> collab uses cw/ci/cp/cP — `cj`/`cJ` are free).

### 1e. Build order
1. Define schema + write the hook script; confirm files appear/update/delete as you use Claude.
2. `sessions.scan()` + Telescope `pick()` + `jump()` — get the picker working.
3. `watch()` + statusline spinner + notify — the "waiting" cue.
4. Later: repoint the producer at the metadata-fs.

---

## Feature 2 — GitLab in-editor (company tasks/MRs)

**Plugin:** `harrisoncramer/gitlab.nvim` (MR review/approve/comment/discussions — mirrors
octo's GitHub flow). Reuses `diffview` (already installed) for the review diff.

### 2a. Plugin spec — `lua/plugins/gitlab.lua`
- Dependencies: `nvim-lua/plenary.nvim`, `sindrets/diffview.nvim` (have it),
  `stevearc/dressing.nvim` (optional — was an avante dep, now removed; add back small),
  `nvim-tree/nvim-web-devicons`.
- `build = function() require("gitlab.server").build(true) end` — **compiles a Go binary**
  (needs Go toolchain installed: `pacman -S go`).
- Auth: reads `GITLAB_TOKEN` (and `GITLAB_URL` for self-hosted company instance) from env,
  or a `.gitlab.nvim` file per project. Put the company instance URL + a PAT with `api`
  scope in your shell profile / a sourced secrets file (do **not** commit the token).

### 2b. Keymaps — new `<leader>l` group ("GitLab")
`<leader>l` is free at top level. Mirror octo semantics:
- `<leader>lr` review (start), `<leader>la` approve, `<leader>lc` create comment,
  `<leader>ls` suggestion, `<leader>lA` add assignee, `<leader>lm` summary/open MR,
  `]t`/`[t` discussion threads (gitlab.nvim provides its own).
- Add `{ "<leader>l", group = "GitLab (MRs)" }` to `which-key.lua` spec.

### 2c. Notes
- GitHub stays on octo (`<leader>o…`) for repo analysis; GitLab on `<leader>l…` for company
  work — clean separation, no key clobbering.
- gitlab.nvim only activates inside a repo whose remote is the GitLab instance; harmless
  elsewhere (lazy-load on `:GitlabReview`-style cmds or on `BufReadPre` gated by remote).

---

## Feature 3 — Standup command → Obsidian (semi-auto)

**Goal:** One command gathers what I worked on today and appends a formatted entry to
today's Obsidian daily note. Obsidian = memory system, so this writes *history*, not tasks.

### 3a. Module — `lua/user/standup.lua` (dotfiles)
Gather sources:
- **Git:** today's commits by me across the current repo —
  `git log --since=00:00 --author="<your email>" --pretty='- %s (%h)'`; plus branches
  touched today. (Optionally loop over a known projects dir for a cross-repo roll-up.)
- **Sessions (later):** read session titles/summaries from the metadata-fs (or the
  status dir's `title` fields) to list what Claude worked on.

Format + write:
- Resolve today's note path used by obsidian.nvim:
  `~/Documents/obsidian-notes/1.Projects/0.Dailies/YYYY-MM-DD-<Day>.md`
  (matches the existing `<leader>oo` daily-note convention).
- Ensure a `## Standup` heading exists; append the gathered bullets under it (idempotent —
  re-running replaces the day's block rather than duplicating).

### 3b. Command + keymap
- `:Standup` user command → `require('user.standup').run()`.
- `<leader>oS` → "Standup: log today's work" (Obsidian group; `oS` is free).
- Register `require('user.standup')` from `init.lua` alongside the other `user.*` modules.

### 3c. Build order
1. Git-only roll-up for the current repo → append to today's note. Ship this first.
2. Cross-repo roll-up (iterate a projects dir).
3. Fold in Claude session summaries once the metadata-fs exists.

---

## Cross-cutting prerequisites
- **Go toolchain** for gitlab.nvim (`go version`).
- **dressing.nvim** re-added as a small standalone dep (it left with avante; gitlab.nvim
  and generic `vim.ui.select` prompts benefit).
- **update-config skill** for the Claude Code hook registration in `~/.claude/settings.json`.
- Keep the **status-dir schema** the single source of truth shared by hook → nvim →
  metadata-fs.
