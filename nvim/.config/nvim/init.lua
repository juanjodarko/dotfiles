vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require('user.settings')
require('user.keymaps')
--require('user.plugins')
--require('user.misc')
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  uv.fs_mkdir(lazypath, 511)
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1,
    config = function()
      require("catppuccin").setup({
        --highlight_overrides = {
        --  mocha = function(mocha)
        --    return {
        --      Comment = { fg = mocha.flamingo },
        --    }
        --  end,
        --},
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = true,
        show_end_of_buffer = false, -- show the '~' characters after the end of buffers
        term_colors = false,
        dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            notify = false,
            mini = false,
            bufferline = true,
            mason = true,
            telescope = {
              enabled = true,
              style = 'nvchad'
            }
            -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
  { 'alexghergh/nvim-tmux-navigation' },
  { 'christoomey/vim-tmux-navigator'},
  { 'tpope/vim-commentary' },
  { 'tpope/vim-repeat' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-eunuch' },
  { 'tpope/vim-unimpaired' },
  { 'tpope/vim-sleuth' },
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb'
    }
  },
  {
    'tpope/vim-projectionist',
    dependencies = {
      'tpope/vim-dispatch'
    }
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'RRethy/nvim-treesitter-endwise'
    },
    config = function ()
      local configs = require('nvim-treesitter.configs')
      configs.setup({
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "query",
          "ruby",
          "javascript",
          "typescript",
          "html",
          "css",
          "dockerfile",
          "markdown",
          "rust",
          "svelte"
        },
        sync_install = true,
        auto_install = true,
        highlight = { enable = true, disable = { 'NvimTree' } },
        indent = { enable = true },
      })
    end,
  },
  { 'nelstrom/vim-visual-star-search' },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup({
        filetype_exclude = {
          'help',
          'terminal',
          'dashboard',
          'lazy',
          'lspinfo',
          'TelescopePrompt',
          'TelescopeResults',
        },
        buftype_exclude = {
          'terminal',
          'NvimTree',
        },
        show_trailing_blankline_indent = false,
        show_first_indent_level = true,
        show_char_blankline = " ",
        show_current_context = true,
        show_current_context_start = true,
      })
      vim.opt.list = true
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {}
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local mocha = require("catppuccin.palettes").get_palette("mocha")

      require('bufferline').setup({
        options = {
          highlights = require('catppuccin.groups.integrations.bufferline').get({
            styles = { "italic", "bold" },
            custom = {
              mocha = {
                  background = { fg = mocha.text },
              },
            }
          }),
          mode = "buffers", -- set to "tabs" to only show tabpages instead
          themable = true, -- allows highlight groups to be overriden i.e. sets highlights as default
          numbers = "ordinal",
          close_command = "bdelete! %d",       -- can be a string | function, | false see "Mouse actions"
          right_mouse_command = "bdelete! %d", -- can be a string | function | false, see "Mouse actions"
          left_mouse_command = "buffer %d",    -- can be a string | function, | false see "Mouse actions"
          middle_mouse_command = nil,          -- can be a string | function, | false see "Mouse actions"
          indicator = {
            icon = ' ', -- this should be omitted if indicator style is not 'icon'
            style = 'icon',
          },
          buffer_close_icon = '',
          modified_icon = '●',
          close_icon = '',
          left_trunc_marker = '',
          right_trunc_marker = '',
          max_name_length = 18,
          max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
          truncate_names = true, -- whether or not tab names should be truncated
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and  " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = 'NvimTree',
              text = '  Files',
              highlight = 'StatusLine',
              text_align = 'left',
            }
          },
          color_icons = true, -- whether or not to add the filetype icon highlights
          get_element_icon = function(element)
            local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(element.filetype, { default = false })
            return icon, hl
          end,
          show_buffer_icons = true, -- disable filetype icons for buffers
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
          persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
          move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
          -- can also be a table containing 2 custom separators
          -- [focused and unfocused]. eg: { '|', '|' }
          separator_style = "thick",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
          },
          sort_by = 'insert_at_end',
          groups = {
            options = {
              toggle_hidden_on_enter = true -- when you re-enter a hidden group this options re-opens that group so the buffer is visible
            },
            items = {
              {
                name = "Tests", -- Mandatory
                highlight = { underline = true, sp = mocha.blue }, -- Optional
                priority = 2, -- determines where it will appear relative to other groups (Optional)
                icon = "", -- Optional
                matcher = function(buf) -- Mandatory
                  return buf.name:match('%_test') or buf.name:match('%_spec')
                end,
              },
            }
          },
          --custom_areas = {
          --  left = function()
          --    return {
          --      { text = '    ', fg = '#8fff6d' },
          --    }
          --  end,
          --},
        },
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff'},
          lualine_c = {
          },
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {
          lualine_a = {},
          lualine_b = {
            {
              'diagnostics',
              sources = { 'nvim_lsp', 'vim_lsp' },
              sections = { 'error', 'warn', 'info', 'hint' },
              diagnostics_color = {
                error = 'DiagnosticError',
                warn = 'DiagnosticWarn',
                info = 'DiagnosticInfo',
                hint = 'DiagnosticHint'
              },
              symbols = {
                error = ' ',
                warn = ' ',
                info = ' ',
                hint = ' '
              },
              colored = true,
              update_in_insert = true,
              always_visible = false
            }
          },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { {'datetime', style = 'default'}}
        },
        inactive_winbar = {
          lualine_a = {
            {
              'filename',
              file_status = true,
              newfile_status = false,
              path = 0,
              shorting_target = 40,
              symbols = {
                modified = '[+]',
                readonly = '[-]',
                unnamed = '[No name]',
                newfile = '[New]'
              }
            }
          }
        },
        extensions = {}
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('nvim-tree').setup({
        git = {
          ignore = false
        },
        renderer = {
          highlight_opened_files = '1',
          group_empty = true,
          icons = {
            show = {
              folder_arrow = false
            },
          },
          indent_markers = {
            enable = true
          }
        }
      })

      vim.cmd([[
        highligh NvimTreeIndentMarket guifg=#30323E
        augroup NvimTreeHighlights
          autocmd ColorScheme * highlight NvimTreeIndentMarker guifg=#30323E
        augroup end
      ]])
      vim.keymap.set('n', '<leader>n', ':NvimTreeFindFileToggle<CR>')
    end,
  },
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({
        easing_function = 'quadratic',
      })

      require('neoscroll.config').set_mappings({
        ['<C-u>'] = { 'scroll', { '-vim.wo.scroll', 'true', '50' } },
        ['<C-d>'] = { 'scroll', { 'vim.wo.scroll', 'true', '50' } },
      })
    end,
  },
  {
    'vim-test/vim-test',
    config = function()
      vim.keymap.set('n', '<Leader>tn', ':TestNearest<CR>')
      vim.keymap.set('n', '<Leader>tf', ':TestFile<CR>')
      vim.keymap.set('n', '<Leader>ts', ':TestSuite<CR>')
      vim.keymap.set('n', '<Leader>tl', ':TestLast<CR>')
      vim.keymap.set('n', '<Leader>tv', ':TestVisit<CR>')

      vim.cmd([[
        let g:test#strategy = 'neovim'
        let g:test#ruby#rspec#executable='docker compose run --rm -e RAILS_ENV=test app bundle exec rspec'
      ]])
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
    },
    config = function()
      local telescope = require('telescope')
      -- local actions = require('actions')

      vim.cmd([[
        highlight link TelescopePromptTitle PMenuSel
        highlight link TelescopePreviewTitle PMenuSel
        highlight link TelescopePromptNormal NormalFloat
        highlight link TelescopePromptBorder FloatBorder
        highlight link TelescopeNormal CursorLine
        highlight link TelescopeBorder CursorLineBg
      ]])

      telescope.setup({
        defaults = {
          path_display = { truncate = 1 },
          prompt_prefix = '   ',
          selection_caret = '  ',
          layout_config = {
            prompt_position = 'top',
          },
          sorting_strategy = 'ascending',
          file_ignore_patterns = { '.git/' },
          preview = {
            treesitter = false,
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          buffers = {
            previewer = false,
            layout_config = {
              width = 80,
            },
          },
          oldfiles = {
            prompt_title = 'History',
          },
          lsp_references = {
            previewer = false,
          },
        },
      })
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>f', builtin.find_files, {})
      -- vim.keymap.set('n', '<leader>F', builtin.find_files, { no_ignore = true, prompt_title = 'All files' })
      vim.keymap.set('n', '<leader>b', builtin.buffers, {})
      vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, {})

    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitsigns').setup({
        sign_priority = 20,
        current_line_blame = true,
        on_attach = function()
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line{full=true} end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end,
      })
    end,
  },
  {
    'Exafunction/codeium.vim',
    config = function()
     vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true })
     vim.keymap.set('i', '<C-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
     vim.keymap.set('i', '<C-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
     vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    end,
  },
})

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.ensure_installed({
  'angularls',
  'bashls',
  'clangd',
  'cmake',
  'cssls',
  'dockerls',
  'eslint',
  'grammarly',
  'html',
  'jsonls',
  'tsserver',
  'ltex',
  'lua_ls',
  'marksman',
  'puppet',
  'jedi_language_server',
  'solargraph',
  'rust_analyzer',
  'sqlls',
  'svelte',
  'tailwindcss',
  'terraformls',
  'vuels',
})

lsp.setup()

--vim.o.runtimepath = vim.o.runtimepath .. ",~/workspace/nvim-plugins/nvim-gtd-planner"
--vim.cmd [[command! ShowTasks lua require'nvim-gtd-planner'.show_tasks()]]
--vim.cmd [[command! -nargs=1 AddTask :lua require'nvim-gtd-planner'.add_task(<q-args>)]]
--vim.cmd [[command! -nargs=1 DeleteTask :lua require'nvim-gtd-planner'.delete_task(tonumber(<q-args>))]]
--vim.cmd [[command! -nargs=1 ToggleComplete :lua require'nvim-gtd-planner'.toggle_complete(tonumber(<q-args>))]]


