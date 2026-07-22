-- Run nvim-ts-context-commentstring in standalone mode (no archived
-- nvim-treesitter dependency). Must be set before the plugin loads.
vim.g.skip_ts_context_commentstring_module = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.hidden = true
vim.opt.signcolumn = 'yes:2'
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.undofile = true -- persistent undo
vim.opt.spell = true
vim.opt.title = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildmode =
'longest:full,full' -- complete the longest common match, and allow tabbing the results to fully complete them
vim.opt.list = true -- enable the below listchars
vim.opt.listchars = { tab = '▸ ', trail = '·' }
vim.opt.mouse = 'a' -- enable mouse for all modes
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = 'unnamedplus'       -- Use Linux system clipboard
vim.opt.confirm = true                  -- ask for confirmation instead of erroring
vim.opt.exrc = true
vim.opt.backup = true                   -- automatically save a backup file
vim.opt.backupdir = { vim.fn.expand('~/.local/share/nvim/backup/') }  -- centralized backup directory
vim.opt.updatetime = 4001               -- Set updatime to 1ms longer than the default to prevent polyglot from changing it
vim.opt.redrawtime = 10000              -- Allow more time for loading syntax on large files
vim.opt.wrap = false
vim.opt.breakindent = true              -- maintain indent when wrapping indented lines
vim.opt.fillchars:append({ eob = ' ' }) -- remove the ~ from end of buffer
vim.opt.shortmess:append({ I = true })  -- disable the splash screen
vim.opt.showmode = false

-- Enable server mode for remote communication (theme switching, etc.)
-- This allows external scripts to send commands to running Neovim instances
if vim.fn.has('nvim-0.9') == 1 then
  -- Create a unique server address based on the process ID
  local server_addr = vim.fn.stdpath('run') .. '/nvim.' .. vim.fn.getpid() .. '.sock'
  vim.fn.serverstart(server_addr)
end
