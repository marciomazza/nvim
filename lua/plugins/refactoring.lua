local keymaps = {
  ["<leader>rf"] = "Extract Function",
  ["<leader>rv"] = "Extract Variable",
  ["<leader>rI"] = "Inline Function",
  ["<leader>ri"] = "Inline Variable",
}

for key, action in pairs(keymaps) do
  vim.keymap.set({ "n", "x" }, key, function()
    return require("refactoring").refactor(action)
  end, { expr = true })
end

return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  opts = {},
  -- keys = keys,
}
