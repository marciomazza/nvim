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
vim.keymap.set("n", "<leader>l", function()
  vim.cmd.write()
  vim.cmd.luafile("%")
end, { desc = "Load lua file" })

-- maintain Visual Mode after shifting > and <
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- toggle spell check
for lang, key in pairs({ en_us = "<F6>", pt_br = "<F7>" }) do
  vim.keymap.set("n", key, function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    vim.opt_local.spelllang = lang
  end, { desc = "Toggle spell check (" .. lang:sub(1, 2):upper() .. ")" })
end

-- configure extra file types
vim.filetype.add({
  pattern = {
    ["ipython_log%.py.*"] = "python", -- ipython log
    [".envrc"] = "zsh", -- direnv config
    [".*ghostty/config"] = "toml",
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

-- open splits at the right
vim.opt.splitright = true

-- disable annoying warnings about swap files
vim.opt.swapfile = false

-- stop the block cursor from hiding the character under the cursor
-- TODO: find a better way to do this
vim.opt.guicursor = {
  "n-v-c:hor50", -- normal/visual/command → barra vertical grossa
  "i-ci:ver25", -- insert → barra vertical mais fina
  "r-cr:hor20", -- replace → underline
  "o:hor50", -- operator-pending → underline mais grosso
  "a:blinkwait700-blinkoff400-blinkon250", -- animação opcional
}

vim.diagnostic.config({ virtual_text = true })
