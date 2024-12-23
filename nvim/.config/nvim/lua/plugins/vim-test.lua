return {
    'vim-test/vim-test',
    config = function()
        vim.keymap.set('n', '<Leader>tn', ':TestNearest<CR>')
        vim.keymap.set('n', '<Leader>tf', ':TestFile<CR>')
        vim.keymap.set('n', '<Leader>ts', ':TestSuite<CR>')
        vim.keymap.set('n', '<Leader>tl', ':TestLast<CR>')
        vim.keymap.set('n', '<Leader>tv', ':TestVisit<CR>')

        vim.cmd([[
      let g:test#strategy = 'neovim'
      let g:test#ruby#rspec#executable='bundle exec rspec'
      let g:test#ruby#minitest#executable='RAILS_ENV=test bundle exec rails test'
    ]])
    end,
}
