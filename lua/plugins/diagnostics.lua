return {
  "rachartier/tiny-inline-diagnostic.nvim",
  -- fixme maybe needs to be "LspAttach" for good integration with pyrefly... OBSERVE
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup()
    vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
}
