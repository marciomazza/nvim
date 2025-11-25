-- tolerate some typos on file related commands
local abbreviations = {
  e = { "E" },
  w = { "W" },
  qa = { "q", "Q", "QA" },
  wq = { "Wq", "WQ", "qw", "QW" },
  wa = { "WA" },
}
for target, sources in pairs(abbreviations) do
  for _, source in ipairs(sources) do
    vim.cmd.cnoreabbrev(source, target)
    vim.cmd.cnoreabbrev(source .. "!", target .. "!")
  end
end

vim.opt.clipboard = "unnamedplus" -- use standard clipboard
vim.opt.diffopt:append("iwhite") -- ignore whitespace in vimdiff

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- tabstops
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
-- use this otherwise markdown will have these set to 4
vim.g.markdown_recommended_style = false

vim.keymap.set("n", "<leader><space>", vim.cmd.nohl, { desc = "Clear highlights" })
vim.keymap.set("n", "<Tab>", vim.cmd.bnext, { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", vim.cmd.bprevious, { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>c", vim.cmd.bdelete, { desc = "Close buffer" })

-- maintain Visual Mode after shifting > and <
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- configure extra file types
vim.filetype.add({
  pattern = {
    ["ipython_log%.py.*"] = "python", -- ipython log
    [".envrc"] = "zsh", -- direnv config
    [".*ghostty/config"] = "toml",
    [".*/templates/.*%.html"] = "htmldjango", -- django-plus.vim is not detecting some templates
  },
  extension = {
    zcml = "xml", -- plone zcml
    dconf = "dosini",
  },
})

-- add project subdirectories to path to find files (with `gf`, for example)
vim.opt.path:append(vim.uv.cwd() .. "/**")
-- but ignore the directory `zzz`
-- TODO: ignore everything that is git ignored
vim.opt.wildignore:append({ "**/zzz/**", ".git" })

vim.opt.splitright = true -- open splits at the right
vim.opt.swapfile = false -- disable annoying warnings about swap files

-- Close quickfix list automatically when selecting an item
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true })
  end,
})
