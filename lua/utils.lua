local utils = {}

function utils.set_keymap(mode, key, result)
  options = { noremap = true, silent = true }
  return vim.api.nvim_set_keymap(mode, key, result, options)
end

return utils
