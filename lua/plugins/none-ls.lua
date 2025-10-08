local plone = require "plone"

return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim",
    },
  },
  config = function()
    local null_ls = require "null-ls"

    -- djlint filetypes should not be formatted by prettier
    local djlint_filetypes = { "django", "jinja.html", "htmldjango", "html" }
    local prettier_filetypes = { "javascript", "typescript", "css", "scss", "less", "json" }

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.djlint.with({ filetypes = djlint_filetypes }),
        null_ls.builtins.diagnostics.djlint.with({ filetypes = djlint_filetypes }),
        null_ls.builtins.formatting.prettier.with({ filetypes = prettier_filetypes }),
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "yaml" }, extra_args = { "--no-bracket-spacing" }
        }),
        -- from nvimtools/none-ls-extras.nvim
        require "none-ls.formatting.trim_whitespace",
        require "none-ls.formatting.trim_newlines",
        require "none-ls.diagnostics.eslint",
      },
    })
  end
}
