local register_lsp_format_on_save = require "utils".register_lsp_format_on_save

local opts = { silent = true }
vim.keymap.set("n", "<C-l>", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "<C-j>", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<C-k>", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

local function set_lsp_keymaps(bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)
  vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, bufopts)
end

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

      lspconfig.lua_ls.setup {
        on_attach = function(client, bufnr)
          register_lsp_format_on_save(client, bufnr)
          set_lsp_keymaps(bufnr)
        end
      }

      local capabilities = require "cmp_nvim_lsp".default_capabilities()
      -- for some strange reason jedi language server completion breaks if this is true
      -- TODO: investigate or report a bug
      capabilities.textDocument.completion.completionItem.snippetSupport = false

      lspconfig.jedi_language_server.setup {
        on_attach = function(_, bufnr)
          set_lsp_keymaps(bufnr)
        end,
        capabilities = capabilities
      }

      local ruff_execute_fix_all = function()
        vim.lsp.buf.code_action {
          filter = function(action)
            return action.kind == "source.fixAll.ruff"
          end,
          apply = true
        }
      end

      lspconfig.ruff.setup {
        on_attach = function(client, bufnr)
          register_lsp_format_on_save(client, bufnr, ruff_execute_fix_all)
          set_lsp_keymaps(bufnr)
        end
      }

      lspconfig.htmx.setup {
        on_attach = function(_, bufnr)
          set_lsp_keymaps(bufnr)
        end,
        filetypes = { "html", "htmldjango" }
      }
    end
  },
}
