local utils = {}

function utils.set_keymap(mode, key, result)
  local options = { noremap = true, silent = true }
  return vim.api.nvim_set_keymap(mode, key, result, options)
end

-- format on save using lsp
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
function utils.register_lsp_format_on_save(client, bufnr, extra_operation)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd(
      "BufWritePre",
      {
        group = augroup,
        buffer = bufnr,
        callback = function()
          local winview = vim.fn.winsaveview() -- saves cursor and scroll positions etc
          vim.lsp.buf.format()
          if extra_operation ~= nil then
            extra_operation()
          end
          vim.fn.winrestview(winview) -- restores
        end
      }
    )
  end
end

return utils
