
"" preservim/nerdtree
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=[
            \ '\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '.git',
            \ '__pycache__', '.pytest_cache', '.mypy_cache', 'htmlcov', 'zz*']
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
nnoremap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_autoclose = 1
"" sort by position in file
let g:tagbar_sort = 0
