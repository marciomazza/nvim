return {

  -- basic
  "tpope/vim-sensible",
  "tpope/vim-abolish",
  "tpope/vim-commentary",
  "tpope/vim-fugitive",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "terryma/vim-multiple-cursors",
  "tommcdo/vim-exchange",     -- TODO: check if this is still needed
  "farmergreg/vim-lastplace", -- remember cursor position on file reopen
  "junegunn/vim-easy-align",

  -- utils
  "CrispyDrone/vim-tasks",

  -- files
  "junegunn/fzf",
  "vim-scripts/grep.vim",

  -- programming in general
  "jiangmiao/auto-pairs",
  "gaving/vim-textobj-argument",
  "dense-analysis/ale",
  { "iamcco/markdown-preview.nvim", run = "cd app && yarn install", cmd = "MarkdownPreview" },
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_filetypes = { gitcommit = true, markdown = true }
    end
  },

  -- lsp
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

  -- appearance
  "itchyny/lightline.vim",
  "mengelbrecht/lightline-bufferline",
  "NLKNguyen/papercolor-theme",
  "folke/lsp-colors.nvim",
}
