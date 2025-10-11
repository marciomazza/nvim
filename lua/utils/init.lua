local extended_ui_open = function()
  --- Open URLs under cursor with go (supports GitHub shorthand)
  local url = vim.fn.expand("<cfile>")
  -- Handle GitHub shorthand (e.g., "tpope/vim-surround")
  if url:match("^[%w-_]+/[%w-_.]+$") then
    url = "https://github.com/" .. url
  end
  vim.ui.open(url)
end
vim.keymap.set("n", "go", extended_ui_open, { desc = "Open URL under cursor" })

local source_current_lua_file = function()
  vim.cmd.write()
  vim.cmd.luafile("%")
end
vim.keymap.set("n", "<leader>l", source_current_lua_file, { desc = "Source current lua file" })

-- toggle spell check
for lang, key in pairs({ en_us = "<F6>", pt_br = "<F7>" }) do
  local toggle_spell_check = function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    vim.opt_local.spelllang = lang
  end
  local desc = string.format("Toggle spell check (%s)", lang:sub(1, 2):upper())
  vim.keymap.set("n", key, toggle_spell_check, { desc = desc })
end
