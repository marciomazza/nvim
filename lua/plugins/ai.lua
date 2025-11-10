return {
  "Exafunction/windsurf.vim",
  config = function()
    vim.g.windsurf_buftype_blacklist = { "quickfix", "help", "nofile", "terminal" }
    vim.g.codeium_idle_delay = 100
  end,
}
