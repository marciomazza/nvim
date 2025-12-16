---@type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          -- commented out plugins dir to reduce latency of "gd"
          -- (possibly add specific plugins, when needed)
          -- vim.fn.stdpath("data") .. "/lazy",
        },
      },
      diagnostics = { globals = { "vim" } },
    },
  },
}
