
" marciomazza/vim-brogrammer-theme
"no_buffers_menu silent for the case when the plugin has not yet been installed
set t_Co=256
silent! colorscheme brogrammer

set number
" set relativenumber

" luochen1990/rainbow
let g:rainbow_active = 1

" itchyny/lightline.vim & mengelbrecht/lightline-bufferline
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': { 'gitbranch': 'FugitiveHead' },
      \ 'tabline': { 'left': [['buffers']] , 'right': [[]] },
      \ 'component_expand': { 'buffers': 'lightline#bufferline#buffers' },
      \ 'component_type': { 'buffers': 'tabsel' },
      \ }
set showtabline=2
