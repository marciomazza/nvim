vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
  end,
})

return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {
          -- for ensure_installed djlsp (wait until PR merged to remove)
          -- https://github.com/mason-org/mason-registry/pull/12057
          registries = {
            "file:~/repos/mason-registry",
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "ruff",
        "jedi_language_server",
        "lua_ls",
        "taplo",
        "tailwindcss",
        "djlsp",
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
