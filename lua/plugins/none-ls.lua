local register_lsp_format_on_save = require "utils".register_lsp_format_on_save

return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim",
    },
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      on_attach = function(client, bufnr)
        register_lsp_format_on_save(client, bufnr)
      end,
      sources = {
        null_ls.builtins.formatting.djlint.with({
          filetypes = { "django", "jinja.html", "htmldjango", "html" }
        }),
        null_ls.builtins.formatting.prettier,
        -- from nvimtools/none-ls-extras.nvim
        require("none-ls.formatting.trim_whitespace"),
        require("none-ls.formatting.trim_newlines"),
        require("none-ls.diagnostics.eslint"),
      },
    })
  end
}
