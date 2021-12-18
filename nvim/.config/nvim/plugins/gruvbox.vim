Plug 'morhetz/gruvbox'

augroup GruvboxOverrides
    autocmd!
    autocmd User PlugLoaded ++nested colorscheme gruvbox
    autocmd User PlugLoaded ++nested set background=dark
augroup end
