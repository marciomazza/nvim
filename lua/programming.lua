local set_keymap = require('utils').set_keymap

-- generall python options
local python_augroup = vim.api.nvim_create_augroup('python-augroup', {clear = true})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = python_augroup,
  callback = function()
    vim.bo.tabstop       = 8
    vim.bo.softtabstop   = 0
    vim.bo.shiftwidth    = 4
    vim.bo.softtabstop   = 4
    vim.bo.smartindent   = true
    vim.bo.formatoptions = 'croqj'
    vim.wo.colorcolumn   = '100'
    vim.cmd('iabbrev pdb breakpoint()')  -- TODO make this only local to python files
    -- ajh17/VimCompletesMe: use omnicompletion with tab just on python files
    vim.b.vcm_tab_complete = "omni"
  end
})

-- hdima/python-syntax -- full python syntax highlighting
vim.g.python_highlight_all = 1

-- dense-analysis/ale ----------------------------------------------------------

-- ALE fixers
vim.g.ale_fix_on_save = 1
vim.g.ale_fixers = { ['*'] = {'remove_trailing_lines', 'trim_whitespace'},
                     python = {'autoflake', 'black', 'isort'}}
vim.g.ale_python_black_use_global = 1
vim.g.ale_python_isort_use_global = 1
vim.g.ale_python_isort_options = '--float-to-top --profile black'

-- ALE linters
vim.g.ale_linters_explicit = 1
vim.g.ale_linters = {python = {'flake8', 'pyright'}}
-- W503 is not PEP 8 compliant and black disregards it
vim.g.ale_python_flake8_options="--ignore E501,W503"
vim.g.ale_pattern_options = {
  ['ipython_log.py'] = {ale_enabled = 0, ale_fixers = {}},
  ['site-packages'] = {ale_enabled = 0, ale_fixers = {}},
  repos = {ale_enabled = 0, ale_fixers = {}},
}

-- ALE appearance
vim.g.ale_echo_msg_error_str = 'E'
vim.g.ale_echo_msg_warning_str = 'W'
vim.g.ale_echo_msg_format = '[%linter%] %s [%severity%]'
vim.g.ale_virtualtext_cursor = 1
vim.g.ale_virtualtext_prefix = ' ▶  '
vim.g.ale_sign_error = '▶'
vim.g.ale_sign_warning = '▶'
vim.g.ale_sign_info = '▶'

-- ALE mappings
set_keymap('n', '<C-k>', '<Plug>(ale_previous_wrap)')
set_keymap('n', '<C-j>', '<Plug>(ale_next_wrap)')

-- davidhalter/jedi-vim --------------------------------------------------------
vim.g['jedi#show_call_signatures'] = "0"
-- disable documentation window
vim.opt.completeopt:remove {'preview'}
vim.g['jedi#goto_command'] = "gd"

-- hack to go to fully qualified names in strings ( like in settings.py )
-- TODO: create a function that uses jedi#goto_definition and falls back to using this if it fails
-- so that we use only one shortcut
set_keymap('n', 'gy', 'yi":Pyimport <C-R>+<CR>')
