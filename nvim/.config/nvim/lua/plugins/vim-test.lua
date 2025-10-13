return {
    'vim-test/vim-test',
    config = function()
        -- Standard keymap helper
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
        end

        map('n', '<Leader>tn', ':TestNearest<CR>', "Test nearest")
        map('n', '<Leader>tf', ':TestFile<CR>', "Test file")
        map('n', '<Leader>ts', ':TestSuite<CR>', "Test suite")
        map('n', '<Leader>tl', ':TestLast<CR>', "Test last")
        map('n', '<Leader>tv', ':TestVisit<CR>', "Test visit")

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
