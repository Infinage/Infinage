# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Proper locale support
export LANG=en_US.UTF-8

# shorter alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias nv='nvim'
alias lpd='list_process_descendants'
alias zq='zoxide query'
alias zqi='zoxide query --interactive'

# Neo + Fzf + Zoxide
nz() {
    local dir file matches count arg="$1"

    # No args → fzf in current directory
    if [ $# -eq 0 ]; then
        file="$(fzf)" || return
        [ -n "$file" ] && nvim "$file"; return
    fi

    # Single argument → resolve as file or folder first
    if [ $# -eq 1 ]; then
        resolved="$(readlink -f "$arg" 2>/dev/null || echo "$arg")"
        [ -f "$resolved" ] && { nvim "$resolved"; return; }
        if [ -d "$resolved" ]; then
            file="$(find -L "$resolved" -type f 2>/dev/null | fzf)"
            [ -n "$file" ] && nvim "$file"; return
        fi
    fi

    # Multiple args or unresolved single arg → use zoxide
    matches="$(zoxide query -l "$@")" || return
    [ $? -ne 0 ] || [ -z "$matches" ] && echo "Could not resolve for: $*" && return
    count="$(echo "$matches" | grep -c .)"

    if [ "$count" -eq 1 ]; then
        dir="$(echo "$matches" | head -n 1)"
    else
        dir="$(zoxide query --interactive "$@")" || return
    fi

    [ -z "$dir" ] && return

    # Run fzf inside resolved directory
    file="$(find -L "$dir" -type f 2>/dev/null | fzf)" || return
    [ -n "$file" ] && nvim "$file"
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
    tmux display-message "✅ Command Success — Cmd: $cmd | Status: $exit_code"
    notify-send -u normal "Command Success ✅" "Cmd: $cmd\nStatus: $exit_code"
  else
    tmux display-message "❌ Command Failed — Cmd: $cmd | Status: $exit_code"
    notify-send -u critical "Command Failed ❌" "Cmd: $cmd\nStatus: $exit_code"
  fi

  return $exit_code
}

PS1='[\u@\h \W]\$ '
if [[ -n "$TMUX" ]]; then
    TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    PS1="[TM:${TMUX_SESSION}] $PS1"
fi

#R='\[\e[38;2;255;100;100m\]'
#G='\[\e[38;2;100;255;100m\]'
#B='\[\e[38;2;100;100;255m\]'
#W='\[\e[0m\]'
#PS1="[$R\u$W@$B\h$W $G\W$W]\\$ "

# Setup fzf for bash
eval "$(fzf --bash)"

# Setup zoxide for bash
export _ZO_RESOLVE_SYMLINKS=1
eval "$(zoxide init bash)"

# Custom function to grep and kill processes
pz() {
  # if argument is given, filter by user, else show all (-e)
  local user_filter=${1:+-u $1}
  [ -z "$user_filter" ] && user_filter="-e"

  # build ps command dynamically; no -e flag so -u takes effect
  local _pz="(date; ps $user_filter -o user,pid,ppid,stat,etime,comm,pmem,pcpu)"

  eval "$_pz | \
  fzf \
    --multi \
    --bind='alt-a:toggle-all' \
    --bind='ctrl-r:reload($_pz)' \
    --bind='ctrl-x:execute-silent(echo {+2} | xargs -r kill -9)+reload($_pz)' \
    --bind='ctrl-y:execute(echo {+2} | ~/bin/copy)' \
    --bind='alt-y:execute(echo {+3} | ~/bin/copy)' \
    --bind='enter:execute(ps -p {2} -o args --no-header | ~/bin/copy)' \
    --bind='ctrl-f:half-page-down,ctrl-b:half-page-up' \
    --bind='alt-h:backward-char,alt-l:forward-char' \
    --header=\$'C-R reload | A-A select all | C-X kill | C-Y copy PID | A-Y copy PPID\n' \
    --header-lines=2 \
    --preview='ps -p {2} -o args --no-header' \
    --preview-window=down,3,wrap \
    --layout=reverse \
    --height=80%"
}
