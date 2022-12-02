syntax on

set guicursor=
set noerrorbells
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set hidden
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set showmode
set showcmd
highlight ColorColumn ctermbg=0 guibg=lightgrey

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'mbbill/undotree'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-fugitive'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vuciv/vim-bujo'
Plug 'tpope/vim-dispatch'
Plug 'vim-utils/vim-man'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'wakatime/vim-wakatime'

call plug#end()

colorscheme gruvbox
set background=dark
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
if executable('rg')
  let g:rg_derive_root="true"
endif
let loaded_matchparent = 1
let mapleader = " "

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'

nnoremap <leader>ghw :h <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>pw :Rg <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-p> :GFiles<CR>
nmap <leader>rr <Plug>(coc-rename)
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30 <CR>

