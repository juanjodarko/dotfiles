vim.g.mapleader = ' '
vim.g.loaded_matchparent = 1

-- Standard keymap helper
local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- Config editing keymaps
map('n', '<leader>ve', ':edit ~/.config/nvim/init.lua<cr>', "Edit init.lua")
map('n', '<leader>vr', ':source ~/.config/nvim/init.lua<cr>', "Reload init.lua")

-- File navigation
map('', 'gf', ':edit <cfile><cr>', "Go to file")

-- Tmux navigation
map('n', '<C-h>', 'TmuxNavigateLeft<CR>', "Navigate left (tmux)")
map('n', '<C-j>', 'TmuxNavigateDown<CR>', "Navigate down (tmux)")
map('n', '<C-k>', 'TmuxNavigateUp<CR>', "Navigate up (tmux)")
map('n', '<C-l>', 'TmuxNavigateRight<CR>', "Navigate right (tmux)")

-- Terminal mode navigation (exit terminal mode + move to window)
map('t', '<C-h>', '<C-\\><C-n><C-w>h', "Navigate left from terminal")
map('t', '<C-j>', '<C-\\><C-n><C-w>j', "Navigate down from terminal")
map('t', '<C-k>', '<C-\\><C-n><C-w>k', "Navigate up from terminal")
map('t', '<C-l>', '<C-\\><C-n><C-w>l', "Navigate right from terminal")

-- Quick escape from terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', "Exit terminal mode")

-- Utility keymaps
map('n', '<leader>ghw', ':h <C-R>=expand("<cword>")<CR><CR>', "Help for word under cursor")
map('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :vertical resize 30 <CR>', "Open file explorer")

-- VCR
map('n', '<leader>xr', ':call VcrQuery()<CR>', "VCR Query")
