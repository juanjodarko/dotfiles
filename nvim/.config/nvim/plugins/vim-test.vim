Plug 'vim-test/vim-test'

if has('nvim')
    let test#strategy='neovim'
else
    let test#strategy='vimterminal'
endif

let g:test#preserve_screen = 1

" let test#ruby#rspec#executable='docker-compose run --rm -e RAILS_ENV=test app rspec'
let test#ruby#rspec#executable='bundle exec spring rspec'
let test#ruby#rspec#executable='docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec'

nmap <leader>tn :TestNearest<CR>
nmap <leader>tf :TestFile<CR>
nmap <leader>ts :TestSuite<CR>
nmap <leader>tl :TestLast<CR>
nmap <leader>tv :TestVisit<CR>
