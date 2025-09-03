-- tolerate some typos on file related commands
-- apparently, there's no equivalent to the "cnoreabbrev" in lua
-- https://github.com/nanotee/nvim-lua-guide/issues/37
local abbreviations = {
  e  = { "E" },
  w  = { "W" },
  qa = { "q", "Q", "QA" },
  wq = { "Wq", "WQ", "qw", "QW" },
  wa = { "WA" }
}
for target, sources in pairs(abbreviations) do
  for _, source in ipairs(sources) do
    vim.cmd(string.format("cnoreabbrev %s %s", source, target))
    vim.cmd(string.format("cnoreabbrev %s! %s!", source, target))
  end
end

vim.opt.clipboard = "unnamed,unnamedplus" -- use standard clipboard
vim.opt.hidden = true                     -- Enable hidden buffers
vim.opt.diffopt:append { "iwhite" }       -- ignore whitespace in vimdiff

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- tabstops
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
-- use this otherwise markdown will have these set to 4
vim.g.markdown_recommended_style = false

vim.keymap.set("n", "<leader><space>", ":noh<cr>") -- clear search highlight
vim.keymap.set("n", "<Tab>", ":bn<cr>")            -- buffer nav
vim.keymap.set("n", "<S-Tab>", ":bp<cr>")          -- buffer nav
vim.keymap.set("n", "<leader>c", ":bd<cr>")        -- close buffer
vim.keymap.set("n", "<leader>l", ":luafile %<cr>") -- reload lua file

-- maintain Visual Mode after shifting > and <
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- toggle spell check
vim.keymap.set("", "<F6>", ":syntax on<CR>:setlocal spell! spelllang=en_us<CR>")
vim.keymap.set("", "<F7>", ":syntax on<CR>:setlocal spell! spelllang=pt_br<CR>")

-- hack to suppress "E173: n more files to edit" after :q without visiting all files
-- https://vi.stackexchange.com/a/31552
vim.api.nvim_create_autocmd("QuitPre", { command = ":blast" })

-- configure extra file types
vim.filetype.add({
  pattern = {
    ["ipython_log%.py.*"] = "python", -- ipython log
    [".envrc"] = "zsh",               -- direnv config
  },
  extension = {
    zcml = "xml", -- plone zcml
    dconf = "dosini",
  },
  filename = {
    ["~/.config/ghostty/config"] = "toml", -- ghostty config
  }
})

-- add project subdirectories to path to find files (with `gf`, for example)
vim.opt.path:append { vim.fn.getcwd() .. "/**" }
-- but ignore the directory `zzz`
-- TODO: ignore everything that is git ignored
vim.opt.wildignore:append { "**/zzz/**", ".git", ".git/*" }

-- open splits at the right
vim.opt.splitright = true

-- disable annoying warnings about swap files
vim.opt.swapfile = false

-- stop the block cursor from hiding the character under the cursor
-- TODO: find a better way to do this
vim.opt.guicursor = {
  "n-v-c:hor50",                          -- normal/visual/command → barra vertical grossa
  "i-ci:ver25",                           -- insert → barra vertical mais fina
  "r-cr:hor20",                           -- replace → underline
  "o:hor50",                              -- operator-pending → underline mais grosso
  "a:blinkwait700-blinkoff400-blinkon250" -- animação opcional
}

-- highlight the current line
vim.opt.cursorline = true
