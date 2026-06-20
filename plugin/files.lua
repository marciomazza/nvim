pack_changed_hook("fff.nvim", function(ev)
  if not ev.data.active then vim.cmd.packadd("fff.nvim") end
  require("fff.download").download_or_build_binary()
end)

vim.pack.add({
  "https://github.com/wsdjeg/vim-fetch",
  "https://github.com/dmtrKovalenko/fff.nvim",
})

require("fff").setup({
  debug = {
    enabled = true,
    show_scores = true,
  },
  layout = {
    height = 1,
    width = 1,
    preview_size = 0.7,
  },
})
vim.keymap.set(
  "n",
  "<leader>e",
  function() require("fff").find_files() end,
  { desc = "FFFind files" }
)
vim.keymap.set(
  "n",
  "<leader>f",
  function()
    require("fff").live_grep({
      query = vim.fn.expand("<cword>"),
    })
  end,
  { desc = "Live grep (current word)" }
)
