vim.cmd [[

"" The PC is fast enough, do syntax highlight syncing from start
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync fromstart
augroup END

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

au FocusGained,BufEnter,BufWinEnter,CursorHold,CursorMoved * :checktime

"" Copy/Paste/Cut
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

"" Enable hidden buffers
set hidden

"" Searching
set ignorecase
set smartcase

"" Tabs. May be overriten by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" toggle spell check
map <F6> :syntax on<CR>:setlocal spell! spelllang=en_us<CR>
imap <F6> <C-o>:syntax on<C-o>:setlocal spell! spelllang=en_us<CR>

" vimdiff -- ignore whitespace differences
set diffopt+=iwhite

]]
