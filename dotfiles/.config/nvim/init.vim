" Install vim-plug if not present
" https://raw.githubusercontent.com/junegunn/vim-plug/refs/heads/master/plug.vim
" nv --headless -es +silent! +'PlugInstall --sync' +qa

" Plugins
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'kshenoy/vim-signature'
Plug 'morhetz/gruvbox'
Plug 'petertriho/nvim-scrollbar'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'airblade/vim-rooter'
Plug 'airblade/vim-gitgutter'
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'jpalardy/vim-slime'
Plug 'goerz/jupytext.nvim'
call plug#end()

" Setup nvim scoll bar
lua require("scrollbar").setup({ handle = { blend = 10 } })

" Setup jupytext
lua require("jupytext").setup({ format = "py:percent" })

" Setup LSP
lua << EOF
-- Setup LSP servers
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local cmp = require('cmp')

-- C/C++ LSP
lspconfig.clangd.setup {
  capabilities = capabilities,
  cmd = { "clangd", "--background-index", "--clang-tidy" },
}

-- Python
lspconfig.jedi_language_server.setup { capabilities = capabilities, }

-- Setup autocompletion
cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<A-j>'] = cmp.mapping.scroll_docs(4),
    ['<A-k>'] = cmp.mapping.scroll_docs(-4),
    ['<S-Tab>'] = cmp.mapping.complete(),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { 
        name = 'buffer',
        option = {
            get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
            end
        },
    },
  },
}

-- Show diagnostics as virtual text
vim.diagnostic.config({
  virtual_text = true,
  signs = { priority = 15 },
  update_in_insert = false,
  float = { border = "rounded" }
})
EOF

" Set leader as space
nnoremap <SPACE> <Nop>
let mapleader=" "

" Set the color scheme
colorscheme gruvbox
let g:gruvbox_contrast_dark = 'soft'
let g:gruvbox_transparent_bg = 1
set background=dark
autocmd VimEnter * hi Normal ctermbg=NONE guibg=NONE

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Dont resize existing windows when a new ones are created or closed
set noea

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
set clipboard^=unnamed,unnamedplus

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
let g:markdown_fenced_languages = ['cpp', 'python', 'javascript', 'js=javascript', 'typescript', 'ts=typescript']
autocmd FileType markdown set conceallevel=0

" Set color scheme when using vimdiff
if &diff
    colorscheme slate
endif

" Matching parathensis are diff to distinguish
hi MatchParen cterm=none ctermbg=black ctermfg=blue

" Paste toggle keybind for pasting into vim
nnoremap <F2> :set paste!<CR>:set paste?<CR>

" Create function to scroll vim popups
function! ScrollPopup(nlines)
    for winid in nvim_list_wins()
        let config = nvim_win_get_config(winid)
        if get(config, 'relative', '') != ''
          let cmd = a:nlines > 0 ? 'normal! ' . a:nlines . "\<C-e>" : 'normal! ' . abs(a:nlines) . "\<C-y>"
          call win_execute(winid, cmd)
          return
        endif
    endfor
endfunction

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

" Disable mouse
set mouse=

" Unload buffer on close
set nohidden

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

" Open new vim terminal
nnoremap <leader>T :tab term bash<CR>
nnoremap <silent> <leader>tt :split <bar> terminal bash<CR>

" 'Zoom' a split window into a tab
nnoremap <leader>zz :tab sb<CR>

" Disable S-Tab in insert mode - we would be using it for autocomplete
inoremap <S-Tab> <Nop>

" Plugin shortcuts
nnoremap <C-n> :NERDTreeToggle<CR>

" XML Auto Indent
autocmd FileType xml setlocal equalprg=xmllint\ --format\ -

" Vim Signature - set dyn marking based on git
let g:SignatureMarkTextHLDynamic = 1

" Git gutter settings
let g:gitgutter_map_keys = 0
let g:gitgutter_sign_allow_clobber = 0
nnoremap gp :GitGutterPreviewHunk<CR>
nnoremap gs :GitGutterStageHunk<CR>
nnoremap gu :GitGutterUndoHunk<CR>
nnoremap ]g :GitGutterNextHunk<CR>
nnoremap [g :GitGutterPrevHunk<CR>
let g:gitgutter_floating_window_options = {
    \ 'relative': 'cursor', 'row': 1, 'col': 0,
    \ 'width': 42, 'height': &previewheight,
    \ 'style': 'minimal', 'border': 'rounded' 
\ }

" Vim rooter configs
let g:rooter_manual_only = 1
let g:rooter_cd_cmd = 'lcd'
let g:rooter_patterns = ['.git', '.svn', 'package.json', '!node_modules']
nnoremap cd :cd %:p:h<CR>:NERDTreeCWD<CR>:NERDTreeClose<CR>
nnoremap cD :Rooter<CR>:NERDTreeCWD<CR>:NERDTreeClose<CR>

" Scroll floating popups via Alt - J / K
nnoremap <silent> <A-j> :call ScrollPopup( 1)<CR>
nnoremap <silent> <A-k> :call ScrollPopup(-1)<CR>

" Nerd tree configs
let NERDTreeShowHidden = 1
let g:NERDTreeShowLineNumbers = 1
let g:NERDTreeMapOpenSplit = 's'
let g:NERDTreeMapOpenVSplit = 'i'
autocmd BufEnter NERD_* setlocal relativenumber

" Telescope for find and grep
nnoremap <leader>ff :lua require('telescope.builtin').find_files({ hidden = true })<CR>
nnoremap <leader>fs :lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>
nnoremap <leader>fS :lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>
nnoremap <leader>fb :lua require('telescope.builtin').buffers()<CR>
nnoremap <leader>fm :lua require('telescope.builtin').marks()<CR>
nnoremap <leader>fg :lua require('telescope.builtin').git_status()<CR>

" Shortcuts in Telescope preview
lua << EOF
local actions = require("telescope.actions")
local map = {
  ["<A-h>"] = actions.preview_scrolling_left,
  ["<A-l>"] = actions.preview_scrolling_right,
  ["<A-j>"] = actions.preview_scrolling_down,
  ["<A-k>"] = actions.preview_scrolling_up,
  ["<C-h>"] = actions.results_scrolling_left,
  ["<C-l>"] = actions.results_scrolling_right,
  ["<C-j>"] = actions.move_selection_next,
  ["<C-k>"] = actions.move_selection_previous,
  ["<C-d>"] = actions.delete_buffer,
}

require("telescope").setup {
  defaults = { mappings = { i = map, n = map, } }
}
EOF

" Custom mappings for LSP
nnoremap <silent> [e        :lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]e        :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> [E        :lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>
nnoremap <silent> ]E        :lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>
nnoremap <silent> <leader>e :lua vim.diagnostic.open_float()<CR>

" Configs for vim slime
let g:slime_target = "neovim"
let g:slime_python_ipython = 1
let g:slime_preserve_curpos = 0
let g:slime_menu_config = 4
nnoremap <silent><expr><leader>ll ":\<C-u>call slime#send_lines(" . v:count . ")\<cr>"
vnoremap <silent><leader>ll :<c-u>call slime#send_op(visualmode(), 1)<cr>

" Vim terminal mappings
tnoremap <expr> <C-w>" '<C-\><C-N>"'.nr2char(getchar()).'pi'
tnoremap <C-w> <C-\><C-N><C-w>
