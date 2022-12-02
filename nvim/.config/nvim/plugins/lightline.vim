Plug 'itchyny/lightline.vim'

set laststatus=2
set noshowmode
let g:lightline = {}
let g:lightline.colorscheme = 'gruvbox'
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
if !has('gui_running')
  set t_Co=256
endif

