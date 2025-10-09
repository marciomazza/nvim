--- Open URLs under cursor with go (supports GitHub shorthand)
vim.keymap.set("n", "go", function()
  local url = vim.fn.expand("<cfile>")
  -- Handle GitHub shorthand (e.g., "tpope/vim-surround")
  if url:match("^[%w-_]+/[%w-_.]+$") then
    url = "https://github.com/" .. url
  end
  vim.ui.open(url)
end, { desc = "Open URL under cursor" })
