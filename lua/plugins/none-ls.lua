return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  opts = function()
    return {
      sources = {
        require("null-ls").builtins.diagnostics.djlint,
      },
    }
  end,
}
