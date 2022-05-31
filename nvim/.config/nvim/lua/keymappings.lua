local mapper = function(mode, key, result)
  vim.api.nvim_set_keymap(mode, key, result, { noremap = true })
end

vim.g.mapleader = ' '
vim.api.nvim_set_keymap('', 'gf', ':edit <cfile><cr>', {})
vim.g.loaded_matchparent = 1

vim.api.nvim_set_keymap('n', '<leader>ve', ':edit ~/.config/nvim/init.lua<cr>',{})
vim.api.nvim_set_keymap('n', '<leader>vr', ':source ~/.config/nvim/init.lua<cr>', {})

vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { silent = true})
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { silent = true})
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { silent = true})
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { silent = true})


mapper('n', '<leader>ghw', ':h <C-R>=expand("<cword>")<CR><CR>')
mapper('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :veritcal resize 30 <CR>')

