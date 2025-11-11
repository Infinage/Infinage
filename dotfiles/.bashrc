# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Proper locale support
export LANG=en_US.UTF-8

# Useful utilities defined here
export PATH="$HOME/bin:$PATH"

# shorter alias
alias l='ls -lart --color=auto'
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat'
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

# TMUX Popup Show Message (closes on enter)
tpshow() {
  local message="$*" lines cols cmd
  lines=$(echo -e "$message" | wc -l)
  cols=$(echo -e "$message" | awk '{print length}' | sort -nr | head -1)
  cmd="bash -c 'tput civis; printf \"%b\" \"\$1\"; stty -echo; read -r _' _ \"$message\""
  tmux display-popup -E -h $((lines+2)) -w $((cols+2)) -xC -yC "$cmd"
}

# Notify On Done: run any command and notify on completion
nod() {
  [ $# -lt 1 ] && echo "Usage: nod <command...>" && return 1

  local cmd="$*" start end elapsed code
  start=$(date +%s.%N)
  eval "$cmd"
  code=$?
  end=$(date +%s.%N)

  elapsed=$(awk -v s="$start" -v e="$end" 'BEGIN { printf "%.2f", e - s }')

  [[ ${#cmd} -gt 40 ]] && cmd="${cmd:0:40}..."

  local color title msg
  if ((code == 0)); then
    title="Command Succeeded"; color="\033[1;32m"
  else
    title="Command Failed"; color="\033[1;31m"
  fi

  msg=$(printf "%b%s%b\n\nTime Taken: %ss\nExit Code: %d\nCommand: %s\n\nPress enter to close." \
    "$color" "$title" "\033[0m" "$elapsed" "$code" "$cmd")

  tpshow "$msg"
  return $code
}

# Quick temp folder for experiments
tempd () { 
  cd "$(mktemp -d)" 
  chmod -R 0700 . 
  if [[ $# -eq 1 ]]; then 
    \mkdir -p "$1" 
    cd "$1" 
    chmod -R 0700 . 
  fi 
}

PS1='[\u@\h \w]\n$ '
if [[ -n "$TMUX" ]]; then
    TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    PS1="[TM:${TMUX_SESSION}] $PS1"
fi

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

# Monitor network sockets by port number or PID
ports() {
    case "$1" in
        "")  ss -patun ;;
        -h|--help)
            echo "Usage: ports [-p port1 [port2 ...]] [-P pid1 [pid2 ...]]"
            echo "  no args         → monitor all sockets"
            echo "  -p <ports...>   → monitor by port(s)"
            echo "  -P <pids...>    → monitor by process ID(s)"
            return
            ;;
        -P)
            shift
            [[ $# -eq 0 ]] && { echo "no pid specified"; return 1; }
            local valid_pids=() regex
            for pid in "$@"; do
                ps -p "$pid" &>/dev/null && valid_pids+=("$pid") || echo "⚠️  PID $pid not found"
            done
            [[ ${#valid_pids[@]} -eq 0 ]] && { echo "no valid pids"; return 1; }
            regex=$(printf 'pid=(%s)[,)]|' "${valid_pids[@]}")
            regex=${regex%|}
            watch -n 1 --differences "ss -patun | grep -E '$regex'"
            ;;
        -p)
            shift
            [[ $# -eq 0 ]] && { echo "no port specified"; return 1; }
            local regex
            regex=$(printf '[:.]%s\\b|' "$@")
            regex=${regex%|}
            watch -n 1 --differences "ss -patun | grep -E '$regex'"
            ;;
        *)
            echo "usage: ports [-p port ...] [-P pid ...]"
            ;;
    esac
}

