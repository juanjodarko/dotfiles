# DAP (Debug Adapter Protocol) Usage Guide

Quick reference for debugging any project type from Neovim.

---

## Keybindings

All mappings use `<leader>d` prefix (leader = Space).

| Key            | Action                    | Mode     |
|----------------|---------------------------|----------|
| `<leader>db`   | Toggle breakpoint         | Normal   |
| `<leader>dB`   | Conditional breakpoint    | Normal   |
| `<leader>dc`   | Continue                  | Normal   |
| `<leader>di`   | Step into                 | Normal   |
| `<leader>do`   | Step over                 | Normal   |
| `<leader>dO`   | Step out                  | Normal   |
| `<leader>dr`   | Open REPL                 | Normal   |
| `<leader>dl`   | Run last                  | Normal   |
| `<leader>dt`   | Terminate                 | Normal   |
| `<leader>dh`   | Hover variable            | Normal/Visual |
| `<leader>dp`   | Preview                   | Normal/Visual |
| `<leader>df`   | Show frames (float)       | Normal   |
| `<leader>ds`   | Show scopes (float)       | Normal   |
| `<leader>du`   | Toggle DAP UI             | Normal   |
| `<leader>de`   | Eval expression           | Normal/Visual |

---

## Per-Framework Usage

### Rails / Ruby

**Prerequisites:**
- Add `gem "debug"` to your Gemfile (required by `rdbg`)
- `bundle install`

**Available configurations:**

| Name                    | What it does                                        |
|-------------------------|-----------------------------------------------------|
| Debug current file      | Runs the current `.rb` file via `bundle exec ruby`  |
| Debug RSpec (current file) | Runs current spec via `bundle exec rspec`        |
| Debug Rails server      | Starts `bundle exec rails server` under debugger    |
| Debug in Docker (attach)| Attaches to a running Docker container (auto-detected) |

**Breakpoints in code:** Use `debugger` or `binding.break` in your Ruby source.

**How it works:** The adapter spawns `bundle exec rdbg` which opens a debug port, then DAP attaches to it.

---

### Next.js

**Available configurations:**

| Name                     | What it does                                              |
|--------------------------|-----------------------------------------------------------|
| Debug Next.js (server)   | Runs `npm run dev` with Node inspector, server-side debug |
| Debug Next.js (client)   | Launches Chrome at `http://localhost:3000` for client-side debug |

**Source maps:** Both configs enable `sourceMaps = true`. The server config skips `node_internals` and `node_modules` to keep the call stack clean.

**Workflow:**
1. Set breakpoints in your page/API route
2. `<leader>dc` → pick "Debug Next.js (server)" for server-side code
3. For client-side React, pick "Debug Next.js (client)" — Chrome opens automatically
4. Breakpoints hit inline; use `<leader>dh` to inspect variables

---

### NestJS

**Prerequisites:**
- Your `package.json` must have a `start:debug` script (standard NestJS scaffold includes it):
  ```json
  "start:debug": "nest start --debug --watch"
  ```

**Configuration:** "Debug NestJS" — runs `npm run start:debug` with source maps enabled.

**How `outFiles` works:** DAP maps TypeScript source to compiled JS in `${workspaceFolder}/dist/**/*.js`. This is how breakpoints set in `.ts` files resolve to the running code.

---

### Jest / Vitest (Test Debugging)

| Name               | What it does                                             |
|--------------------|----------------------------------------------------------|
| Debug Jest Tests   | Runs Jest with `--runInBand` for sequential debugging    |
| Debug Vitest Tests | Runs Vitest with `--run` on the current file             |

Both use `pwa-node` adapter and run in the integrated terminal.

---

### Go

**Adapter:** Delve (`dlv dap`)

**Prerequisites:** Install Delve — `go install github.com/go-delve/delve/cmd/dlv@latest`

| Name                      | What it does                                |
|---------------------------|---------------------------------------------|
| Debug                     | Launch and debug the current `.go` file     |
| Debug test (go.mod)       | Debug tests in the current file's package   |
| Debug test (current file) | Debug tests in the current file only        |

---

### Python

**Adapter:** debugpy (installed via Mason)

**Prerequisites:** Mason installs debugpy automatically. No extra pip install needed.

| Name        | What it does                          |
|-------------|---------------------------------------|
| Launch file | Debug the current `.py` file          |

**Virtual environment auto-detection:** The config checks for `./venv/bin/python` and `./.venv/bin/python` in your project root. Falls back to `/usr/bin/python`.

---

## Docker Debugging

### How auto-detection works

When any DAP configuration loads, `project_utils.build_docker_dap_config()` checks for Docker Compose files in your project root:
- `docker-compose.yml`
- `compose.yml`
- `docker-compose.yaml`
- `compose.yaml`

If found, a "Debug in Docker (attach)" configuration is automatically added for the relevant language.

### Standard debug ports

| Language       | Port  | Protocol          |
|----------------|-------|-------------------|
| Ruby           | 38698 | rdbg              |
| JavaScript/TS  | 9229  | Node Inspector    |
| Go             | 2345  | Delve             |
| Python         | 5678  | debugpy           |

