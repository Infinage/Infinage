" Install vim-plug if not present
" https://raw.githubusercontent.com/junegunn/vim-plug/refs/heads/master/plug.vim
" nv --headless -es +silent! +'PlugInstall --sync' +qa

" Plugins
call plug#begin()
Plug 'stevearc/oil.nvim'
Plug 'morhetz/gruvbox'
Plug 'nvim-lua/plenary.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'ibhagwan/fzf-lua'
Plug 'hrsh7th/nvim-cmp'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'goerz/jupytext.nvim'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-fugitive'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
call plug#end()

" Setup lualine
lua << EOF
local theme = require('lualine.themes.gruvbox')

local function mode_color()
  local mode = vim.fn.mode()
  local colors = {
    n = theme.normal.a,
    i = theme.insert.a,
    v = theme.visual.a,
    V = theme.visual.a,
    c = theme.command.a,
    R = theme.replace.a,
    t = theme.normal.a,
  }
  return { fg = colors[mode].fg, bg = colors[mode].bg, gui = 'bold' }
end

require('lualine').setup({
  options = {
    component_separators = '',
    theme = { 
      normal = theme.normal,
      insert = theme.normal,
      visual = theme.normal,
      replace = theme.normal,
      command = theme.normal,
      terminal = theme.normal,
      inactive = theme.inactive,
    }
  },
  sections = {
    lualine_a = { { 'mode', color = mode_color, separator = { right = '' } } },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'searchcount', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location', 'searchcount' },
  },
  tabline = {
    lualine_a = { { 'tabs', tab_max_length = 40, mode = 2, max_length = vim.o.columns } },
  }
})
EOF

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
    "--limit-results=50",
  },
})

-- Python
vim.lsp.config('jedi_language_server', { capabilities = capabilities, })

-- Bash
vim.lsp.config('bashls', { capabilities = capabilities, })

-- Enable both LSP configs
vim.lsp.enable('clangd', 'jedi_language_server', 'bashls')

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
autocmd VimEnter * hi Normal ctermbg=NONE guibg=NONE
let g:gruvbox_transparent_bg=1
set background=dark
colorscheme gruvbox

" Show the status on the second to last line.
set laststatus=2

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

" Searching related stuff
set ignorecase
set smartcase
set hlsearch
set incsearch

" Set border as rounded for floating windows
set winborder=rounded

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

" Disable search count (lualine displays it)
set shortmess=S

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

" Navigate prev and next tab
nnoremap [t :tabprevious<CR>
nnoremap ]t :tabnext<CR>

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
let g:gitgutter_floating_window_options = {
    \ 'relative': 'cursor', 'row': 1, 'col': 0,
    \ 'width': 42, 'height': &previewheight,
    \ 'style': 'minimal', 'border': 'rounded' 
\ }

" Git gutter text object navigation
omap ig <Plug>(GitGutterTextObjectInnerPending)
omap ag <Plug>(GitGutterTextObjectOuterPending)
xmap ig <Plug>(GitGutterTextObjectInnerVisual)
xmap ag <Plug>(GitGutterTextObjectOuterVisual)

" Git gutter keymaps
nnoremap gp :GitGutterPreviewHunk<CR>
nnoremap gs :GitGutterStageHunk<CR>
vnoremap gs :GitGutterStageHunk<CR>
nnoremap gu :GitGutterUndoHunk<CR>
nmap ]g <Plug>(GitGutterNextHunk)
nmap [g <Plug>(GitGutterPrevHunk)

" Fugitive keybinds
nnoremap <leader>gd :Gdiffsplit!<CR>
nnoremap <leader>gD :G! difftool -y<CR>
nnoremap <leader>gl :0Gllog<CR>
nnoremap gb :G blame<CR>

" Fold everything in Fugitive windows
autocmd FileType git setlocal foldmethod=syntax | silent! normal! ggVGzc

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
              toggle_flag = "--multiline --multiline-dotall --files-with-matches",
            }))
          end,
          desc = "toggle-multiline",
          header = function(o)
            local utils = require("fzf-lua.utils")
            local flag = "--multiline"
            if o.cmd and o.cmd:match(utils.lua_regex_escape(flag)) then
              return "[x] Multiline"
            else
              return "[ ] Multiline"
            end
          end,
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
        true,
        ["Alt-j"] = "preview-down",
        ["Alt-k"] = "preview-up",
        ["Alt-d"] = "preview-page-down",
        ["Alt-u"] = "preview-page-up",
        ["ctrl-q"] = "select-all+accept",
        ["ctrl-l"] = "forward-char",
        ["ctrl-h"] = "backward-char",
      },
      builtin = {
        true,
        ["Alt-j"] = "preview-down",
        ["Alt-k"] = "preview-up",
        ["Alt-d"] = "preview-page-down",
        ["Alt-u"] = "preview-page-up",
        ["Alt-p"] = "focus-preview",
        ["ctrl-l"] = "forward-char",
        ["ctrl-h"] = "backward-char",
      },
  },
})

