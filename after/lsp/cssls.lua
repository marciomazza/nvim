-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/cssls.lua
---@type vim.lsp.Config
return {
  on_attach = function(client, _)
    -- cssls corrupts Tailwind v4 at-rules (@source/@plugin/@layer) and injects
    -- the compiled stylesheet (daisyUI banner) when used as format fallback.
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
