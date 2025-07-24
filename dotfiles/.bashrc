#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- make dir (if needed) and cd into it --------------------------
mkdircd () {
    # exit if no argument
    [ -z "$1" ] && { echo "usage: mkdircd <dir>"; return 1; }
    # create the directory if it doesn't already exist
    mkdir -p -- "$1" && cd -- "$1"
}

# shorter alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias mcd=mkdircd
PS1='[\u@\h \W]\$ '

#R='\[\e[38;2;255;100;100m\]'
#G='\[\e[38;2;100;255;100m\]'
#B='\[\e[38;2;100;100;255m\]'
#W='\[\e[0m\]'
#PS1="[$R\u$W@$B\h$W $G\W$W]\\$ "

alias nv='nvim'
