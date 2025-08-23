vim.g.mapleader = ' '
vim.g.loaded_matchparent = 1

-- Config editing keymaps
vim.keymap.set('n', '<leader>ve', ':edit ~/.config/nvim/init.lua<cr>')
vim.keymap.set('n', '<leader>vr', ':source ~/.config/nvim/init.lua<cr>')

-- File navigation  
vim.keymap.set('', 'gf', ':edit <cfile><cr>')

-- Tmux navigation
vim.keymap.set('n', '<C-h>', 'TmuxNavigateLeft<CR>', { silent = true })
vim.keymap.set('n', '<C-j>', 'TmuxNavigateDown<CR>', { silent = true })
vim.keymap.set('n', '<C-k>', 'TmuxNavigateUp<CR>', { silent = true })
vim.keymap.set('n', '<C-l>', 'TmuxNavigateRight<CR>', { silent = true })

-- Utility keymaps
vim.keymap.set('n', '<leader>ghw', ':h <C-R>=expand("<cword>")<CR><CR>')
vim.keymap.set('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :vertical resize 30 <CR>')

-- VCR
vim.keymap.set('n', '<leader>xr', ':call VcrQuery()<CR>')
