" Plugins
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'jpalardy/vim-slime'
Plug 'kshenoy/vim-signature'
Plug 'goerz/jupytext.vim'
Plug 'vim-python/python-syntax'
Plug 'morhetz/gruvbox'
Plug 'dense-analysis/ale'
call plug#end()

" Set leader as space
nnoremap <SPACE> <Nop>
let mapleader=" "

" Set the color scheme
colorscheme gruvbox
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
set autoindent
set noshiftround
set colorcolumn=80
set textwidth=0
set wrapmargin=0
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Custom Whitespace Javascript, Typescript, HTML, JSON
augroup custom_indentation
    autocmd!
    autocmd Filetype javascript,typescript,html,json setlocal tabstop=2 shiftwidth=2 softtabstop=2
augroup END

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Ignore case while searching
set ignorecase

" Override the ignorecase option if searching for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Don't show the mode you are, on the last line
set noshowmode

" Enable folding
set foldmethod=manual
set foldlevel=99

" Use System Clipboard
set clipboard=unnamedplus

" Compat Disable screen flashing, backspace work as expected
set belloff=all
set backspace=eol,indent,start

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

" Auto close brackets (quotes, paranthesis, etc)
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O
inoremap <expr> ) strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
inoremap <expr> } strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
inoremap <expr> ] strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"

" Support python inside markdown
let g:markdown_fenced_languages = ['python', 'javascript', 'js=javascript', 'typescript', 'ts=typescript']
autocmd FileType markdown set conceallevel=0
let g:jupytext_fmt='py:percent'

" Create .ipynb with skeleton
if empty(glob("~/.vim/templates/skeleton.ipynb"))
    call mkdir($HOME . "/.vim/templates", "p")
    silent !curl --no-progress-meter -o ~/.vim/templates/skeleton.ipynb https://raw.githubusercontent.com/Infinage/Infinage/main/others/vim-templates/skeleton.ipynb
endif
function! CreateJupyterNotebook()
    let currpath = fnamemodify(expand('%:p:h'), ':p') .. 'untitled.ipynb'
    let nbpath = input("Enter new notebook path: ", currpath)
    if !empty(nbpath)
        silent execute "!cp ~/.vim/templates/skeleton.ipynb " . nbpath
        redraw!
    endif
endfunction
nnoremap <leader>nb :call CreateJupyterNotebook()<CR>

" Set color scheme when using vimdiff
if &diff
    colorscheme slate
endif

" Matching parathensis are diff to distinguish
hi MatchParen cterm=none ctermbg=black ctermfg=blue

" Paste toggle keybind for pasting into vim
" https://vim.fandom.com/wiki/Toggle_auto-indenting_for_code_paste
set pastetoggle=<F2>

" WSL specific changes
let uname = substitute(system('uname'),'\n','','')
if uname == 'Linux'
    let versionfile = "/proc/version"
    let lines = filereadable(versionfile) ? readfile(versionfile): []
    if !empty(lines) && lines[0] =~ "Microsoft"
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

" Clear marks and search highlights
nnoremap <leader>cm :delm a-zA-Z0-9<CR>
nnoremap <leader>cc :nohl<CR>

" Open terminal in a new tab
nnoremap <leader>tt :tab term bash<CR>

" 'Zoom' a split window into a tab
nnoremap <leader>zz :tab sb<CR>

" Disable S-Tab in insert mode - we would be using it for autocomplete
inoremap <S-Tab> <Nop>

" Plugin shortcuts
nnoremap <C-n> :NERDTreeToggle<CR>

" XML Auto Indent
autocmd FileType xml setlocal equalprg=xmllint\ --format\ -

" Nerd tree configs
let NERDTreeShowHidden = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeMapOpenSplit = 's'
let g:NERDTreeMapOpenVSplit = 'i'
autocmd BufEnter NERD_* setlocal relativenumber

" Configs for vim slime
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
let g:slime_preserve_curpos = 0
nnoremap <silent><expr><leader>ll ":\<C-u>call slime#send_lines(" . v:count . ")\<cr>"
vnoremap <silent><leader>ll :<c-u>call slime#send_op(visualmode(), 1)<cr>

" Configs for ALE
" Create .clangd file into '~/.config/clangd/config.yaml' - MANUAL
let g:ale_python_pylint_auto_pipenv = 1
let g:ale_linters = {'c': ['clangd', 'gcc'], 'cpp': ['clangd', 'gcc'], 'python': ['mypy', 'jedils'], 'javascript': ['eslint'], 'typescript': ['eslint', 'tsserver'], 'sh': ['shellcheck']}
let g:ale_fixers = {'c': ['clangd', 'gcc'], 'cpp': ['clangd', 'gcc'], 'python': ['black'], 'javascript': ['eslint'], 'typescript': ['eslint']}
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let cpp_opts = '-std=c++20 -Wall -Wextra'
let g:ale_cpp_cc_options = cpp_opts
let g:ale_cpp_gcc_options = cpp_opts
set omnifunc=ale#completion#OmniFunc
set completeopt=noinsert,menuone,noselect
highlight ALEError cterm=italic
imap <S-Tab> <Plug>(ale_complete)
nnoremap K :ALEHover<CR>
nnoremap <leader>d :ALEGoToDefinition -split<CR>
nnoremap <leader>n :ALEFindReferences<CR>
