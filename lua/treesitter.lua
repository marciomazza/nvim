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
