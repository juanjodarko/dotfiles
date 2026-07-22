return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",

    -- Test adapters
    "nvim-neotest/neotest-vim-test", -- Backward compatibility with vim-test
    "olimorris/neotest-rspec", -- Ruby/Rails RSpec
    "nvim-neotest/neotest-jest", -- JavaScript/TypeScript Jest
    "marilari88/neotest-vitest", -- JavaScript/TypeScript Vitest
    "nvim-neotest/neotest-go", -- Go
    "nvim-neotest/neotest-python", -- Python pytest
  },
  config = function()
    local neotest = require("neotest")
    local project_utils = require("user.project_utils")
    local project_config = project_utils.get_project_config()

    -- Load project-specific Neotest overrides from .nvim.lua
    local neotest_overrides = {}
    if project_config.neotest then
      neotest_overrides = project_config.neotest
    end

    -- Build adapters based on project type
    local adapters = {}

    -- Ruby/Rails: RSpec
    if project_config.is_ruby or project_config.is_rails then
      table.insert(adapters, require("neotest-rspec")({
        rspec_cmd = function()
          -- 1. Check for project override
          if neotest_overrides.rspec and neotest_overrides.rspec.rspec_cmd then
            local override = neotest_overrides.rspec.rspec_cmd
            return type(override) == "function" and override() or override
          end

          -- 2. Auto-detect Docker Compose
          local base_cmd = {"bundle", "exec", "rspec"}
          return project_utils.build_docker_test_command(base_cmd, "app")
        end,
      }))
    end

    -- JavaScript/TypeScript: Jest or Vitest
    if project_config.is_javascript or project_config.is_typescript or project_config.is_react or project_config.is_nodejs then
      -- Check if project uses Vitest
      local package_json_path = project_config.root_dir .. "/package.json"
      if vim.fn.filereadable(package_json_path) == 1 then
        local package_json = vim.fn.readfile(package_json_path)
        local json_str = table.concat(package_json, "\n")

        if string.find(json_str, '"vitest"') then
          -- Vitest configuration
          local vitest_config = {}

          -- 1. Check for project override
          if neotest_overrides.vitest and neotest_overrides.vitest.vitestCommand then
            vitest_config.vitestCommand = neotest_overrides.vitest.vitestCommand
          else
            -- 2. Auto-detect Docker Compose
            vitest_config.vitestCommand = function()
              local base_cmd = {"npx", "vitest"}
              local docker_cmd = project_utils.build_docker_test_command(base_cmd, "frontend")
              return table.concat(docker_cmd, " ")
            end
          end

          table.insert(adapters, require("neotest-vitest")(vitest_config))
        else
          -- Jest configuration
          local jest_config = {
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }

          -- 1. Check for project override
          if neotest_overrides.jest and neotest_overrides.jest.jestCommand then
            local override = neotest_overrides.jest.jestCommand
            jest_config.jestCommand = type(override) == "function" and override() or override
          else
            -- 2. Auto-detect Docker Compose
            jest_config.jestCommand = function()
              local base_cmd = {"npm", "test", "--"}
              local docker_cmd = project_utils.build_docker_test_command(base_cmd, "frontend")
              return table.concat(docker_cmd, " ")
            end
          end

          table.insert(adapters, require("neotest-jest")(jest_config))
        end
      end
    end

    -- Go: go test
    if project_config.is_go then
      local go_config = {}

      -- 1. Check for project override
      if neotest_overrides.go then
        go_config = vim.tbl_deep_extend("force", go_config, neotest_overrides.go)
      else
        -- 2. Auto-detect Docker Compose
        local has_docker = project_utils.has_docker_compose()
        if has_docker then
          go_config.args = function()
            local service = project_utils.detect_docker_service("api")
            return {
              "-exec",
              string.format("docker compose run --rm %s go test", service),
            }
          end
        end
      end

      table.insert(adapters, require("neotest-go")(go_config))
    end

    -- Python: pytest
    if project_config.is_python then
      local python_config = {
        dap = { justMyCode = false },
        args = { "--log-level", "DEBUG", "--quiet" },
        runner = "pytest",
      }

      -- 1. Check for project override
      if neotest_overrides.python then
        python_config = vim.tbl_deep_extend("force", python_config, neotest_overrides.python)
      else
        -- 2. Auto-detect Docker Compose
        local has_docker = project_utils.has_docker_compose()
        if has_docker then
          python_config.python = function()
            local service = project_utils.detect_docker_service("backend")
            return string.format("docker compose run --rm %s python", service)
          end
        end
      end

      table.insert(adapters, require("neotest-python")(python_config))
    end

    -- Fallback: vim-test adapter for unsupported test frameworks
    table.insert(adapters, require("neotest-vim-test")({
      ignore_file_types = { "python", "vim", "lua", "javascript", "typescript", "ruby", "go" },
    }))

    neotest.setup({
      adapters = adapters,
      status = {
        enabled = true,
        virtual_text = true,
        signs = true,
      },
      icons = {
        passed = "",
        running = "",
        failed = "",
        skipped = "",
        unknown = "",
        watching = "",
      },
      floating = {
        border = "rounded",
        max_height = 0.8,
        max_width = 0.9,
        options = {},
      },
      highlights = {
        adapter_name = "NeotestAdapterName",
        border = "NeotestBorder",
        dir = "NeotestDir",
        expand_marker = "NeotestExpandMarker",
        failed = "NeotestFailed",
        file = "NeotestFile",
        focused = "NeotestFocused",
        indent = "NeotestIndent",
        marked = "NeotestMarked",
        namespace = "NeotestNamespace",
        passed = "NeotestPassed",
        running = "NeotestRunning",
        select_win = "NeotestWinSelect",
        skipped = "NeotestSkipped",
        target = "NeotestTarget",
        test = "NeotestTest",
        unknown = "NeotestUnknown",
        watching = "NeotestWatching",
      },
      output = {
        enabled = true,
        open_on_run = "short", -- "short" shows output for failed tests only
      },
      output_panel = {
        enabled = true,
        open = "botright split | resize 15",
      },
      quickfix = {
        enabled = true,
        open = false, -- Don't auto-open quickfix
      },
      run = {
        enabled = true,
      },
      running = {
        concurrent = true,
      },
      summary = {
        enabled = true,
        animated = true,
        follow = true,
        expand_errors = true,
        open = "botright vsplit | vertical resize 50",
        mappings = {
          attach = "a",
          clear_marked = "M",
          clear_target = "T",
          debug = "d",
          debug_marked = "D",
          expand = { "<CR>", "<2-LeftMouse>" },
          expand_all = "e",
          jumpto = "i",
          mark = "m",
          next_failed = "J",
          output = "o",
          prev_failed = "K",
          run = "r",
          run_marked = "R",
          short = "O",
          stop = "u",
          target = "t",
          watch = "w",
        },
      },
      watch = {
        enabled = true,
        symbol_queries = {
          ruby = [[
            (method) @symbol
            (class) @symbol
            (module) @symbol
          ]],
          javascript = [[
            (function_declaration) @symbol
            (method_definition) @symbol
            (arrow_function) @symbol
          ]],
          typescript = [[
            (function_declaration) @symbol
            (method_definition) @symbol
            (arrow_function) @symbol
          ]],
          go = [[
            (function_declaration) @symbol
            (method_declaration) @symbol
          ]],
        },
      },
    })
  end,
  keys = {
    {
      "<leader>tr",
      function()
        require("neotest").run.run()
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run current file",
    },
    {
      "<leader>td",
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Debug nearest test",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle test summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open({ enter = true })
      end,
      desc = "Show test output",
    },
    {
      "<leader>tO",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Toggle output panel",
    },
    {
      "<leader>tS",
      function()
        require("neotest").run.stop()
      end,
      desc = "Stop test",
    },
    {
      "<leader>tw",
      function()
        require("neotest").watch.toggle(vim.fn.expand("%"))
      end,
      desc = "Toggle watch mode",
    },
  },
}
