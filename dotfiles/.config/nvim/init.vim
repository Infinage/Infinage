" Install vim-plug if not present
" https://raw.githubusercontent.com/junegunn/vim-plug/refs/heads/master/plug.vim
" mkdir -p ~/.local/share/nvim/site/autoload && mv misc/plug.vim ~/.local/share/nvim/site/autoload
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
Plug 'tpope/vim-fugitive'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'branch': 'master' }
Plug 'https://codeberg.org/andyg/leap.nvim.git'
Plug 'olimorris/codecompanion.nvim'
Plug 'windwp/nvim-autopairs'
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
  view_options = { show_hidden = true, },
  keymaps = {
    ["`"] = false,
    ["!"] = "actions.open_terminal",
    ["<C-v>"] = { "actions.select", opts = { vertical = true } },
    ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-y>"] = { "actions.yank_entry", opts = { modify = ":." } },
    ["<A-y>"] = "actions.yank_entry",
  }
})

-- Keymap to open Oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory of current buffer in Oil" })
vim.keymap.set("n", "~", "<CMD>Oil .<CR>", { desc = "Open CWD in Oil" })
EOF

" Setup LSP
lua << EOF
-- Setup LSP servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local cmp = require('cmp')

-- C/C++ LSP (custom modification from what is defined)
vim.lsp.config('clangd', {
  capabilities = capabilities,
  cmd = { 
    "clangd", "--query-driver=**", "--background-index", "--clang-tidy", "-j=8", 
    "--pch-storage=memory", "--limit-references=100", "--limit-results=50", 
    -- "--experimental-modules-support"
  },
})

-- Enable all required LSP configs
vim.lsp.enable({'clangd', 'jedi_language_server', 'bashls', 'lua_ls', 'cmake'})

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
    { name = 'codecompanion' },
    {  name = 'buffer',
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

" Setup treesitter
lua << EOF
require("nvim-treesitter.install").prefer_git = true
require('nvim-treesitter.configs').setup {
  parser_install_dir = nil,
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  ensure_installed = { 
    "cpp", "lua", "python", "vim", "vimdoc", "bash", "markdown", 
    "markdown_inline", "cmake", "xml", "json", "dockerfile", 
    "javascript", "query", "yaml",
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      node_decremental = "<BS>",
    },
  },
  textobjects = {
    enable = true,
    select = {
      enable = true, lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["i/"] = "@comment.inner",
        ["a/"] = "@comment.outer",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]1"] = "@class.outer",
        ["]2"] = "@function.outer",
        ["]3"] = "@block.outer",
        ["]4"] = "@loop.outer",
        ["]5"] = "@conditional.outer",
        ["]6"] = "@return.inner",
      },
      goto_previous_start = {
        ["[1"] = "@class.outer",
        ["[2"] = "@function.outer",
        ["[3"] = "@block.outer",
        ["[4"] = "@loop.outer",
        ["[5"] = "@conditional.outer",
        ["[6"] = "@return.inner",
      },
      goto_next_end = {
        ["}1"] = "@class.outer",
        ["}2"] = "@function.outer",
        ["}3"] = "@block.outer",
        ["}4"] = "@loop.outer",
        ["}5"] = "@conditional.outer",
      },
      goto_previous_end = {
        ["{1"] = "@class.outer",
        ["{2"] = "@function.outer",
        ["{3"] = "@block.outer",
        ["{4"] = "@loop.outer",
        ["{5"] = "@conditional.outer",
      },
    },
  }
}
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

" Highlight cursor line underneath the cursor horizontally (disabled for perf)
set nocursorline

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
"let g:clipboard = "tmux"

" Compat Disable screen flashing, backspace work as expected
set belloff=all
set backspace=eol,indent,start

" Autocomplete in command line
set wildmenu

" Split right and down first
set splitright splitbelow

" Disable search count (lualine displays it)
set shortmess=S

" Setup persistent undo
set undofile

" Controls how fast swap files are created 
" also how fast fugutive updates marks
set updatetime=100 

" Setup auto pairs in nvim
lua require("nvim-autopairs").setup()

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
lua << EOF
for _, mode in ipairs({ "n", "i", "v", "x", "c" }) do
  for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
    vim.api.nvim_set_keymap(mode, key, "<Nop>", { noremap = true, silent = true })
  end
end
EOF

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

" Follow symlink to real file
command! FollowSymlink execute 'file ' fnameescape(resolve(expand('%:p')))

" Close all splits in current tab/window
command! -bang Q execute 'windo' (<bang>0 ? 'quit!' : 'quit')

