" Install vim-plug if not present
" https://raw.githubusercontent.com/junegunn/vim-plug/refs/heads/master/plug.vim
" nv --headless -es +silent! +'PlugInstall --sync' +qa

" Plugins
call plug#begin()
Plug 'stevearc/oil.nvim'
Plug 'chentoast/marks.nvim'
Plug 'morhetz/gruvbox'
Plug 'nvim-lua/plenary.nvim'
Plug 'airblade/vim-rooter'
Plug 'airblade/vim-gitgutter'
Plug 'ibhagwan/fzf-lua'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'jpalardy/vim-slime'
Plug 'goerz/jupytext.nvim'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-fugitive'
call plug#end()

" Setup oil nvim
lua << EOF
local oil = require("oil")
oil.setup({
  columns = { "icon", "permissions", "size", "mtime" },
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["!"] = "actions.open_terminal",
    ["<C-Y>"] = "actions.yank_entry",
    ["<C-y>"] = { 
        callback = function()
            local entry = oil.get_cursor_entry()
            local dir = oil.get_current_dir()
            if not entry or not dir then return end
            vim.fn.setreg("+", vim.fn.fnamemodify(dir, ":.") .. entry.name)
        end,
        desc = "Copy relative file path of current entry",
    },
  }
})

-- Keymap to open Oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory of current buffer in Oil" })
vim.keymap.set("n", "~", "<CMD>Oil .<CR>", { desc = "Open CWD in Oil" })
EOF

" Setup jupytext
lua require("jupytext").setup({ format = "py:percent" })

" Setup marks.nvim
lua << EOF
local marks = require("marks")

-- Delete all numbered bookmarks (0–9)
function _G.DeleteAllBookmarks()
    for i = 0, 9 do
        pcall(function() marks["delete_bookmark" .. tostring(i)]() end)
    end
end

marks.setup {
  default_mappings = true,
  signs = true,
  mappings = {
    toggle = "m`",
    next_bookmark = "]~",
    prev_bookmark = "[~",
    annotate = "<leader>ba"
  }
}
EOF

" Setup LSP
lua << EOF
-- Setup LSP servers
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local cmp = require('cmp')

