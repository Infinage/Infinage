" Clear existing syntax
syntax clear

" Highlight entire lines based on log level
syntax match LogMeta   ".*\[META\].*$"
syntax match LogInfo   ".*\[INFO\].*$"
syntax match LogWarn   ".*\[WARN\].*$"
syntax match LogError  ".*\[ERROR\].*$"
syntax match LogCrit   ".*\[CRIT\].*$"

" Define colors
hi LogMeta guifg=#808080
hi LogInfo guifg=#00af00
hi LogWarn guifg=#ffaf00
hi LogError guifg=#ff0000
hi LogCrit guifg=#ffffff guibg=#ff0000
