vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", function()
      local pytest_clients = vim.lsp.get_clients({ bufnr = 0, name = "pytest_lsp" })
      if #pytest_clients > 0 then
        local client = pytest_clients[1]
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
        client:request("textDocument/definition", params, function(err, result)
          local has_result = not err
            and result
            and type(result) == "table"
            and (result.uri ~= nil or #result > 0)
          if has_result then
            local loc = vim.islist(result) and result[1] or result
            vim.lsp.util.show_document(loc, client.offset_encoding, { focus = true })
          else
            vim.lsp.buf.definition({ filter = function(c) return c.name ~= "pytest_lsp" end })
          end
        end, 0)
        return
      end

      -- ts_ls: prefer project-local implementation over the .d.ts type declaration
      local ts_clients = vim.lsp.get_clients({ bufnr = 0, name = "ts_ls" })
      if #ts_clients > 0 then
        local client = ts_clients[1]
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
        client:request("textDocument/implementation", params, function(_, result)
          if not result then
            vim.lsp.buf.definition()
            return
          end
          local results = vim.islist(result) and result or { result }
          if #results == 0 then
            vim.lsp.buf.definition()
            return
          end
          -- Pick the first result inside cwd; otherwise the first non-`node_modules`; otherwise the first
          local cwd = vim.uv.cwd() or ""
          local pick
          for _, loc in ipairs(results) do
            local path = vim.uri_to_filepath(loc.uri or "")
            if path:sub(1, #cwd) == cwd then
              pick = loc
              break
            end
          end
          pick = pick or vim.tbl_filter(function(loc)
            return not vim.uri_to_filepath(loc.uri or ""):match("/node_modules/")
          end, results)[1] or results[1]
          vim.lsp.util.show_document(pick, client.offset_encoding, { focus = true })
        end, 0)
        return
      end

      vim.lsp.buf.definition()
    end, { buffer = ev.buf, desc = "Go to definition" })
  end,
})

vim.lsp.enable("pytest_lsp")
vim.lsp.enable("cotton")

require("mason").setup({ npm = { ["min-release-age"] = 3 } })
require("mason-lspconfig").setup({
  ensure_installed = {
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    "stylua",
    "ruff",
    "pyrefly",
    "lua_ls",
    "tombi",
    "tailwindcss",
    "cssls",
    "djlsp",
    "ts_ls",
    "oxfmt",
    "oxlint",
    -- xxx disabled until a new release is made. 0.2.0 is broken and breaks other lsps hover and completion
    -- "htmx",
    "bashls",
  },
})
