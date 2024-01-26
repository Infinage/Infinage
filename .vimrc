" Plugins
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" Set the color scheme
colorscheme desert
set background=dark

" Matching parathensis are diff to distinguish
let g:loaded_matchparen=1

" Don't try to be vi compatible
set nocompatible

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2

" Highlight the searches
set hlsearch

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Turn on syntax highlighting
syntax on

" For plugins to load correctly
filetype plugin indent on

" Set numbering and relative numbering
set number relativenumber

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set noshiftround

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Use space characters instead of tabs.
set expandtab

" Ignore case while searching
set ignorecase

" Override the ignorecase option if searching for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Enable folding
set foldmethod=indent
set foldlevel=99

" Use System Clipboard
set clipboard=unnamedplus

" Speed up scrolling in Vim
set ttyfast 

" Autocomplete in command line
set wildmenu

" Split right and down first
set splitright splitbelow

" Search count
set shortmess-=S

" Set PWD to the file that vim is editing
set autochdir

" Set leader as space
nnoremap <SPACE> <Nop>
let mapleader=" "

" Remove newbie crutches in Command Mode
cnoremap <Down> <Nop>
cnoremap <Left> <Nop>
cnoremap <Right> <Nop>
cnoremap <Up> <Nop>

" Remove newbie crutches in Insert Mode
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
inoremap <Up> <Nop>

" Remove newbie crutches in Normal Mode
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
nnoremap <Up> <Nop>

" Remove newbie crutches in Visual Mode
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>
vnoremap <Up> <Nop>

" In insert or command mode, move normally by using Ctrl
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

" Resize splits with ctrl - hjkl
nnoremap <C-h> :vertical resize +1<CR>
nnoremap <C-l> :vertical resize -1<CR>
nnoremap <C-j> :resize +1<CR>
nnoremap <C-k> :resize -1<CR>

" Plugin shortcuts
nnoremap <C-p> :Files<Cr>
nnoremap <silent><leader>f :Rg<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <silent><leader>l :Buffers<CR>

" Set fzf to include hidden files
let $FZF_DEFAULT_COMMAND = 'rg --hidden --ignore .git -l -g ""'
