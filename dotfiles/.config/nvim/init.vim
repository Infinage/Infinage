" Install vim-plug if not present
" https://raw.githubusercontent.com/junegunn/vim-plug/refs/heads/master/plug.vim
" nv --headless -es +silent! +'PlugInstall --sync' +qa

" Plugins
call plug#begin()
Plug 'stevearc/oil.nvim'
Plug 'morhetz/gruvbox'
Plug 'nvim-lua/plenary.nvim'
Plug 'airblade/vim-rooter'
Plug 'airblade/vim-gitgutter'
Plug 'ibhagwan/fzf-lua'
Plug 'hrsh7th/nvim-cmp'
Plug 'neovim/nvim-lspconfig'
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
    ["`"] = false,
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

" Setup LSP
lua << EOF
-- Setup LSP servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local cmp = require('cmp')

-- C/C++ LSP
vim.lsp.config('clangd', {
  capabilities = capabilities,
  cmd = { 
    "clangd", "--background-index", "--clang-tidy", "-j=8", 
    "--pch-storage=memory", "--malloc-trim", "--limit-references=100",
    "--limit-results=20",
  },
})

-- Python
vim.lsp.config('jedi_language_server', { capabilities = capabilities, })

-- Enable both LSP configs
vim.lsp.enable('clangd', 'jedi_language_server')

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

" Clear marks for current buffer and search highlights
nnoremap <leader>cm :delm a-z<CR>
nnoremap <leader>cM :delm a-zA-Z<CR>
nnoremap <leader>cc :nohl<CR>

" Vim terminal related keybinds
nnoremap <silent><leader>T :tabnew <bar> terminal bash<CR>
nnoremap <silent> <leader>tt :split <bar> terminal bash<CR>
nnoremap <silent> <leader>tv :vsplit <bar> terminal bash<CR>
tnoremap <ESC> <C-\><C-n>
tnoremap <expr> <C-w>" '<C-\><C-N>"'.nr2char(getchar()).'pi'
tnoremap <C-w> <C-\><C-N><C-w>

" 'Zoom' a split window into a tab
nnoremap <leader>zz :tab sb<CR>

" Disable S-Tab in insert mode - we would be using it for autocomplete
inoremap <S-Tab> <Nop>

" Formatters for XML, JSON, SQL
augroup formatters
  autocmd!
  autocmd FileType xml setlocal equalprg=xmllint\ --format\ -
  autocmd FileType json setlocal equalprg=jq\ .
  autocmd FileType sql setlocal equalprg=sqlformat\ --reindent\ --keywords\ upper\ --identifiers\ lower\ -
augroup END

" Assocating file type to extensions
augroup ftdetect
  autocmd!
  autocmd BufRead,BufNewFile *.log* set filetype=log
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
nnoremap <leader>gd :Ghdiffsplit!<CR>
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
  grep = {
    actions = {
      ["alt-n"] = {
        fn = function(_, opts)
          require("fzf-lua").actions.toggle_flag(_, vim.tbl_extend("force", opts, {
            toggle_flag = "--multiline --multiline-dotall"
          }))
        end,
        desc = "Toggle multiline search",
      },
    },
  },
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
            fzf.actions.git_buf_split(...)
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
EOF

" FZF for find and grep
nnoremap <leader>fb :lua require('fzf-lua').buffers()<CR>
nnoremap <leader>ff :lua require('fzf-lua').files()<CR>
nnoremap <leader>fs :lua require('fzf-lua').blines()<CR>
vnoremap <leader>fs <cmd>FzfLua blines<CR>
nnoremap <leader>fS :lua require('fzf-lua').live_grep_native()<CR>
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

lua << EOF
-- Create a helper for safely renaming unnamed + terminal buffers
vim.api.nvim_create_user_command("RenameBuf", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[buf].buftype
  local name = opts.args

  -- Some edge cases
  if name == "" then 
    vim.notify("A new name is required.", vim.log.levels.ERROR) 
    return 
  end

  -- Skip renaming if it's a real file buffer
  if vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 1 then
    print("Skipping Rename: buffer is tied to a real file.")
    return
  end

  vim.api.nvim_buf_set_name(buf, name)
end, { nargs = 1, desc = "Safely renames unnamed or terminal buffers.", })

