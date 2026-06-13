vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
})

vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

---@type snacks.Config
require("snacks").setup({
  bigfile = { enabled = true },
  git = { enabled = true },
  gitbrowse = { enabled = true },
  lazygit = { enabled = true, win = { width = 0, height = 0, border = "none" } },
  terminal = { enabled = true },
  image = {
    enabled = true,
    bo = {
      buftype = "nofile",
      bufhidden = "wipe",
      swapfile = false,
      modifiable = false,
    },
  },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  words = { enabled = true },
  picker = {
    enabled = true,
    sources = {
      files = { hidden = true },
    },
  },
})

-- git
vim.keymap.set(
  "n",
  "<leader>gb",
  function() Snacks.picker.git_branches() end,
  { desc = "Git Branches" }
)
vim.keymap.set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log" })
vim.keymap.set(
  "n",
  "<leader>gL",
  function() Snacks.picker.git_log_line() end,
  { desc = "Git Log Line" }
)
vim.keymap.set(
  "n",
  "<leader>gs",
  function() Snacks.picker.git_status() end,
  { desc = "Git Status" }
)
vim.keymap.set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash" })
vim.keymap.set(
  "n",
  "<leader>gd",
  function() Snacks.picker.git_diff() end,
  { desc = "Git Diff (Hunks)" }
)
vim.keymap.set(
  "n",
  "<leader>gf",
  function() Snacks.picker.git_log_file() end,
  { desc = "Git Log File" }
)
