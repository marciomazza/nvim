vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
  end,
})

return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
        "stylua",
        "ruff",
        "pyrefly",
        "lua_ls",
        "taplo",
        "tailwindcss",
        "djlsp",
        -- todo: choose copilot x windosurf x something else
        "copilot", -- github/copilot-language-server-release
        "ts_ls",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "prettier", "prettierd" },
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
