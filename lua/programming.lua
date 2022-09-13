require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "lua", "rust", "javascript", "sql" },
  auto_install = true,
  highlight = { enable = true, additional_vim_regex_highlighting = false },
}

-- python ----------------------------------------------------------------------

-- davidhalter/jedi-vim
vim.g['jedi#show_call_signatures'] = "0"
vim.opt.completeopt:remove {'preview'}  -- disable documentation window

function jedi_goto()
  -- based on autoload/jedi.vim ... function! jedi#goto()
  vim.cmd [[
    python3 jedi_goto_names = jedi_vim.goto(mode="goto")
    python3 success_lua_boolean = "true" if jedi_goto_names else "false"
    python3 vim.exec_lua(f"jedi_goto_success = {success_lua_boolean}")
  ]]
  return jedi_goto_success
end

--- extend jedi#goto to fall back to pyimport (useful for names inside comments or under quotes)
function jedi_goto_or_pyimport()
  if jedi_goto() then
    return
  end
  -- if goto definition did't work, try pyimport
  filename = vim.fn['expand']('<cfile>')
  vim.fn['jedi#py_import'](filename)
end
-- general python options
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
    vim.keymap.set('n', 'gd', jedi_goto_or_pyimport, {buffer = true})
  end
})