-- Setup an alias for above function
vim.cmd("command! -nargs=+ Rb RenameBuf <args>")

-- Copy current file + line to clipboard
local function copy_file_and_line_to_clipboard()
  local filepath = vim.fn.expand("%:p")
  local linenum = vim.fn.line(".")
  local text = filepath .. ":" .. linenum
  vim.fn.setreg("+", text)
  vim.api.nvim_echo({ { "Copied: " .. text, "None" } }, false, {})
end

-- Setup alias for above function
vim.api.nvim_create_user_command("Where", function()
  copy_file_and_line_to_clipboard()
end, {})
EOF

" Navigate across files using jump list
function! JumpToNextBufferInJumplist(dir) " 1=forward, -1=backward
    let jl = getjumplist()
    let jumplist = jl[0]
    let curjump = jl[1]

    let jumpcmdstr = a:dir > 0 ? '<C-i>' : '<C-o>'
    let jumpcmdchr = a:dir > 0 ? "\<C-i>" : "\<C-o>"
    let searchrange = a:dir > 0? range(curjump+1, len(jumplist)): range(curjump-1, 0, -1)

    let found = 0
    for i in searchrange
        if i < len(jumplist) && jumplist[i]["bufnr"] != bufnr('%')
            let n = (i - curjump) * a:dir
            execute "silent normal! " . n . jumpcmdchr
            let found = 1
            break
        endif
    endfor

  if !found 
    echohl WarningMsg | echom "No other jump locations available" | echohl None
  endif
endfunction

" Jump multiple files from jump list
nnoremap <silent>]f :call JumpToNextBufferInJumplist( 1)<CR>
nnoremap <silent>[f :call JumpToNextBufferInJumplist(-1)<CR>

" Toggle bookmark on the current line
function! ToggleBookmark()
  let l:marks = getmarklist()
  let l:taken = []

  " Collect all uppercase marks
  for m in l:marks
    let mchar = m['mark'][1]
    let mark_file_abs = m['file'] !=# ''? fnamemodify(m['file'], ':p'): ''

    " Only consider uppercase marks A-Z
    if !(char2nr(mchar) >= char2nr('A') && char2nr(mchar) <= char2nr('Z'))
        continue
    endif

    " If current line already has an uppercase mark toggle it off
    call add(l:taken, mchar)
    if m['pos'][1] == line('.') && mark_file_abs ==# expand('%:p')
      execute 'delmarks ' . mchar
      echohl None | echom "Bookmark removed"
      return
    endif
  endfor

  " Compute available uppercase marks and place first one
  let l:available = filter(map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)'), 'index(l:taken, v:val) == -1')
  if !empty(l:available)
      execute 'mark ' . l:available[0]
      echohl None | echom "Line bookmarked"
  else
      echohl WarningMsg | echom "No marks available" | echohl NONE
  endif
endfunction

" Populate all global bookmarks to a quickfix list
function! GlobalMarksToQuickfix()
  let l:qf = []

  for m in getmarklist()
    let mark = m['mark'][1]
    let file = get(m, 'file', '')
    let pos  = get(m, 'pos', [])

    " Only uppercase global marks
    if matchstr(mark, '^[A-Z]$') != ''
      call add(l:qf, {
            \ 'filename': file == ''? file: fnamemodify(file, ':p'),
            \ 'lnum': get(pos, 1, 0),
            \ 'col': get(pos, 2, 0),
            \ 'text': 'Mark ' . mark,
            \ })
    endif
  endfor

  if empty(l:qf)
    echohl WarningMsg | echom "No global marks found" | echohl None
    return
  endif

  " Populate quickfix list and open
  call setqflist([], ' ', {'title': 'Global Marks', 'items': l:qf})
  copen
endfunction

" Map to toggle bookmarking a line and to display all in a qf list
nnoremap <silent> m` :call ToggleBookmark()<CR>
nnoremap <silent> <leader>fm :call GlobalMarksToQuickfix()<CR>

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
