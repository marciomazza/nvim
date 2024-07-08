local opts = { silent = true }
vim.keymap.set("n", "<C-l>", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "<C-j>", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<C-k>", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

local pre_format_hooks = {
  ruff = function()
    -- fix all ruff detected errors
    vim.lsp.buf.code_action {
      filter = function(action) return action.kind == "source.fixAll.ruff" end,
      apply = true
    }
  end
}

local lsp_format_on_save = function()
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

return {
  {
    "williamboman/mason.nvim",
    config = true
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "lua_ls", "jedi_language_server", "ruff", "htmx" }
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require "lspconfig"

      local plone = require "plone"

      lspconfig.util.on_setup =
          lspconfig.util.add_hook_before(
            lspconfig.util.on_setup,
            function(config)
              local plone_config = plone.get_plone_config()
              if plone_config ~= nil then
                config.root_dir = function()
                  return plone_config.root_dir
                end
                config.init_options = { workspace = { extraPaths = plone_config.extra_paths } }
              end
            end
          )

      local function on_attach(client, bufnr)
        -- set keymaps for LSP
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, bufopts)
      end

      lspconfig.lua_ls.setup { on_attach = on_attach }

      local capabilities = require "cmp_nvim_lsp".default_capabilities()
      -- for some strange reason jedi language server completion breaks if this is true
      -- TODO: investigate or report a bug
      capabilities.textDocument.completion.completionItem.snippetSupport = false

      lspconfig.jedi_language_server.setup {
        on_attach = on_attach,
        capabilities = capabilities
      }

      lspconfig.ruff.setup { on_attach = on_attach }
      lspconfig.htmx.setup { on_attach = on_attach, filetypes = { "html", "htmldjango" }
      }
    end
  },
}
