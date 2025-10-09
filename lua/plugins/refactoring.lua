local keys_to_actions = {
  rf = "Extract Function",
  rv = "Extract Variable",
  rI = "Inline Function",
  ri = "Inline Variable",
}

for keys, action in pairs(keys_to_actions) do
  local refactor = function()
    return require("refactoring").refactor(action)
  end
  vim.keymap.set({ "n", "x" }, "<leader>" .. keys, refactor, { expr = true, desc = action })
end

return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  opts = {},
}
