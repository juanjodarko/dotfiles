return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local project_utils = require("user.project_utils")
    local project_config = project_utils.get_project_config()

    -- ===========================================
    -- DAP ICONS & SIGNS
    -- ===========================================
    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticOk", linehl = "debugPC", numhl = "" })

    -- ===========================================
    -- VIRTUAL TEXT CONFIGURATION
    -- ===========================================
    require("nvim-dap-virtual-text").setup({
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      show_stop_reason = true,
      commented = false,
      only_first_definition = true,
      all_references = false,
      display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == 'inline' then
          return ' = ' .. variable.value
        else
          return variable.name .. ' = ' .. variable.value
        end
      end,
      virt_text_pos = "eol", -- position: 'eol' | 'overlay' | 'right_align' | 'inline'
    })

    -- ===========================================
    -- RUBY/RAILS DEBUGGER
    -- ===========================================
    -- Install: gem install debug
    -- Usage: Add `debugger` or `binding.break` to your Ruby code
    dap.adapters.ruby = function(callback, config)
      callback({
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "bundle",
          args = {
            "exec",
            "rdbg",
            "-n",
            "--open",
            "--port",
            "${port}",
            "-c",
            "--",
            "bundle",
            "exec",
            config.command,
            config.script,
          },
        },
      })
    end

    -- Ruby configurations with smart Docker detection
    local ruby_configs = {
      {
        type = "ruby",
        name = "Debug current file",
        request = "attach",
        localfs = true,
        command = "ruby",
        script = "${file}",
      },
      {
        type = "ruby",
        name = "Debug RSpec (current file)",
        request = "attach",
        localfs = true,
        command = "rspec",
        script = "${file}",
      },
      {
        type = "ruby",
        name = "Debug Rails server",
        request = "attach",
        localfs = true,
        command = "rails",
        script = "server",
      },
    }

    -- Add Docker configuration if available
    -- 1. Check for project override
    local ruby_docker_override = nil
    if project_config.dap and project_config.dap.ruby and project_config.dap.ruby.docker_config then
      ruby_docker_override = project_config.dap.ruby.docker_config
    end

    -- 2. Auto-detect Docker Compose
    if ruby_docker_override then
      table.insert(ruby_configs, ruby_docker_override)
    else
      local docker_config = project_utils.build_docker_dap_config("ruby", "app")
      if docker_config then
        table.insert(ruby_configs, docker_config)
      end
    end

    dap.configurations.ruby = ruby_configs

    -- ===========================================
    -- JAVASCRIPT/TYPESCRIPT DEBUGGER
    -- ===========================================
    -- Install: Mason will install node-debug2-adapter
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        args = {
          require("mason-registry").get_package("js-debug-adapter"):get_install_path()
            .. "/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }

    local js_based_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

    -- Build JavaScript/TypeScript configurations with smart Docker detection
    for _, language in ipairs(js_based_languages) do
      local js_configs = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Jest Tests",
          -- trace = true, -- include debugger info
          runtimeExecutable = "node",
          runtimeArgs = {
            "./node_modules/jest/bin/jest.js",
            "--runInBand",
          },
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Vitest Tests",
          runtimeExecutable = "node",
          runtimeArgs = {
            "./node_modules/vitest/vitest.mjs",
            "--run",
            "${file}",
          },
          rootPath = "${workspaceFolder}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
      }

      -- Add Docker configuration if available
      -- 1. Check for project override
      local js_docker_override = nil
      if project_config.dap and project_config.dap.node and project_config.dap.node.docker_config then
        js_docker_override = project_config.dap.node.docker_config
      end

      -- 2. Auto-detect Docker Compose
      if js_docker_override then
        table.insert(js_configs, js_docker_override)
      else
        local docker_config = project_utils.build_docker_dap_config(language, "frontend")
        if docker_config then
          table.insert(js_configs, docker_config)
        end
      end

      dap.configurations[language] = js_configs
    end

    -- ===========================================
    -- GO DEBUGGER (Delve)
    -- ===========================================
    -- Install: go install github.com/go-delve/delve/cmd/dlv@latest
    dap.adapters.delve = {
      type = "server",
      port = "${port}",
      executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}" },
      },
    }

    -- Go configurations with smart Docker detection
    local go_configs = {
      {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}",
      },
      {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
      },
      {
        type = "delve",
        name = "Debug test (current file)",
        request = "launch",
        mode = "test",
        program = "${file}",
      },
    }

    -- Add Docker configuration if available
    -- 1. Check for project override
    local go_docker_override = nil
    if project_config.dap and project_config.dap.go and project_config.dap.go.docker_config then
      go_docker_override = project_config.dap.go.docker_config
    end

    -- 2. Auto-detect Docker Compose
    if go_docker_override then
      table.insert(go_configs, go_docker_override)
    else
      local docker_config = project_utils.build_docker_dap_config("go", "api")
      if docker_config then
        table.insert(go_configs, docker_config)
      end
    end

    dap.configurations.go = go_configs

    -- ===========================================
    -- PYTHON DEBUGGER
    -- ===========================================
    -- Install: Mason will install debugpy
    dap.adapters.python = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
      args = { "-m", "debugpy.adapter" },
    }

    -- Python configurations with smart Docker detection
    local python_configs = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
            return cwd .. "/venv/bin/python"
          elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
            return cwd .. "/.venv/bin/python"
          else
            return "/usr/bin/python"
          end
        end,
      },
    }

    -- Add Docker configuration if available
    -- 1. Check for project override
    local python_docker_override = nil
    if project_config.dap and project_config.dap.python and project_config.dap.python.docker_config then
      python_docker_override = project_config.dap.python.docker_config
    end

    -- 2. Auto-detect Docker Compose
    if python_docker_override then
      table.insert(python_configs, python_docker_override)
    else
      local docker_config = project_utils.build_docker_dap_config("python", "backend")
      if docker_config then
        table.insert(python_configs, docker_config)
      end
    end

    dap.configurations.python = python_configs
  end,
  keys = {
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Set conditional breakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continue",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "Step into",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Step over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Step out",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.open()
      end,
      desc = "Open REPL",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "Run last",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "Terminate",
    },
    {
      "<leader>dh",
      function()
        require("dap.ui.widgets").hover()
      end,
      desc = "Hover",
      mode = { "n", "v" },
    },
    {
      "<leader>dp",
      function()
        require("dap.ui.widgets").preview()
      end,
      desc = "Preview",
      mode = { "n", "v" },
    },
    {
      "<leader>df",
      function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
      end,
      desc = "Frames",
    },
    {
      "<leader>ds",
      function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end,
      desc = "Scopes",
    },
  },
}
