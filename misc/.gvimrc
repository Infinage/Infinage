set guioptions-=m "menu bar
set guioptions-=T "tool bar
set guioptions-=r "scroll bar

" Set some basic fonts
set guifont=Hack_Nerd_Font_Mono:h12

" Set terminal output encoding
set encoding=utf-8

" Disable balloon popups on Gvim
set noballooneval

" Reset Backspace behaviour
set backspace=indent,eol,start

" GUI to match the general theme
set guioptions-=e

" Setting up the file format
set fileformats=unix,dos

" Python configs
let g:slime_python_ipython=0

" Ale disable balloon hover
let g:ale_hover_cursor=0

" Disable Mouse
set mouse=

" Color Scheme for Vim terminal
let g:terminal_ansi_colors = [
  \'#282828', '#CC241D', '#98971A', '#D79921',
  \'#458588', '#B16286', '#689D6A', '#D65D0E',
  \'#fb4934', '#b8bb26', '#fabd2f', '#83a598',
  \'#d3869b', '#8ec07c', '#fe8019', '#FBF1C7' ]

highlight Terminal guibg='#202020'
highlight Terminal guifg='#ebdbb2'
