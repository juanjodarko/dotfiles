local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Initialize packer
require('packer').init({
  compile_path = vim.fn.stdpath('data')..'/site/plugin/packer_compiled.lua',
  display = {
    open_fn = function()
      return require('packer.util').float({ border = 'solid' })
    end,
  },
})

-- Install plugins
local use = require('packer').use

use('wbthomason/packer.nvim')

use('christoomey/vim-tmux-navigator')
--use('farmergreg/vim-lastplace')
use('tpope/vim-commentary')
use('tpope/vim-repeat')
use('tpope/vim-surround')
use('tpope/vim-eunuch') -- Adds :Rename, :SudoWrite
use('tpope/vim-unimpaired') -- Adds [b and other handy mappings
use('tpope/vim-sleuth') -- Indent autodetection with editorconfig support
use('nelstrom/vim-visual-star-search')
--
use({
  'tpope/vim-projectionist',
  requires = 'tpope/vim-dispatch',
  config = function()
    require('user.plugins.projectionist')
  end,
})
--
--use({
--  "ellisonleao/gruvbox.nvim",
--  config = function()
--    vim.o.background = "dark"
--    vim.cmd([[colorscheme gruvbox]])
--  end,
--})
use({
  'arcticicestudio/nord-vim',
  config = function()
    vim.o.background = 'dark'
    vim.cmd([[colorscheme nord]])
  end,
})
--
--use({
--  'tommcdo/vim-lion',
--  config = function()
--    require('user.plugins.lion')
--  end,
--})
--
--use({
--  'whatyouhide/vim-textobj-xmlattr',
--  requires = 'kana/vim-textobj-user',
--})
--
use({
  'lukas-reineke/indent-blankline.nvim',
  config = function()
    require('user.plugins.indent-blankline')
  end,
})
--
use({
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup()
  end,
})
--
use({
  'akinsho/bufferline.nvim',
  tag = "v3.*",
  requires = 'kyazdani42/nvim-web-devicons',
  config = function()
    require('user.plugins.bufferline')
  end
})
--
use({
  'nvim-lualine/lualine.nvim',
  requires = 'kyazdani42/nvim-web-devicons',
  config = function()
    require('user.plugins.lualine')
  end,
})
--
use({
  'kyazdani42/nvim-tree.lua',
  requires = 'kyazdani42/nvim-web-devicons',
  config = function()
    require('user.plugins.nvim-tree')
  end,
})
--
use({
  'karb94/neoscroll.nvim',
  config = function()
    require('user.plugins.neoscroll')
  end,
})
--
use({
  'vim-test/vim-test',
  config = function()
    require('user.plugins.vim-test')
  end,
})
--
use({
  'voldikss/vim-floaterm',
  config = function()
    require('user.plugins.floaterm')
  end,
})
--
use({
  'nvim-telescope/telescope.nvim',
  requires = {
    { 'nvim-lua/plenary.nvim' },
    { 'kyazdani42/nvim-web-devicons' },
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
  },
  config = function()
    require('user.plugins.telescope')
  end,
})
--
use({
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  requires = {
    'nvim-treesitter/playground',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'RRethy/nvim-treesitter-endwise'
  },
  config = function()
    require('user.plugins.treesitter')
  end,
})
--
use({
  'tpope/vim-fugitive',
  requires = 'tpope/vim-rhubarb',
  cmd = 'G',
})
--
use({
  'lewis6991/gitsigns.nvim',
  requires = 'nvim-lua/plenary.nvim',
  config = function()
    require('gitsigns').setup({
      sign_priority = 20,
      on_attach = function(bufnr)
        vim.keymap.set('n', ']h', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true, buffer = bufnr })
        vim.keymap.set('n', '[h', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true, buffer = bufnr })
      end,
    })
  end,
})
--
use({
  'neovim/nvim-lspconfig',
  requires = {
    'b0o/schemastore.nvim',
    'folke/lsp-colors.nvim',
  },
  config = function()
    require('user.plugins.lspconfig')
  end,
})
--
use({
  'weilbith/nvim-code-action-menu',
  cmd = 'CodeActionMenu',
})
--
use({
  'jose-elias-alvarez/null-ls.nvim',
  requires = {
    {'nvim-lua/plenary.nvim'},
    {"semanticart/ruby-code-actions.nvim"}
  },
  config = function()
    require('user.plugins.null-ls')
  end,
})
--
---- use {
----   'j-hui/fidget.nvim',
----   config = function()
----     require('fidget').setup{
----       align = {
----         bottom = false
----       }
----     }
----   end,
---- }
--
use({
  'L3MON4D3/LuaSnip',
  config = function()
    require('user.plugins.luasnip')
  end,
})
--
use({
  'hrsh7th/nvim-cmp',
  requires = {
    'L3MON4D3/LuaSnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-nvim-lua',
    'jessarcher/cmp-path',
    'onsails/lspkind-nvim',
    'saadparwaiz1/cmp_luasnip',
  },
  config = function()
    require('user.plugins.cmp')
  end,
})
--
--
---- Experimental
--
--
--use({
--  'glepnir/dashboard-nvim',
--  config = function()
--    require('user.plugins.dashboard')
--  end,
--})
--
--use({
--  'danymat/neogen',
--  config = function()
--    require('neogen').setup({})
--  end,
--  requires = 'nvim-treesitter/nvim-treesitter',
--})
--
use({
  'sheerun/vim-polyglot',
})
--
---- Rename in a popup window
--use({
--  'hood/popui.nvim',
--  requires = 'RishabhRD/popfix',
--  config = function()
--    vim.ui.select = require('popui.ui-overrider')
--    vim.ui.input = require('popui.input-overrider')
--  end,
--})
--
use({
  'folke/trouble.nvim',
  requires = 'kyazdani42/nvim-web-devicons',
  config = function()
    require('trouble').setup()
  end,
})
--
--use({
--  'antoinemadec/FixCursorHold.nvim',
--  config = function()
--    vim.g.cursorhold_updatetime = 100
--  end,
--})
--
---- Automatically install plugins on first run
if packer_bootstrap then
  require('packer').sync()
end
--
---- Automatically regenerate compiled loader file on save
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile>
  augroup end
]])
