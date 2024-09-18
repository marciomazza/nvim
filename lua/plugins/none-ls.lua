local djlint_filetypes = { "django", "jinja.html", "htmldjango", "html" }

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
      sources = {
        null_ls.builtins.formatting.djlint.with({ filetypes = djlint_filetypes }),
        null_ls.builtins.diagnostics.djlint.with({ filetypes = djlint_filetypes }),
        null_ls.builtins.formatting.prettier,
        -- keep this until ruff implements float-to-top
        --   see https://github.com/astral-sh/ruff/issues/6514
        null_ls.builtins.formatting.isort.with({ extra_args = { "--float-to-top" } }),
        -- from nvimtools/none-ls-extras.nvim
        require("none-ls.formatting.trim_whitespace"),
        require("none-ls.formatting.trim_newlines"),
        require("none-ls.diagnostics.eslint"),
      },
    })
  end
}
