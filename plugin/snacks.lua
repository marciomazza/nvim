vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
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
for _, map in ipairs({
  { key = "b", method = "git_branches", desc = "Git Branches" },
  { key = "l", method = "git_log", desc = "Git Log" },
  { key = "L", method = "git_log_line", desc = "Git Log Line" },
  { key = "s", method = "git_status", desc = "Git Status" },
  { key = "S", method = "git_stash", desc = "Git Stash" },
  { key = "d", method = "git_diff", desc = "Git Diff (Hunks)" },
  { key = "f", method = "git_log_file", desc = "Git Log File" },
}) do
  vim.keymap.set(
    "n",
    "<leader>g" .. map.key,
    function() Snacks.picker[map.method]() end,
    { desc = map.desc }
  )
end
