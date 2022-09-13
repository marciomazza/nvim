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
  use 'tommcdo/vim-exchange'
  use 'editorconfig/editorconfig-vim'
  use 'farmergreg/vim-lastplace'  -- remember cursor position on file reopen
  use 'junegunn/vim-easy-align'

  -- utils
  use 'CrispyDrone/vim-tasks'

  -- files
  use 'junegunn/fzf'
  use 'vim-scripts/grep.vim'

  -- sidebars
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = require('sidebars').nvim_tree_config
  }
  use { 'preservim/tagbar', config = require('sidebars').tagbar_config }

  -- programming in general
  use 'jiangmiao/auto-pairs'
  use 'gaving/vim-textobj-argument'
  use 'chrisbra/Colorizer'
  use 'honza/vim-snippets'
  use 'dense-analysis/ale'
  use 'ajh17/VimCompletesMe'
  use 'cespare/vim-toml'
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}
  use 'jparise/vim-graphql'
  use 'github/copilot.vim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  -- python
  use {'raimon49/requirements.txt.vim', ft = {'requirements'}}
  -- temporaryly use my own local fork
  -- TODO probably revert back to 'davidhalter/jedi-vim' if and after PR is accepted
  -- https://github.com/davidhalter/jedi/pull/1879
  use {'~/repos/jedi-vim', ft = {'python'}}

  -- docker
  use 'ekalinin/Dockerfile.vim'

  -- aesthetics
  use 'luochen1990/rainbow'
  use 'itchyny/lightline.vim'
  use 'mengelbrecht/lightline-bufferline'
  use 'NLKNguyen/papercolor-theme'
end)

-- load sub config files
require('tuning')
require('aesthetics')
require('programming')
require('ale')
require('extras')
