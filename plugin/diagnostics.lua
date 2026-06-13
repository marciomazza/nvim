vim.pack.add({
  "https://github.com/rachartier/tiny-inline-diagnostic.nvim",
})

require("tiny-inline-diagnostic").setup({
  options = { show_source = true },
})
vim.diagnostic.config({ virtual_text = false })
