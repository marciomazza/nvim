vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bufopts = { noremap = true, silent = true, buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  end,
})

vim.lsp.config("*", {
  root_markers = { "pyproject.toml", ".git", ".jj" },
})

vim.lsp.enable({ "djlsp" }) -- still not known to mason-lspconfig

return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "ruff", "jedi_language_server", "taplo" },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "prettier", "prettierd", "stylua" },
    },
  },
}
