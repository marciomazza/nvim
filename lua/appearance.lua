vim.cmd.colorscheme "PaperColor"

vim.opt.number = true
vim.opt.relativenumber = true
-- It breaks a lot of things, so suspended. Perhaps use it in the future
-- vim.opt.cmdheight = 0  -- autohide the command-line (https://vi.stackexchange.com/a/38231)

-- itchyny/lightline.vim & mengelbrecht/lightline-bufferline
vim.g.lightline = {
    colorscheme = "PaperColor",
    active = {
        left = {
            {"mode", "paste"},
            {"gitbranch", "readonly", "filename", "modified"}
        }
    },
    component_function = {gitbranch = "FugitiveHead"},
    tabline = {left = {{"buffers"}}, right = {{}}},
    component_expand = {buffers = "lightline#bufferline#buffers"},
    component_type = {buffers = "tabsel"}
}
vim.opt.showtabline = 2
vim.g["lightline#bufferline#modified"] = " ★"
vim.g["lightline#bufferline#read_only"] = " "