" Navigate prev and next tab
nnoremap [t :tabprevious<CR>
nnoremap ]t :tabnext<CR>

" When using `dd` in the quickfix list, remove the item from the quickfix list.
" Source: https://vi.stackexchange.com/a/21255
function! ListDelete(bufnr) range abort
  let l:winid = winnr()
  let l:is_loc = getwininfo(win_getid())[0].loclist == 1
  let l:list = l:is_loc ? getloclist(l:winid) : getqflist()
  call remove(l:list, a:firstline - 1, a:lastline - 1)
  if l:is_loc
    call setloclist(l:winid, [], 'r', {'items': l:list})
  else
    call setqflist([], 'r', {'items': l:list})
  endif
  call setpos('.', [a:bufnr, min([a:firstline, len(l:list)]), 1, 0])
endfunction

augroup ListDelete
  autocmd!
  autocmd FileType qf nnoremap <silent><buffer> dd :<C-u>call ListDelete(bufnr())<CR>
  autocmd FileType qf vnoremap <silent><buffer> d :<C-u>'<,'>call ListDelete(bufnr())<CR>
augroup END

" Swap keymaps for quickfix navigation
nnoremap ]Q :cnfile<CR>
nnoremap [Q :cpfile<CR>
nnoremap ]<C-q> :clast<CR>
nnoremap [<C-q> :crewind<CR>

" Swap keymaps for loclist navigation
nnoremap ]L :lnfile<CR>
nnoremap [L :lpfile<CR>
nnoremap ]<C-l> :llast<CR>
nnoremap [<C-l> :lrewind<CR>

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
nnoremap <leader>du :Gvdiffsplit!<CR>
nnoremap <leader>ds :Gvdiffsplit! HEAD:%<CR>
nnoremap <leader>gD :G! difftool -y<CR>
nnoremap <silent><leader>gl :<C-u>execute 'G log' (v:count ? '-n ' . v:count : '')<CR>
nnoremap gb :G blame<CR>

" Diffput and diffget support in visual mode
vnoremap <silent> <leader>dg :<C-U>execute "'<,'>diffget"<CR>
vnoremap <silent> <leader>dp :<C-U>execute "'<,'>diffput"<CR>

" Fold everything in Fugitive windows
autocmd FileType git setlocal foldmethod=syntax | silent! normal! ggVGzc

" Scroll floating popups
nnoremap <silent> <A-j> :call ScrollPopup(  1)<CR>
nnoremap <silent> <A-k> :call ScrollPopup( -1)<CR>
nnoremap <silent> <A-n> :call ScrollPopup( 10)<CR>
nnoremap <silent> <A-m> :call ScrollPopup(-10)<CR>

" Scroll right left with keybinds
nnoremap <A-l> 20zl
nnoremap <A-h> 20zh

" Shortcuts for FZF-Lua
lua << EOF
local fzf = require("fzf-lua")

fzf.setup({
  blines = { fzf_opts = { ["--no-sort"] = true } },
  files = {
    actions = {
        ['ctrl-y'] = {
            fn = function(selected)
              local clean = {}
              for _, entry in ipairs(selected) do
                entry = (entry:gsub('^[^%w]*([%w].*)$', '%1'))
                entry = vim.fn.fnamemodify(entry, ':p')
                table.insert(clean, entry)
              end
              vim.fn.setreg('+', table.concat(clean, '\n'))
              vim.notify('Copied selection to clipboard', vim.log.levels.INFO)
            end, exec_silent = true, desc = "Copy file path",
        },
        ["ctrl-x"] = {
          fn = function(selected)
            if not selected or #selected == 0 then return end
            local choice = vim.fn.confirm("Delete " .. #selected .. " file(s)?", "&Yes\n&No", 2)
            if choice ~= 1 then return end
            for _, entry in ipairs(selected) do
              entry = (entry:gsub('^[^%w]*([%w].*)$', '%1'))
              local path = vim.fn.fnamemodify(entry, ':p')
              if vim.fn.filereadable(path) == 1 then os.remove(path) end
            end
          end, reload = true, desc = "Delete file"
        },
        ["alt-n"] = {
          fn = function(selected, opts)
            if opts.query == "" then return end
            local fpath = vim.fn.fnamemodify(opts.query, ":p")
            local fdir = vim.fn.fnamemodify(fpath, ":h")
            if vim.fn.isdirectory(fdir) == 0 then vim.fn.mkdir(fdir, "p") end
            if vim.fn.filereadable(fpath) == 1 then 
              vim.notify("File already exists: " .. fpath, vim.log.levels.WARN) 
              return
            end
            vim.fn.writefile({}, fpath)
            vim.notify("Created file: " .. fpath, vim.log.levels.INFO)
          end, reload = true, desc = "Create new file"
        },
    }
  },
  buffers = {
    actions = {
      ["alt-x"] = {
        fn = function(selected)
          if not selected or #selected == 0 then return end
          local choice = vim.fn.confirm("Force delete " .. #selected .. " buffer(s)?", "&Yes\n&No", 2)
          if choice ~= 1 then return end
          for _, e in ipairs(selected) do
            local bufnr = tonumber(e:match("%[(%d+)%]"))
            if bufnr then vim.cmd("bdelete! " .. bufnr) end
          end
        end,
        reload = true, desc = "Delete buffer"
      },
    }
  },
  grep = {
    actions = {
        ["Alt-l"] = {
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
      fzf_args="--multi",
      actions = {
        ["alt-q"] = function(selected)
          if not selected or #selected == 0 then return end
          local commits = {}
          for _, entry in ipairs(selected) do
            local hash = entry:match("^%x+")
            if hash then table.insert(commits, hash) end
          end
          if #commits > 0 then
            local cmd = string.format("silent! G show %s", table.concat(commits, " "))
            vim.cmd(cmd)
          end
        end,
      },
      preview = "git show --color --stat {1}",
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
        actions = {
          ["ctrl-d"] = function(...)
            fzf.actions.git_buf_split(...)
            vim.cmd("windo diffthis | wincmd h")
          end, desc = "Diff against commit"
        },
    },
  },
  manpages = {
      previewer = "man_native",
      winopts = { 
        fullscreen = true, 
        preview = { 
          hidden = false, 
          layout = "vertical", 
          vertical = "down:80%"
        } 
      }
  },
  undotree = { 
    winopts = { 
      preview = {
        locate = false,
        layout = "horizontal", 
        horizontal = "right:75%",
        hidden = false, 
      }, 
    } 
  },
  winopts = {
    preview = {
      layout = "vertical",
      vertical = "down:60%",
      horizontal = "right:60%",
      wrap = true,
      scrollbar = "float",
      default = "bat",
      delay = 20,
      hidden = true,
    },
  },
  keymap = {
      fzf = {
        true,
        ["Alt-j"] = "preview-down",
        ["Alt-k"] = "preview-up",
        ["Alt-n"] = "preview-half-page-down",
        ["Alt-m"] = "preview-half-page-up",
        ["ctrl-q"] = "select-all+accept",
        ["ctrl-l"] = "forward-char",
        ["ctrl-h"] = "backward-char",
        ["ctrl-backspace"] = "backward-kill-word",
      },
      builtin = {
        true,
        ["Alt-j"] = "preview-down",
        ["Alt-k"] = "preview-up",
        ["Alt-n"] = "preview-half-page-down",
        ["Alt-m"] = "preview-half-page-up",
        ["Alt-f"] = "focus-preview",
        ["ctrl-l"] = "forward-char",
        ["ctrl-h"] = "backward-char",
        ["ctrl-backspace"] = "backward-kill-word",
      },
  },
})

vim.api.nvim_create_user_command("DocSymbols", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local has_document_symbols = false

  for _, client in ipairs(clients) do
    if client.server_capabilities.documentSymbolProvider then
      has_document_symbols = true
      break
    end
  end

  if has_document_symbols then
    fzf.lsp_document_symbols()
  else
    fzf.treesitter()
  end
end, { nargs = 0, desc = "Open LSP Symbols if LSP attached else open treesitter" })
EOF

" FZF keymaps for useful utils
nnoremap <silent><leader>fb :lua require('fzf-lua').buffers()<CR>
nnoremap <silent><leader>ff :lua require('fzf-lua').files({resume=true})<CR>
nnoremap <silent><leader>fl :lua require('fzf-lua').lines({resume=true})<CR>
nnoremap <silent><leader>fs :lua require('fzf-lua').blines({resume=true})<CR>
nnoremap <silent><leader>fS :lua require('fzf-lua').live_grep_native()<CR>
nnoremap <silent><leader>fg :lua require('fzf-lua').git_bcommits()<CR>
nnoremap <silent><leader>fG :lua require('fzf-lua').git_commits()<CR>
nnoremap <silent><leader>fz :lua require('fzf-lua').builtin()<CR>
nnoremap <silent><leader>fm :lua require('fzf-lua').marks({marks = "%u"})<CR>
nnoremap <silent><leader>fM :lua require('fzf-lua').manpages()<CR>
nnoremap <silent><leader>fo :lua require('fzf-lua').oldfiles()<CR>
nnoremap <silent><leader>fk :DocSymbols<CR>
vnoremap <silent><leader>fs <cmd>FzfLua blines resume=true<CR>
vnoremap <silent><leader>fg <cmd>FzfLua git_bcommits<CR>

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
  if buftype == "" then vim.bo[buf].buftype = "nofile" end

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

" Keymaps for Leap.nvim jump plugin
lua << EOF
require('leap').opts.safe_labels = ''
vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
EOF

" Codecompanion Setup
lua << EOF
require("codecompanion").setup({
  strategies = {
      chat = { adapter = "gemini", },
      inline = { adapter = "gemini", },
      cmd = { adapter = "gemini", },
      agent = { adapter = "gemini", }
  },
  adapters = {
    http = {
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          env = { api_key = "cmd:pass show google/gemini" },
          schema = { model = { default = "gemini-2.5-flash", }, },
        })
      end,
      groq = function()
        return require("codecompanion.adapters").extend("openai", {
          name = "Groq", env = { api_key = "cmd:pass show groq" },
          url = "https://api.groq.com/openai/v1/chat/completions",
          schema = { model = { default = "llama-3.1-8b-instant", }, },
        })
      end,
    },
  },
})
EOF
 
" Keymaps for codecompanion
nnoremap <silent> <leader>C :CodeCompanionChat Toggle<CR>
vnoremap <silent> <leader>C :<C-u>call feedkeys(":'<,'>CodeCompanion ")<CR>
vnoremap <silent> <leader>ll :CodeCompanionChat Add<CR>

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
      if i < len(jumplist)
        let buf = jumplist[i]["bufnr"]
        if buf != bufnr('%') && bufexists(buf) && bufloaded(buf)
          execute "silent normal! " . ((i - curjump) * a:dir) . jumpcmdchr
          let found = 1
          silent! normal! g`"zz
          break
        endif
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

" Jump to next or previous bookmark (A-Z)
function! NavigateBookmark(direction, ...) abort
  " static variable to track last bookmark (for global navigation)
  if !exists("t:last_bookmark")
      let t:last_bookmark = ''
  endif

  " Get optional buffer number arg
  let l:bufnum = get(a:, 1, 0)

  " Filter only for A-Z (filter by buffer no if provided)
  let l:marks = filter(getmarklist(), {_, m ->
      \ (m.mark[1] =~# '^[A-Z]$') &&
      \ (l:bufnum ==# 0 || m.pos[0] == l:bufnum)
      \ })

  if empty(l:marks)
    echohl WarningMsg | echom "No bookmarks found" | echohl None
    return
  endif

  " --- Buffer-specific mode ---
  if l:bufnum > 0
    call sort(l:marks, {a,b -> a.pos[1] - b.pos[1]}) " Sort by line#
    let l:cur_line = line('.')
    let l:next_idx = -1

    " Find next or previous mark based on direction
    for i in range(len(l:marks))
      if a:direction > 0 && l:marks[i].pos[1] > l:cur_line
        let l:next_idx = i | break
      elseif a:direction < 0 && l:marks[i].pos[1] < l:cur_line
        let l:next_idx = i
      endif
    endfor
    if l:next_idx == -1 " Handle wrap-around
      let isWrapped = 1
      let l:next_idx = a:direction > 0 ? 0 : len(l:marks) - 1
    endif
    let l:m = l:marks[l:next_idx]
    execute l:m.pos[1]

  " --- Global alphabetical mode ---
  else
    let l:len = len(l:marks)
    let l:mark_names = map(copy(l:marks), {_,m -> m.mark})
    let l:idx = index(l:mark_names, t:last_bookmark)
    if l:idx == -1 " Handle wrap around
        let l:idx = a:direction > 0 ? -1 : 0
    endif
    let l:m = l:marks[(l:idx + a:direction + l:len) % l:len]
    execute "normal! " . l:m.mark | redraw
  endif

  let t:last_bookmark = l:m.mark
  normal! zz
  let l:wrap_msg = exists('l:isWrapped') && l:isWrapped ? "(Wrapped) " : ""
  echohl None | echom l:wrap_msg . "At bookmark: " . t:last_bookmark[1] | echohl None

endfunction

" Map to toggle bookmarking a line and jumping across bookmarks
nnoremap <silent> m` :call ToggleBookmark()<CR>
nnoremap ]` :call NavigateBookmark(1)<CR>
nnoremap [` :call NavigateBookmark(-1)<CR>
nnoremap }` :call NavigateBookmark(1, bufnr('%'))<CR>
nnoremap {` :call NavigateBookmark(-1, bufnr('%'))<CR>

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
