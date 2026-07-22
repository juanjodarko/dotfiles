# Repository Guidelines

## Project Structure & Module Organization

This is a Lua-based Neovim configuration. `init.lua` is the entrypoint and loads user settings, keymaps, Lazy.nvim, LSP, and Mason setup. Core modules live in `lua/user/`; plugin specs live in `lua/plugins/`, usually one file per plugin or feature. Shared bootstrapping and tool setup live in `lua/config/`. Root Markdown files such as `README.md`, `WORKFLOW.md`, and `DAP_GUIDE.md` contain operating notes. `lazy-lock.json` pins plugin versions and should change only when plugin updates are intentional.

## Build, Test, and Development Commands

- `nvim`: open Neovim with this config; Lazy.nvim bootstraps automatically if missing.
- `nvim --headless "+Lazy! sync" +qa`: install or update plugins and refresh `lazy-lock.json`.
- `nvim --headless "+checkhealth" +qa`: run provider, plugin, LSP, and tool health checks.
- `:Lazy`, `:Mason`, `:ConformInfo`: inspect plugin, language server, and formatter state inside Neovim.

There is no separate build step; changes are loaded by restarting Neovim or sourcing `init.lua`.

## Coding Style & Naming Conventions

Use Lua modules returning tables for plugin specs and named modules under `lua/user/` for reusable behavior. Prefer one plugin spec per file, named after the plugin or feature, for example `lua/plugins/telescope.lua`. Use two-space indentation, matching `vim.opt.shiftwidth = 2`. Prefer the quote style already present in the edited file. Keep keymap descriptions short and action-oriented.

## Testing Guidelines

This config has no repository-level automated test suite. Validate edits by launching Neovim, running `:checkhealth`, and exercising the affected feature directly. For plugin changes, run `:Lazy reload <plugin>` or restart Neovim and confirm there are no startup errors. For LSP, formatter, or debugger changes, test in a real project file for the target language. Neotest supports opened project tests for Ruby, JavaScript/TypeScript, Go, and Python.

## Commit & Pull Request Guidelines

Recent history uses short, informal summaries such as `configuration` and `updatecreds`. Keep new commits concise but clearer when possible, for example `update telescope keymaps` or `add python neotest defaults`. Pull requests should describe the affected workflow, list manual validation, and call out changes to `lazy-lock.json`, LSP tooling, or external dependencies. Include screenshots only for visible UI changes.

## Agent-Specific Instructions

Keep edits scoped to the requested feature or plugin. Do not reorder unrelated plugin specs or reformat large files casually. Preserve user-local assumptions, especially machine-specific paths, project overrides, and experimental plugin files.