### Exposing ports in docker-compose

You need to expose the debug port in your `docker-compose.yml`:

```yaml
services:
  app:
    ports:
      - "38698:38698"  # Ruby debug
    # OR
    # - "9229:9229"    # Node.js debug
    # - "2345:2345"    # Go Delve
    # - "5678:5678"    # Python debugpy
```

### Path mapping

Docker configs automatically set up path mappings between your local project root and the container's `working_dir` (read from the compose file or Dockerfile `WORKDIR`, defaults to `/app`).

### Service detection

The auto-detector looks for these service names in order: the language hint (e.g., `"app"` for Ruby, `"frontend"` for JS/TS, `"api"` for Go, `"backend"` for Python), then `app`, `web`, `backend`, `api`, `server`, `frontend`.

---

## Project Overrides

Create a `.nvim.lua` file at your project root (also supports `.nvimrc.lua` or `.config/nvim.lua`) to customize DAP configs per project.

The file must return a table. DAP overrides go under the `dap` key:

### Example: Custom Ruby Docker config

```lua
-- .nvim.lua
return {
  dap = {
    ruby = {
      docker_config = {
        type = "ruby",
        name = "Debug Rails in Docker",
        request = "attach",
        localfs = false,
        host = "127.0.0.1",
        port = 38698,
        pathMappings = {
          {
            localRoot = vim.fn.getcwd(),
            remoteRoot = "/myapp",
          }
        },
      }
    }
  }
}
```

### Example: Custom Node.js Docker config

```lua
return {
  dap = {
    node = {
      docker_config = {
        type = "pwa-node",
        name = "Debug API in Docker",
        request = "attach",
        address = "localhost",
        port = 9229,
        localRoot = vim.fn.getcwd(),
        remoteRoot = "/usr/src/app",
        sourceMaps = true,
      }
    }
  }
}
```

### Example: Custom Go Docker config

```lua
return {
  dap = {
    go = {
      docker_config = {
        type = "delve",
        name = "Debug Go in Docker",
        mode = "remote",
        request = "attach",
        host = "127.0.0.1",
        port = 2345,
        substitutePath = {
          { from = vim.fn.getcwd(), to = "/go/src/app" }
        },
      }
    }
  }
}
```

### Example: Custom Python Docker config

```lua
return {
  dap = {
    python = {
      docker_config = {
        type = "python",
        name = "Debug Python in Docker",
        request = "attach",
        connect = { host = "localhost", port = 5678 },
        pathMappings = {
          { localRoot = vim.fn.getcwd(), remoteRoot = "/code" }
        },
      }
    }
  }
}
```

When a project override exists for a language, it **replaces** the auto-detected Docker config (but local configs like "Debug current file" remain).

---

## DAP UI Layout

The UI opens automatically when a debug session starts and closes when it terminates.

```
┌──────────────────────────────────────────────────────────┐
│  Left Panel (40 cols)  │         Editor                  │
│  ┌──────────────────┐  │                                 │
│  │ Scopes    (25%)  │  │   ← your code with breakpoints  │
│  │ Breakpoints(25%) │  │                                 │
│  │ Stacks    (25%)  │  │                                 │
│  │ Watches   (25%)  │  │                                 │
│  └──────────────────┘  │                                 │
├──────────────────────────────────────────────────────────┤
│  Bottom Panel (10 rows)                                  │
│  ┌─────────────────────┬─────────────────────┐           │
│  │ REPL (50%)          │ Console (50%)       │           │
│  └─────────────────────┴─────────────────────┘           │
└──────────────────────────────────────────────────────────┘
```

**UI element mappings (inside DAP UI panels):**
- `<CR>` or double-click — expand/collapse
- `o` — open
- `d` — remove
- `e` — edit
- `r` — REPL
- `t` — toggle

**Floating windows** (e.g., from `<leader>dh` hover): close with `q` or `<Esc>`.

**Virtual text:** Variable values display inline at end of line while debugging.

---

## Troubleshooting

### Check adapter installation
Run `:Mason` and verify these are installed:
- `js-debug-adapter` — for JavaScript/TypeScript/Next.js/NestJS
- `debugpy` — for Python

Go (Delve) and Ruby (`rdbg`) are not managed by Mason — install them via their respective toolchains.

### Enable trace logging
```vim
:lua require("dap").set_log_level("TRACE")
```
Log file location: `~/.local/state/nvim/dap.log`

### Common issues

| Problem | Solution |
|---------|----------|
| Breakpoints not hitting | Check source maps are enabled; verify paths match between local and container |
| "Could not connect" in Docker | Ensure the debug port is exposed in docker-compose and the debugger is actually listening |
| Ruby adapter fails | Run `bundle exec rdbg --version` to verify installation |
| NestJS breakpoints in wrong file | Check `outFiles` points to your actual `dist/` directory |
| Python wrong interpreter | Create a `venv` or `.venv` directory in project root, or use a `.nvim.lua` override |
| Go "dlv not found" | Ensure `$GOPATH/bin` is in your PATH |
| DAP UI doesn't open | Run `<leader>du` to toggle manually; check `:messages` for errors |
