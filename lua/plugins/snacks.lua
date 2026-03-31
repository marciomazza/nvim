return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
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
    picker = { enabled = true },
  },
  keys = {
    { "<leader>e", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sb", function() Snacks.picker.buffers() end, desc = "Buffers" },
  },
}
