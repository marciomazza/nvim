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

" files
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-scripts/grep.vim'

" aesthetics
Plug 'luochen1990/rainbow'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'marciomazza/vim-brogrammer-theme'

" sidebars
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'majutsushi/tagbar', {'on': []}

" programming in general
Plug 'jiangmiao/auto-pairs'
Plug 'gaving/vim-textobj-argument'
Plug 'chrisbra/Colorizer'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'dense-analysis/ale'
Plug 'ervandew/supertab'

" python
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'fisadev/vim-isort', { 'for': 'python' }
Plug 'psf/black', { 'for': 'python' }

" golang
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

" load sub config files
source ~/.config/nvim/config/tuning.vim
source ~/.config/nvim/config/keys.vim
source ~/.config/nvim/config/files.vim
source ~/.config/nvim/config/aesthetics.vim
source ~/.config/nvim/config/sidebars.vim
source ~/.config/nvim/config/programming.vim
