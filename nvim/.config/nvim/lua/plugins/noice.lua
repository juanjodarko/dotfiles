return {
  "folke/noice.nvim",
  event = "VeryLazy",
  config = function()
    -- Set up Catppuccin colors for Noice after colorscheme loads
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "catppuccin*",
      callback = function()
        local colors = require("catppuccin.palettes").get_palette()

        -- Custom Noice highlights with Catppuccin colors
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = colors.surface0, fg = colors.text })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = colors.mauve })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = colors.sky, bold = true })
        vim.api.nvim_set_hl(0, "NoiceConfirm", { bg = colors.surface0, fg = colors.text })
        vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "NoiceMini", { bg = colors.mantle, fg = colors.text })

        -- Message history highlights
        vim.api.nvim_set_hl(0, "NoiceSplit", { bg = colors.base, fg = colors.text })
        vim.api.nvim_set_hl(0, "NoiceSplitBorder", { fg = colors.lavender })

        -- Command/search highlights
        vim.api.nvim_set_hl(0, "NoiceCmdline", { fg = colors.text })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { fg = colors.mauve, bold = true })

        -- LSP progress highlights
        vim.api.nvim_set_hl(0, "NoiceLspProgressTitle", { fg = colors.sky })
        vim.api.nvim_set_hl(0, "NoiceLspProgressClient", { fg = colors.peach })
        vim.api.nvim_set_hl(0, "NoiceLspProgressSpinner", { fg = colors.blue })

        -- Format highlights (icons in cmdline)
        vim.api.nvim_set_hl(0, "NoiceFormatProgressDone", { fg = colors.green })
        vim.api.nvim_set_hl(0, "NoiceFormatProgressTodo", { fg = colors.surface2 })

        -- Specific level highlights
        vim.api.nvim_set_hl(0, "NoiceFormatError", { fg = colors.red })
        vim.api.nvim_set_hl(0, "NoiceFormatWarn", { fg = colors.yellow })
        vim.api.nvim_set_hl(0, "NoiceFormatInfo", { fg = colors.blue })
        vim.api.nvim_set_hl(0, "NoiceFormatDebug", { fg = colors.overlay0 })
        vim.api.nvim_set_hl(0, "NoiceFormatTrace", { fg = colors.overlay1 })

        -- Completion highlights
        vim.api.nvim_set_hl(0, "NoiceCompletionItemKindDefault", { fg = colors.text })
        vim.api.nvim_set_hl(0, "NoiceCompletionItemMenu", { fg = colors.subtext0 })
      end,
    })

    -- Trigger it immediately if Catppuccin is already loaded
    if vim.g.colors_name and vim.g.colors_name:match("catppuccin") then
      vim.cmd("doautocmd ColorScheme " .. vim.g.colors_name)
    end

    require("noice").setup({
      -- ==========================================
      -- LSP CONFIGURATION
      -- ==========================================
      lsp = {
        -- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        -- LSP progress notifications
        progress = {
          enabled = true,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle = 1000 / 30, -- frequency to update lsp progress message
          view = "mini",
        },
        -- Hover documentation
        hover = {
          enabled = true,
          silent = false, -- set to true to not show a message if hover is not available
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        -- Signature help
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character
            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        -- LSP message handling
        message = {
          enabled = true,
          view = "notify",
          opts = {},
        },
        -- Defaults for hover and signature help
        documentation = {
          view = "hover",
          opts = {
            lang = "markdown",
            replace = true,
            render = "plain",
            format = { "{message}" },
            win_options = { concealcursor = "n", conceallevel = 3 },
          },
        },
      },

      -- ==========================================
      -- PRESETS
      -- ==========================================
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },

      -- ==========================================
      -- MESSAGE ROUTES
      -- ==========================================
      routes = {
        -- Filter out noise from yank/undo/redo operations
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
              { find = '%d fewer lines' },
              { find = '%d more lines' },
            },
          },
          opts = { skip = true },
        },

        -- Filter out "written" messages
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },

        -- Filter out search count messages (shown in statusline instead)
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },

        -- Send errors to notify for better visibility
        {
          filter = {
            event = "msg_show",
            kind = "emsg",
          },
          view = "notify",
          opts = {
            title = "Error",
            level = "error",
            merge = false,
          },
        },

        -- Send warnings to notify
        {
          filter = {
            event = "msg_show",
            kind = "wmsg",
          },
          view = "notify",
          opts = {
            title = "Warning",
            level = "warn",
          },
        },

        -- Route long messages to split
        {
          filter = {
            event = "msg_show",
            min_height = 10,
          },
          view = "split",
        },
      },

      -- ==========================================
      -- VIEW CONFIGURATION
      -- ==========================================
      views = {
        cmdline_popup = {
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
              FloatBorder = "FloatBorder",
              CursorLine = "PmenuSel",
              Search = "None",
            },
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = "60%",
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
              FloatBorder = "FloatBorder",
              CursorLine = "PmenuSel",
            },
          },
        },
        split = {
          backend = "split",
          relative = "editor",
          position = "bottom",
          size = "30%",
          close = {
            keys = { "q", "<Esc>" },
          },
          enter = true,
          buf_options = {
            filetype = "noice",
          },
          win_options = {
            winhighlight = {
              Normal = "Normal",
              FloatBorder = "FloatBorder",
              Search = "Search",
            },
          },
        },
        popup = {
          backend = "popup",
          relative = "editor",
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = "80%",
            height = "60%",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = "NormalFloat",
              FloatBorder = "FloatBorder",
              CursorLine = "PmenuSel",
            },
          },
        },
        mini = {
          backend = "mini",
          relative = "editor",
          align = "message-right",
          timeout = 2000,
          reverse = true,
          position = {
            row = -2,
            col = "100%",
          },
          size = "auto",
          border = {
            style = "none",
          },
          zindex = 60,
          win_options = {
            winblend = 0,
            winhighlight = {
              Normal = "NoiceMini",
              IncSearch = "",
              CurSearch = "",
              Search = "",
            },
          },
        },
      },

      -- ==========================================
      -- COMMAND LINE & MESSAGES
      -- ==========================================
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        opts = {},
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
          input = {},
        },
      },

      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },

      -- ==========================================
      -- NOTIFICATIONS
      -- ==========================================
      notify = {
        enabled = true,
        view = "notify",
      },

      -- ==========================================
      -- ADDITIONAL OPTIONS
      -- ==========================================
      popupmenu = {
        enabled = true,
        backend = "nui", -- backend to use to show regular cmdline completions
      },

      redirect = {
        view = "popup",
        filter = { event = "msg_show" },
      },

      commands = {
        history = {
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "" } },
              { event = "lsp", kind = "message" },
            },
          },
        },
        last = {
          view = "popup",
          opts = { enter = true, format = "details" },
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "" } },
              { event = "lsp", kind = "message" },
            },
          },
          filter_opts = { count = 1 },
        },
        errors = {
          view = "popup",
          opts = { enter = true, format = "details" },
          filter = { error = true },
          filter_opts = { reverse = true },
        },
      },

      -- ==========================================
      -- SMART HISTORY
      -- ==========================================
      smart_move = {
        enabled = true,
        excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
      },

      -- ==========================================
      -- THROTTLE
      -- ==========================================
      throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates?
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  keys = {
    { "<leader>nm", "<cmd>Noice history<cr>", desc = "Message History" },
    { "<leader>nl", "<cmd>Noice last<cr>", desc = "Last Message" },
    { "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Dismiss Notifications" },
    { "<leader>ne", "<cmd>Noice errors<cr>", desc = "Error Messages" },
  },
}