-- Function to fuzzy search and preview cppman pages inline
function cppman_live()
  fzf.fzf_live(
  "cppman -f <query>",
  {
    prompt = "cppman> ",
    exec_empty_query = false,
    preview = {
      type = "cmd", 
      fn = function(selected) 
        local token = selected[1]:match("^(%S+)") or selected[1] 
        return "cppman " .. vim.fn.shellescape(token) 
      end,
    },
    actions = {
      ["default"] = function(selected)
        local token = selected[1]:match("^(.-) %-") or selected[1]
        vim.cmd("split | terminal cppman " .. token)
      end,
    },
    winopts = {
      fullscreen = true,
      preview = {
        hidden = false,
        layout = "vertical",
        vertical = "down:80%",
      },
    },
  })
end
EOF

" FZF keymaps for useful utils
nnoremap <leader>fb :lua require('fzf-lua').buffers()<CR>
nnoremap <leader>ff :lua require('fzf-lua').files({resume=true})<CR>
nnoremap <leader>fs :lua require('fzf-lua').blines({resume=true})<CR>
vnoremap <leader>fs <cmd>FzfLua blines<CR>
nnoremap <leader>fS :lua require('fzf-lua').live_grep_native()<CR>
nnoremap <leader>fg :lua require('fzf-lua').git_bcommits()<CR>
vnoremap <leader>fg <cmd>FzfLua git_bcommits<CR>
nnoremap <leader>fG :lua require('fzf-lua').git_commits()<CR>
nnoremap <leader>fz :lua require('fzf-lua').builtin()<CR>
nnoremap <leader>cp :lua cppman_live()<CR>

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
  local text = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
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
            silent! normal! g`"
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
      echohl None | echom "Bookmark removed: " . mchar
      return
    endif
  endfor

  " Compute available uppercase marks and place first one
  let l:available = filter(map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)'), 'index(l:taken, v:val) == -1')
  if !empty(l:available)
      execute 'mark ' . l:available[0]
      echohl None | echom "Bookmark added: " . l:available[0]
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

" Change to project root based on .git (or other patterns)
function! Rooter()
  " Patterns to consider as project root
  let l:roots = ['.git']

  let l:dir = expand('%:p:h')
  if l:dir == ''
    let l:dir = getcwd()
  endif

  while l:dir !=# '/'
    " Check if any of the root patterns exist in this directory
    for root in l:roots
      if isdirectory(l:dir . '/' . root)
        execute 'cd ' . fnameescape(l:dir)
        echo "Changed directory to project root: " . l:dir
        return
      endif
    endfor
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile

  echohl WarningMsg | echom "No project root found" | echohl None
endfunction

" Map above function to keybinds
nnoremap cd :cd %:p:h<CR>
nnoremap cD :call Rooter()<CR>

" Feedback for what has been yanked
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=250 }
augroup END

" Add linter for extra 
let g:ale_set_loclist = 0
let g:ale_linters = { 'cpp': ['cc'] }
let cpp_opts = '-std=c++23 -Wall -Weffc++ -Wextra -Wpedantic -L/home/kael/cpplib/lib -I/home/kael/cpplib/include'
let g:ale_cpp_cc_options = cpp_opts
let g:ale_floating_preview = 1
nnoremap <leader>ad :ALEDetail<CR>
