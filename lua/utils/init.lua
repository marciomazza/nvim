local M = {}

function M.open_url()
  --- Open URLs under cursor with go (supports GitHub shorthand)
  local url = vim.fn.expand("<cfile>")
  -- Handle GitHub shorthand (e.g., "tpope/vim-surround")
  if url:match("^[%w-_]+/[%w-_.]+$") then url = "https://github.com/" .. url end
  vim.ui.open(url)
end
vim.keymap.set("n", "go", M.open_url, { desc = "Open URL under cursor" })

---@param spec_name string
---@param callback fun(ev: { data: vim.event.packchanged.data })
local function pack_changed_hook(spec_name, callback)
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      local name, kind = ev.data.spec.name, ev.data.kind
      if spec_name == name and (kind == "install" or kind == "update") then callback(ev) end
    end,
  })
end

_G.pack_changed_hook = pack_changed_hook

function M.find_sublist(list, sublist)
  for i = 1, #list - #sublist + 1 do
    local match = true
    for j, s in ipairs(sublist) do
      if list[i + j - 1] ~= s then
        match = false
        break
      end
    end
    if match then return i end
  end
end

function M.move_sublist(list, sublist, to_index)
  local src = M.find_sublist(list, sublist)
  if not src then return end
  for j = 1, #sublist do
    table.insert(list, to_index + j - 1, table.remove(list, src + j - 1))
  end
end

local source_current_lua_file = function()
  vim.cmd.write()
  vim.cmd.luafile("%")
end
vim.keymap.set("n", "<leader>l", source_current_lua_file, { desc = "Source current lua file" })

-- toggle / switch spell check language
for lang, key in pairs({ en_us = "<F6>", pt_br = "<F7>" }) do
  local toggle_spell_check = function()
    local current = vim.wo.spell and vim.bo.spelllang or ""
    if current == lang then
      vim.wo.spell = false
    else
      vim.wo.spell = true
      vim.bo.spelllang = lang
    end
  end
  local desc = string.format("Switch spell check to %s", lang:sub(1, 2):upper())
  vim.keymap.set("n", key, toggle_spell_check, { desc = desc })
end

-- Ctrl+g: also copy file path
vim.keymap.set("n", "<C-g>", function()
  vim.fn.setreg("+", vim.api.nvim_buf_get_name(0))
  vim.cmd("file")
end, { desc = "Show file info and copy it's path to clipboard" })

return M
