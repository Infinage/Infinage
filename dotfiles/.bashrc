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
alias nv='nvim'
alias lpd=list_process_descendants

# Compile & run a cpp source inside gdb
cdb() {
    if [ $# -lt 1 ]; then
        echo "Usage: cdb <source.cpp> [compile flags]"
        return 1
    fi

    src="$1"
    exe="${src%.*}.out"
    shift

    g++ -std=c++23 -ggdb "$src" -o "$exe" "$@" || return 1
    gdb -q "./$exe"
}

# List all process descendents for input process ID
list_process_descendants() {
    local children
    children=$(pgrep -P "$1")

    if [ -n "$children" ]; then
        for child in $children; do
            list_process_descendants "$child"
        done
        echo "$children"
    fi
}

# Notify On Done: run any command and notify on completion
nod() {
  if [ $# -lt 1 ]; then
    echo "Usage: nod <command...>"; return 1
  fi

  local cmd="$*"
  trap 'list_process_descendants $$ | xargs -r kill 2>/dev/null' INT TERM EXIT

  # Execute command capture its exit code
  # wait for any bg processes to finish running
  eval "$cmd"; wait; local exit_code=$?;

  # Trim command for notifications
  if [ ${#cmd} -gt 20 ]; then
    cmd="${cmd:0:20}..."
  fi

  # Notify
  if [ $exit_code -eq 0 ]; then
    notify-send -u normal "Command Success ✅" "Cmd: $cmd\nStatus: $exit_code"
  else
    notify-send -u critical "Command Failed ❌" "Cmd: $cmd\nStatus: $exit_code"
  fi

  return $exit_code
}

PS1='[\u@\h \W]\$ '

#R='\[\e[38;2;255;100;100m\]'
#G='\[\e[38;2;100;255;100m\]'
#B='\[\e[38;2;100;100;255m\]'
#W='\[\e[0m\]'
#PS1="[$R\u$W@$B\h$W $G\W$W]\\$ "

# Setup fzf for bash
eval "$(fzf --bash)"

# Setup zoxide for bash
eval "$(zoxide init bash)"

# Custom function to grep and kill processes
alias kz="(date; ps -ef) |\
fzf \
  --multi \
  --bind='alt-a:toggle-all' \
  --bind='ctrl-r:reload(date; ps -ef)' \
  --bind='ctrl-x:execute-silent(echo {+2} | xargs -r kill -9)+reload(date; ps -ef)' \
  --bind='enter:ignore' \
  --bind='ctrl-f:half-page-down,ctrl-b:half-page-up' \
  --bind='alt-h:backward-char,alt-l:forward-char' \
  --header=$'CTRL-R reload | ALT-A select all | ENTER kill | CTRL-X kill\n' \
  --header-lines=2 \
  --preview='echo {}' \
  --preview-window=down,3,wrap \
  --layout=reverse \
  --height=80%"
