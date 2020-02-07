
" generall python options
augroup vimrc-python
  autocmd!
  autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 colorcolumn=79
      \ formatoptions+=croq softtabstop=4 smartindent
      \ cinwords=if,elif,else,for,while,try,except,finally,def,class,with
augroup END

" hdima/python-syntax -- full python syntax highlighting
let g:python_highlight_all = 1

" SirVer/ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
let g:UltiSnipsEditSplit="vertical"

" dense-analysis/ale
let g:ale_fix_on_save = 1
let g:ale_fixers = {'python': ['isort']}
" TODO make mypy togglable?
" let b:ale_linters = {'python': ['mypy']}
let g:ale_pattern_options = {'ipython_log.py': {'ale_enabled': 0}}
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
""" male isort match black expectaions
""" see https://github.com/microsoft/vscode-python/issues/6933#issuecomment-543059396
""" TODO observe if this is really working... perhaps have a test?
let g:ale_python_isort_options = '--multi-line=1 --trailing-comma --force-grid-wrap=0 --use-parentheses --line-width=88'

" davidhalter/jedi-vim
let g:jedi#popup_on_dot = 0
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = "<leader>d"
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>n"
let g:jedi#rename_command = "<leader>r"
let g:jedi#show_call_signatures = "0"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#popup_on_dot = 1
" disable documentation window
set completeopt-=preview

" psf/black  -- apply black on every save
autocmd BufWritePre *.py execute ':Black'
