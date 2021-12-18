Plug 'vim-test/vim-test'

if has('nvim')
    let test#strategy='neovim'
else
    let test#strategy='vimterminal'
end
let g:test#preserve_screen = 1

let test#ruby#rails#executable='docker-compose exec -e RAILS_ENV=test app rails rspec'

nmap <leader>tn :TestNearest<CR>
nmap <leader>tf :TestFile<CR>
nmap <leader>ts :TestSuite<CR>
nmap <leader>tl :TestLast<CR>
nmap <leader>tv :TestVisit<CR>
