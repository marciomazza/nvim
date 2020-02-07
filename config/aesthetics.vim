
" marciomazza/vim-brogrammer-theme
"no_buffers_menu silent for the case when the plugin has not yet been installed
set t_Co=256
silent! colorscheme brogrammer

" luochen1990/rainbow
let g:rainbow_active = 1

" vim-airline/vim-airline
let g:airline_theme = 'powerlineish'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''

  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif
" in airline avoid delay when switching from insert to normal mode
" see https://github.com/bling/vim-airline/issues/124#issuecomment-22389800
" and see https://github.com/bling/vim-airline/wiki/FAQ#there-is-a-pause-when-leaving-insert-mode
set ttimeoutlen=50

" tpope/vim-fugitive
if exists("*fugitive#statusline")
  set statusline+=%{fugitive#statusline()}
endif
