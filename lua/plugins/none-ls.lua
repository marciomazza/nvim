local register_lsp_format_on_save = require "utils".register_lsp_format_on_save

return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      on_attach = function(client, bufnr)
        register_lsp_format_on_save(client, bufnr)
      end,
      sources = {
        null_ls.builtins.formatting.trim_whitespace,
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.formatting.djlint.with({
          filetypes = { "django", "jinja.html", "htmldjango", "html" }
        }),
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.formatting.prettier,
      },
    })
  end
}
