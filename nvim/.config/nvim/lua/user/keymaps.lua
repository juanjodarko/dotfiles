local mapper = function(mode, key, result)
  vim.api.nvim_set_keymap(mode, key, result, { noremap = true })
end

vim.g.mapleader = ' '
vim.api.nvim_set_keymap('', 'gf', ':edit <cfile><cr>', {})
vim.g.loaded_matchparent = 1

vim.api.nvim_set_keymap('n', '<leader>ve', ':edit ~/.config/nvim/init.lua<cr>',{})
vim.api.nvim_set_keymap('n', '<leader>vr', ':source ~/.config/nvim/init.lua<cr>', {})

vim.api.nvim_set_keymap('n', '<C-h>', 'TmuxNavigateLeft<CR>', { silent = true})
vim.api.nvim_set_keymap('n', '<C-j>', 'TmuxNavigateDown<CR>', { silent = true})
vim.api.nvim_set_keymap('n', '<C-k>', 'TmuxNavigateUp<CR>', { silent = true})
vim.api.nvim_set_keymap('n', '<C-l>', 'TmuxNavigateRight<CR>', { silent = true})

mapper('n', '<leader>ghw', ':h <C-R>=expand("<cword>")<CR><CR>')
mapper('n', '<leader>pv', ':wincmd v<bar> :Ex <bar> :veritcal resize 30 <CR>')

-- TroubleToggle
mapper("n", "<leader>ttdl", ":TroubleToggle<CR>", {silent = true, noremap = true})
mapper("n", "<leader>ttwd", ":TroubleToggle workspace_diagnostics<CR>", {silent = true, noremap = true})
mapper("n", "<leader>ttdd", ":TroubleToggle document_diagnostics<CR>", {silent = true, noremap = true})
mapper("n", "<leader>ttll", ":TroubleToggle loclist<CR>", {silent = true, noremap = true})
mapper("n", "<leader>ttxq", ":TroubleToggle quickfix<CR>", {silent = true, noremap = true})
mapper("n", "gR", ":TroubleToggle lsp_references<CR>", {silent = true, noremap = true})

