-- Django Cotton language server
---@type vim.lsp.Config
return {
  cmd = {
    "node",
    vim.fn.expand("~/repos/cotton-vscode-ext/packages/language-server/out/server.js"),
    "--stdio",
  },
  filetypes = { "html", "htmldjango" },
  root_markers = { "manage.py", "pyproject.toml", ".git", "cotton.config.json" },
}
