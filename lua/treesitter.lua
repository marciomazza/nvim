
-- Temporarily use my own treesitter dockerfile parser
-- TODO remove this once/if PR is accepted
-- https://github.com/camdencheek/tree-sitter-dockerfile/pull/24
--
-- this hack was also needed to get the parser to work
-- https://github.com/nvim-treesitter/nvim-treesitter/discussions/885#discussioncomment-320369
--
-- ln -s \
-- ~/repos/tree-sitter-dockerfile/queries \
-- ~/.local/share/nvim/site/pack/packer/start/nvim-treesitter/queries/dockerfile
--
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.dockerfile = {
  install_info = {
    url = "~/repos/tree-sitter-dockerfile",
    files = { "src/parser.c" },
  },
}

return {
  'nvim-treesitter/nvim-treesitter',
  run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  requires = {
    'p00f/nvim-ts-rainbow',
  },
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "python", "lua", "rust", "javascript", "sql" },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      rainbow = { enable = true }, -- enable nvim-ts-rainbow
    }
  end,
}
