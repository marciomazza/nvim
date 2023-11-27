--- extend "gx" to add github missing prefix
local function custom_netrw_BrowseX()
  -- based on netrwPlugin.vim
  --   see
  --   /usr/share/nvim/runtime/plugin/netrwPlugin.vim
  --   /usr/share/nvim/runtime/autoload/netrw.vim
  local filename = vim.fn["netrw#GX"]() -- gets filename under cursor for netrw

  -- if filename matches a relative github path (like "tpope/vim-surround")
  if string.match(filename, "^([^/]+/[^/]+)$") then
    filename = "https://github.com/" .. filename -- adds github prefix
  end

  -- "gx" originally calls <Plug>NetrwBrowseX, that is:
  --   netrw#BrowseX(netrw#GX(),netrw#CheckIfRemote(netrw#GX()))<cr>
  local check_if_remote = vim.fn["netrw#CheckIfRemote"]
  vim.fn["netrw#BrowseX"](filename, check_if_remote(filename))
end

vim.keymap.set("n", "gx", custom_netrw_BrowseX)
