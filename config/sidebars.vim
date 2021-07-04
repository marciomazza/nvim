
"" preservim/nerdtree
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 40
let g:NERDTreeShowHidden = 1
let g:NERDTreeQuitOnOpen = 1
noremap <F3> :NERDTreeToggle<CR>
"" avoid conflict that show brackets on nerdtree
""   https://github.com/luochen1990/rainbow/issues/92
let g:rainbow_conf = { 'separately': { 'nerdtree': 0 } }


" majutsushi/tagbar
"
"" hack by @magnunleno to replace
""     let g:airline#extensions#tagbar#enabled = 1
function! MyTagbarToggle()
  let g:airline#extensions#tagbar#enabled = 1
  call plug#load('tagbar')
  TagbarToggle
  let s:ext = {}
  let s:ext._theme_funcrefs = []
  function! s:ext.add_statusline_func(name) dict
    call airline#add_statusline_func(a:name)
  endfunction
  function! s:ext.add_statusline_funcref(function) dict
    call airline#add_statusline_funcref(a:function)
  endfunction
  function! s:ext.add_inactive_statusline_func(name) dict
    call airline#add_inactive_statusline_func(a:name)
  endfunction
  function! s:ext.add_theme_func(name) dict
    call add(self._theme_funcrefs, function(a:name))
  endfunction
  call airline#extensions#tagbar#init(s:ext)
  AirlineRefresh
endfunction
nnoremap <silent> <F4> :call MyTagbarToggle()<CR>
let g:tagbar_autoclose = 1
"" sort by position in file
let g:tagbar_sort = 0
