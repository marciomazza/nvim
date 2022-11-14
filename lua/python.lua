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
    vim.cmd('iabbrev pdb __import__("pdb").set_trace()')  -- TODO make this only local to python files
  end
})

-- zcml plone files are xml
vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  pattern = "*.zcml",
  callback = function() vim.bo.filetype = "xml" end
})
