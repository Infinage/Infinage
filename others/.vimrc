" Plugins
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jpalardy/vim-slime'
Plug 'goerz/jupytext.vim'
Plug 'davidhalter/jedi-vim'
Plug 'vim-python/python-syntax'
call plug#end()

" Set the color scheme
colorscheme slate
set background=dark

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
let python_highlight_all = 1

" For plugins to load correctly
filetype plugin indent on

" Set numbering and relative numbering
set number relativenumber

" Whitespace
set wrap
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

" Don't show the mode you are on the last line
" required for jedi-vim for show non intrusive show signatures
set noshowmode

" Enable folding
set foldmethod=manual
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

" Set color scheme when using vimdiff
if &diff
    colorscheme elflord
endif

" Matching parathensis are diff to distinguish
hi MatchParen cterm=none ctermbg=black ctermfg=blue

" Paste toggle keybind for pasting into vim
" https://vim.fandom.com/wiki/Toggle_auto-indenting_for_code_paste
set pastetoggle=<F2>

" WSL specific changes
let uname = substitute(system('uname'),'\n','','')
if uname == 'Linux'
    let lines = readfile("/proc/version")
    if lines[0] =~ "Microsoft"

        " WSL yank support
        let s:clip = '/mnt/c/Windows/System32/clip.exe'  
        if executable(s:clip)
            augroup WSLYank
                    autocmd!
                    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif 
            augroup END
        endif

    endif
endif

" Set leader as space
nnoremap <SPACE> <Nop>
let mapleader=" "

" Remove newbie crutches in Command, Insert, Normal & Visual Mode
cnoremap <Down> <Nop>
cnoremap <Left> <Nop>
cnoremap <Right> <Nop>
cnoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
inoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
nnoremap <Up> <Nop>
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
nnoremap <C-h> :vertical resize -1<CR>
nnoremap <C-l> :vertical resize +1<CR>
nnoremap <C-k> :resize -1<CR>
nnoremap <C-j> :resize +1<CR>

" Plugin shortcuts
nnoremap <C-p> :Files<Cr>
nnoremap <silent><leader>f :Rg<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <silent><leader>l :Buffers<CR>

" Set fzf to include hidden files
let $FZF_DEFAULT_COMMAND = 'rg --hidden --ignore .git -l -g ""'

" Configs for vim slime
let g:slime_target = "tmux"
let g:slime_python_ipython = 1

" Configs for Jedi
let g:jedi#popup_on_dot = 0
let g:jedi#completions_command = "<S-Tab>"
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#show_call_signatures = 2