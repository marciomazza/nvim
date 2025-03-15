-- tolerate some typos on file related commands
-- apparently, there's no equivalent to the "cnoreabbrev" in lua
-- https://github.com/nanotee/nvim-lua-guide/issues/37
local abbrev_translations = {
  "W w",
  "Q q",
  "Qa qa",
  "E e",
  "W! w!",
  "Q! q!",
  "Qa! qa!",
  "Qall qall",
  "Qall! qall!",
  "Wq wq",
  "Wa wa",
  "wQ wq",
  "WQ wq",
  "qw wq"
}
for _, entry in pairs(abbrev_translations) do
  vim.cmd(string.format("cnoreabbrev %s", entry))
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
vim.keymap.set("n", "<leader>e", ":FZF<cr>")       -- open file with fzf
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

-- grep.vim
vim.keymap.set("n", "<leader>f", ":Rgrep<CR>")
vim.g.Grep_Default_Options = "-IR"
vim.g.Grep_Skip_Files = "*~ ipython_log.py*"
vim.g.Grep_Skip_Dirs = "RCS CVS SCCS htmlcov .pytest_cache .mypy_cache zz"

-- configure extra file types
vim.filetype.add({
  pattern = {
    ["ipython_log%.py.*"] = "python", -- ipython log
    [".+%.zcml"] = "xml",             -- plone zcml
    [".envrc"] = "zsh",               -- direnv config
  }
})

-- add project subdirectories to path to find files (with `gf`, for example)
vim.opt.path:append { vim.fn.getcwd() .. "/**" }
-- but ignore the directory `zzz`
-- TODO: ignore everything that is git ignored
vim.opt.wildignore:append { "**/zzz/**" }
