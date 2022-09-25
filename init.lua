set_keymap = require('utils').set_keymap

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- basic
  use 'tpope/vim-sensible'
  use 'tpope/vim-abolish'
  use 'tpope/vim-commentary'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'terryma/vim-multiple-cursors'
  use 'bogado/file-line'
  use 'tommcdo/vim-exchange'           -- TODO: check if this is still needed
  use 'editorconfig/editorconfig-vim'
  use 'farmergreg/vim-lastplace'       -- remember cursor position on file reopen
  use 'junegunn/vim-easy-align'

  -- utils
  use 'CrispyDrone/vim-tasks'

  -- files
  use 'junegunn/fzf'
  use 'vim-scripts/grep.vim'
  use (require('sidebars'))  -- nvim-tree & preservim/tagbar

  -- programming in general
  use 'jiangmiao/auto-pairs'
  use 'gaving/vim-textobj-argument'
  use 'dense-analysis/ale'
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}
  use {'github/copilot.vim', config = function()
    vim.g.copilot_filetypes = { gitcommit = true, markdown = true }
  end}
  use (require('treesitter'))
  use (require('nvim-cmp'))
  use 'neovim/nvim-lspconfig'

  -- python
  use {'raimon49/requirements.txt.vim', ft = {'requirements'}}

  -- appearance
  use 'itchyny/lightline.vim'
  use 'mengelbrecht/lightline-bufferline'
  use 'NLKNguyen/papercolor-theme'
  use 'folke/lsp-colors.nvim'

end)

-- load sub config files
require('tuning')
require('appearance')
require('lsp')
require('python')
require('ale')
require('extras')
