call plug#begin()

" basic
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'terryma/vim-multiple-cursors'
Plug 'bogado/file-line'
Plug 'tommcdo/vim-exchange'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'editorconfig/editorconfig-vim'

" utils

Plug 'CrispyDrone/vim-tasks'
""" TODO run this only on CrispyDrone/vim-tasks context
""" for https://github.com/CrispyDrone/vim-tasks#add-tasks
let maplocalleader="\<space>"
""" no time marks for @done
let g:TasksDateFormat = ''

" files
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-scripts/grep.vim'

" sidebars
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'preservim/tagbar'

" programming in general
Plug 'jiangmiao/auto-pairs'
Plug 'gaving/vim-textobj-argument'
Plug 'chrisbra/Colorizer'
Plug 'honza/vim-snippets'
Plug 'dense-analysis/ale'
Plug 'ajh17/VimCompletesMe'
Plug 'cespare/vim-toml'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'editorconfig/editorconfig-vim'
Plug 'jparise/vim-graphql'
Plug 'github/copilot.vim'

" python
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}
" temporaryly use my own local fork
" TODO probably revert back to 'davidhalter/jedi-vim' if and after PR is accepted
" https://github.com/davidhalter/jedi/pull/1879
Plug '~/repos/jedi-vim', { 'for': 'python' }

" golang
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" docker
Plug 'ekalinin/Dockerfile.vim'

" aesthetics
Plug 'luochen1990/rainbow'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'marciomazza/vim-brogrammer-theme'
"" vim-devicons must go last (according to install instructions)
Plug 'ryanoasis/vim-devicons'

call plug#end()

" load sub config files
source ~/.config/nvim/config/tuning.vim
source ~/.config/nvim/config/keys.vim
source ~/.config/nvim/config/files.vim
source ~/.config/nvim/config/aesthetics.vim
source ~/.config/nvim/config/sidebars.vim
source ~/.config/nvim/config/programming.vim