-- C/C++ LSP
lspconfig.clangd.setup {
  capabilities = capabilities,
  cmd = { 
    "clangd", "--background-index", "--clang-tidy", "-j=8", 
    "--pch-storage=memory", "--malloc-trim", "--limit-references=100",
    "--limit-results=20",
  },
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

" Status line with Git Status, rel filename, File type, Row, Col, Percent
set statusline=\ %{FugitiveHead()!=''?'['.FugitiveHead().']\ ':''}%f\ %M\ %Y\ %R%=\ Row:\ %l\ Col:\ %c\ Percent:\ %p%%\ 

" Show the status on the second to last line.
set laststatus=2

" Highlight the searches
set hlsearch

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Set numbering and relative numbering
set number relativenumber

" Always use unix line endings on save
set fileformat=unix

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
    autocmd Filetype javascript,typescript,html,json,vim setlocal tabstop=2 shiftwidth=2 softtabstop=2
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
"let g:clipboard = "termux"

" Compat Disable screen flashing, backspace work as expected
set belloff=all
set backspace=eol,indent,start

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

" Clear marks, bookmarks and search highlights
nnoremap <leader>cm :delm a-zA-Z0-9<CR>
nnoremap <leader>cM :lua DeleteAllBookmarks()<CR>
nnoremap <leader>cc :nohl<CR>
nnoremap <leader>fB :lua FZFBookmarksList()<CR>

" Vim terminal related keybinds
nnoremap <silent><leader>T :tabnew <bar> terminal bash<CR>
nnoremap <silent> <leader>tt :split <bar> terminal bash<CR>
nnoremap <silent> <leader>tv :vsplit <bar> terminal bash<CR>
tnoremap <ESC> <C-\><C-n>
tnoremap <expr> <C-w>" '<C-\><C-N>"'.nr2char(getchar()).'pi'
tnoremap <C-w> <C-\><C-N><C-w>

" 'Zoom' a split window into a tab
nnoremap <leader>zz :tab sb<CR>

" Newer and colder quickfix list mapping
nnoremap ]f :cnewer<CR>
nnoremap [f :colder<CR>

" Disable S-Tab in insert mode - we would be using it for autocomplete
inoremap <S-Tab> <Nop>

" Formatters for XML, JSON, SQL
augroup formatters
  autocmd!
  autocmd FileType xml setlocal equalprg=xmllint\ --format\ -
  autocmd FileType json setlocal equalprg=jq\ .
  autocmd FileType sql setlocal equalprg=sqlformat\ --reindent\ --keywords\ upper\ --identifiers\ lower\ -
augroup END

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

" Fugitive keybinds
nnoremap <leader>gd :Gvdiffsplit!<CR>
nnoremap <leader>gD :G! difftool<CR>
nnoremap <leader>gl :0Gllog<CR>

" Vim rooter configs
let g:rooter_manual_only = 1
let g:rooter_cd_cmd = 'lcd'
let g:rooter_patterns = ['.git', '.svn', 'package.json', '!node_modules']
nnoremap cd :cd %:p:h<CR>
nnoremap cD :Rooter<CR>

" Scroll floating popups via Alt - J / K
nnoremap <silent> <A-j> :call ScrollPopup( 1)<CR>
nnoremap <silent> <A-k> :call ScrollPopup(-1)<CR>

" Shortcuts for FZF-Lua
lua << EOF
local fzf = require("fzf-lua")

fzf.setup({
  git = {
    commits = {
      preview = "git show --color --stat --format= {1}",
      winopts = {
        preview = {
          layout = "vertical",
          horizontal = "right:40%",
          vertical = "down:40%",
          hidden = false
        },
      },
    },
    bcommits = {
        fzf_args="--multi",
        actions = {
          ["ctrl-q"] = function(selected)
            if not selected or #selected == 0 then return end
            local current_file = vim.api.nvim_buf_get_name(0)
            if current_file == "" then
              vim.notify("Not in a file buffer to see its commits", vim.log.levels.WARN)
              return
            end

            local commits = {}
            for _, entry in ipairs(selected) do
              local hash = entry:match("^%x+")
              if hash then table.insert(commits, hash) end
            end

            if #commits > 0 then
              local cmd = string.format("silent! Gclog %s -- %s", table.concat(commits, " "), current_file)
              vim.cmd(cmd) vim.cmd("copen")
            end
          end,

          ["ctrl-d"] = function(...)
            fzf.actions.git_buf_vsplit(...)
            vim.cmd("windo diffthis | wincmd h")
          end,
        },
    },
  },
  winopts = {
    preview = {
      layout = "vertical",
      vertical = "down:60%",
      horizontal = "right:60%",
      wrap = true,
      scrollbar = "float",
      default = "bat",
      hidden = true,
    },
  },
  keymap = {
      fzf = {
        ["Alt-j"] = "preview-page-down",
        ["Alt-k"] = "preview-page-up",
        ["ctrl-f"] = "half-page-down",
        ["ctrl-b"] = "half-page-up",
        ["ctrl-q"] = "select-all+accept",
        ["f3"]     = "toggle-preview-wrap",
        ["ctrl-l"] = "forward-char",
        ["ctrl-h"] = "backward-char",
      },
  },
})

-- Function to feed marks.nvim bookmarks list output to fzf
function _G.FZFBookmarksList()
  -- Run the Vim command to populate the location list
  vim.cmd("BookmarksListAll")
  local loclist = vim.fn.getloclist(0)
  vim.cmd("lclose")

  -- Grab the entries from the location list
  if vim.tbl_isempty(loclist) then
    vim.notify("No bookmarks found", vim.log.levels.WARN) return
  end

  -- Convert loclist items into strings for fzf
  local entries = vim.tbl_map(function(item)
    local fname = vim.fn.bufname(item.bufnr)
    local text = vim.trim(item.text or "")
    return string.format("%s:%d: %s", fname, item.lnum, text)
  end, loclist)

  -- Configure fzf-lua picker
  local opts = require("fzf-lua.config").normalize_opts({
    prompt = "Bookmarks> ",
    actions = {
      ["default"] = function(selected)
        if #selected == 1 then
          local fname, lnum = selected[1]:match("^(.-):(%d+):")
          if fname and lnum then
            vim.cmd("edit " .. fname)
            vim.fn.cursor(tonumber(lnum), 1)
          end
        else
          local newlist = {}
          for _, entry in ipairs(selected) do
            local fname, lnum, text = entry:match("^(.-):(%d+):%s*(.*)")
            if fname and lnum then
              table.insert(newlist, { filename = fname, lnum = tonumber(lnum), text = text, })
            end
          end

          if not vim.tbl_isempty(newlist) then
            vim.fn.setloclist(0, newlist, "r")
            vim.cmd("lopen")
          end
        end
      end,
    },
  }, "files")

  fzf.fzf_exec(entries, opts)
end
EOF

" FZF for find and grep
nnoremap <leader>fb :lua require('fzf-lua').buffers()<CR>
nnoremap <leader>ff :lua require('fzf-lua').files()<CR>
nnoremap <leader>fs :lua require('fzf-lua').blines()<CR>
nnoremap <leader>fS :lua require('fzf-lua').live_grep_native()<CR>
nnoremap <leader>fm :lua require('fzf-lua').marks()<CR>
nnoremap <leader>fg :lua require('fzf-lua').git_bcommits()<CR>
vnoremap <leader>fg <cmd>FzfLua git_bcommits<CR>
nnoremap <leader>fG :lua require('fzf-lua').git_commits()<CR>
nnoremap <leader>fz :lua require('fzf-lua').builtin()<CR>

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

" Add linter for extra 
let g:ale_set_loclist = 0
let g:ale_linters = { 'cpp': ['cc'] }
let cpp_opts = '-std=c++23 -Wall -Weffc++ -Wextra -Wpedantic -pedantic-errors -L/home/kael/cpplib/lib -I/home/kael/cpplib/include'
let g:ale_cpp_cc_options = cpp_opts
let g:ale_floating_preview = 1
nnoremap <leader>ad :ALEDetail<CR>
