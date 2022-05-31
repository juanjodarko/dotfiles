Plug 'kyazdani42/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'

" NOTE: If barbar's option dict isn't created yet, create it
let bufferline = get(g:, 'bufferline', {})

" Enable/disable auto-hiding the tab bar when there is a single buffer
let bufferline.auto_hide = v:true

" Goto buffer in position...
nnoremap <silent>    <A-1> :BufferGoto 1<CR>
nnoremap <silent>    <A-2> :BufferGoto 2<CR>
nnoremap <silent>    <A-3> :BufferGoto 3<CR>
nnoremap <silent>    <A-4> :BufferGoto 4<CR>
nnoremap <silent>    <A-5> :BufferGoto 5<CR>
nnoremap <silent>    <A-6> :BufferGoto 6<CR>
nnoremap <silent>    <A-7> :BufferGoto 7<CR>
nnoremap <silent>    <A-8> :BufferGoto 8<CR>
nnoremap <silent>    <A-9> :BufferLast<CR>

" Pin/unpin buffer
nnoremap <silent>    <A-p> :BufferPin<CR>

" Close buffer
nnoremap <silent>    <A-c> :BufferClose<CR>

" Close All But Current or pinned
nnoremap <silent>    <A-x> :BufferCloseAllButCurrentOrPinned<CR>
