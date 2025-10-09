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
    dependencies = { { "mason-org/mason.nvim", opts = {} }, "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "ruff", "jedi_language_server", "taplo" },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "prettier", "prettierd", "stylua" },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      return { sources = { require("null-ls").builtins.diagnostics.djlint } }
    end,
  },
}
