return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true, example = "doom" },
    indent = { enabled = true, char = "|" },
    lazygit = {
      enabled = true,
      configure = true,
    },
    picker = { enabled = false },
    notifier = { enabled = true, timeout = 10000 },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      {
        width = 0.6,
        height = 0.6,
        border = "rounded",
        title = " Git Blame ",
        title_pos = "center",
        ft = "git",
      }
    }
  },
  keys = {
    -- Core Lazygit interface
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },

    -- File history
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit: File history (current)" },

    -- Repository log
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit: Log (repo)" },

    -- Commits
    { "<leader>gc", function()
      -- Show commits for current file
      Snacks.lazygit.log_file()
    end, desc = "Lazygit: Commits (current file)" },

    { "<leader>gC", function()
      -- Show all commits in repo
      Snacks.lazygit.log()
    end, desc = "Lazygit: Commits (entire repo)" },

    -- Blame
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git: Blame line" },

    -- Browse (open in GitHub/GitLab)
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git: Browse (GitHub/GitLab)" },

    -- Terminal
    { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    {
      "<leader>N",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          }
        })
      end,
    }
  },
  init = function()
    Snacks = require("snacks")
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end
    })
  end
}
