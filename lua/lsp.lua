local pre_format_hooks = {
  ruff = function()
    -- fix all ruff detected errors
    vim.lsp.buf.code_action {
      filter = function(action) return action.kind == "source.fixAll.ruff" end,
      apply = true
    }
  end
}

local function lsp_format_on_save()
  local winview = vim.fn.winsaveview() -- saves cursor and scroll positions etc
  vim.lsp.buf.format {
    filter = function(client)
      if client.server_capabilities.documentFormattingProvider then
        local pre_format_hook = pre_format_hooks[client.name] or function() end
        pre_format_hook()
        return true
      end
    end
  }
  vim.fn.winrestview(winview) -- restores positions
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
  callback = lsp_format_on_save,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local bufopts = { noremap = true, silent = true, buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  end
})

vim.lsp.config("*", {
  root_markers = { "pyproject.toml", ".git", ".jj" },
})

vim.lsp.enable { "lua_ls", "ruff", "taplo", "djlsp", "jedi-language-server" }
