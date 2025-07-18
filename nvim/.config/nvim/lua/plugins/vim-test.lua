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
        -- transformation -------------------------------------------------------
        vim.cmd([[
          function! DockerTransform(cmd) abort
            " Only wrap when we’re *inside* a Docker-based project
            if filereadable('docker-compose.yml')
              return 'docker compose run --rm app ' . a:cmd
            endif
            if filereadable('compose.yml')
              return 'docker compose -f compose.yml run --rm app ' . a:cmd
            endif
            return a:cmd
          endfunction

          let g:test#custom_transformations = {'docker': function('DockerTransform')}
          let g:test#transformation        = 'docker'
        ]])
    end,
}
