vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufopts = { noremap = true, silent = true, buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  end,
})

vim.lsp.config("*", {
  root_markers = { "pyproject.toml", ".git", ".jj" },
})

vim.lsp.enable({ "lua_ls", "ruff", "taplo", "djlsp", "jedi-language-server" })
