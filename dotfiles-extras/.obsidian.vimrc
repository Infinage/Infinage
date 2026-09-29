" ==========================================================
" Basic Settings
" ==========================================================
unmap <Space>
let mapleader="space"
set clipboard=unnamed

" Disable arrow keys (Hard mode)
nmap <Up> <Nop>
nmap <Down> <Nop>
nmap <Left> <Nop>
nmap <Right> <Nop>
vmap <Up> <Nop>
vmap <Down> <Nop>
vmap <Left> <Nop>
vmap <Right> <Nop>

" ==========================================================
" Insert Mode Navigation
" ==========================================================
" Move normally using Ctrl in insert mode
imap <C-h> <Esc>hi
imap <C-j> <Esc>ja
imap <C-k> <Esc>ka
imap <C-l> <Esc>la

" ==========================================================
" Navigation & App Commands
" ==========================================================
" Command Palette & Quick Switcher
exmap command_palette obcommand command-palette:open
nmap <Space>fz :command_palette<CR>

exmap quick_switcher obcommand switcher:open
nmap <Space>ff :quick_switcher<CR>

exmap global_search obcommand global-search:open
nmap <Space>fS :global_search<CR>

" Go Into Link
exmap goto_link obcommand editor:follow-link
nmap <C-]> :goto_link<CR>

" Navigate prev and next tab
exmap tabnext obcommand workspace:next-tab
nmap ]t :tabnext<CR>

exmap tabprev obcommand workspace:previous-tab
nmap [t :tabprev<CR>

" Remove highlights
nmap <Space>cc :nohl<CR>

" ==========================================================
" Folding
" ==========================================================
exmap togglefold obcommand editor:toggle-fold
nmap zf :togglefold<CR>

" ==========================================================
" Surround Configuration
" ==========================================================
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
exmap surround_bold surround ** **
exmap surround_strikethrough surround ~~ ~~
exmap surround_italics surround _ _

" Must use 'map' and not 'nmap' for the first one
map [[ :surround_wiki<CR>

vunmap S
vmap S" :surround_double_quotes<CR>
vmap S' :surround_single_quotes<CR>
vmap Sb :surround_brackets<CR>
vmap S( :surround_brackets<CR>
vmap S) :surround_brackets<CR>
vmap S[ :surround_square_brackets<CR>
vmap S{ :surround_curly_brackets<CR>
vmap S} :surround_curly_brackets<CR>
vmap S* :surround_bold<CR>
vmap S~ :surround_strikethrough<CR>
vmap S_ :surround_italics<CR>
