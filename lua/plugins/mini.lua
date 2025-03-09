local COMMENTSTRINGS = {
  sql = "-- %s",
  htmldjango = "{# %s #}",
}

return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.ai").setup()
    require("mini.align").setup()
    require("mini.comment").setup {
      options = {
        custom_commentstring = function()
          return COMMENTSTRINGS[vim.bo.filetype] or nil
        end,
      }
    }
    require("mini.operators").setup()
    require("mini.pairs").setup()
    require("mini.surround").setup()
    require("mini.jump").setup()
    require("mini.splitjoin").setup()
  end,
}
