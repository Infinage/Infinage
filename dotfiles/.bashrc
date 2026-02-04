# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Proper locale support
export LANG=en_US.UTF-8

# Useful utilities defined here
export PATH="$HOME/bin:$PATH"

# Termux specific
if [ -n "$TERMUX_VERSION" ]; then
  export XDG_RUNTIME_DIR="${TERMUX__PREFIX}/tmp"
  mkdir -p "$XDG_RUNTIME_DIR"
fi

# Move cursor and navigate history without reaching for arrow keys
# Note: We can jump forward and backward words by Alt-f and Alt-b
bind '"\C-h": backward-char'
bind '"\C-l": forward-char'
bind '"\C-k": previous-history'
bind '"\C-j": next-history'

# shorter alias
alias l='ls -lart --color=auto --human-readable'
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat'
alias nv='nvim'
alias tempd='cd "$(mktemp -d)"'
alias zq='zoxide query'
alias zqi='zoxide query --interactive'
alias nchat='nvim +":CodeCompanionChat" +":wincmd w" +":q"'
alias mm='micromamba'

# List all directories
d() {
    l "${1:-.}" | grep '^d'
}

# Neo + Fzf + Zoxide
# Behaviour:
# 1. no args → fzf current dir
# 2. file → open
# 3. dir → zoxide + fzf inside
# 4. else → zoxide resolve
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
            zq "$resolved" >/dev/null 2>&1 || zoxide add "$resolved"
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

# Print new lines
nl() {
    local count="${1:-1}"
    for ((i=0; i<count; i++)); do
        echo
    done
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

# Setup for caching CPM
export CPM_SOURCE_CACHE=$HOME/.cache/CPM

# Direnv hook and setup
_direnv_hook() {
  local previous_exit_status=$?;
  trap -- '' SIGINT;
  eval "$("/usr/bin/direnv" export bash)";
  trap - SIGINT;
  return $previous_exit_status;
};

if [[ ";${PROMPT_COMMAND[*]:-};" != *";_direnv_hook;"* ]]; then
  if [[ "$(declare -p PROMPT_COMMAND 2>&1)" == "declare -a"* ]]; then
    PROMPT_COMMAND=(_direnv_hook "${PROMPT_COMMAND[@]}")
  else
    PROMPT_COMMAND="_direnv_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
fi

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
    local output_file=

    # check if -f is specified first
    while [[ "$1" == "-f" ]]; do
        shift
        [[ $# -eq 0 ]] && { echo "no file specified"; return 1; }
        output_file="$1"
        shift
    done

    case "$1" in
        "")  ss -patun ;;
        -h|--help)
            echo "Usage: ports [-p port1 [port2 ...]] [-P pid1 [pid2 ...]] [-f file]"
            echo "  no args         → monitor all sockets"
            echo "  -p <ports...>   → monitor by port(s)"
            echo "  -P <pids...>    → monitor by process ID(s)"
            echo "  -f <file>       → write output to file"
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
            if [[ -n "$output_file" ]]; then
                watch -n 1 --differences "ss -patun | grep -E '$regex' | tee -a '$output_file'"
            else
                watch -n 1 --differences "ss -patun | grep -E '$regex'"
            fi
            ;;
        -p)
            shift
            [[ $# -eq 0 ]] && { echo "no port specified"; return 1; }
            local regex
            regex=$(printf '[:.]%s\\b|' "$@")
            regex=${regex%|}
            if [[ -n "$output_file" ]]; then
                watch -n 1 --differences "ss -patun | grep -E '$regex' | tee -a '$output_file'"
            else
                watch -n 1 --differences "ss -patun | grep -E '$regex'"
            fi
            ;;
        *)
            echo "usage: ports [-p port ...] [-P pid ...] [-f file]"
            ;;
    esac
}

# List and manage env variables
envz() {
    eval "env | \
    fzf \
        --bind='ctrl-y:execute(echo {+} | cut -d\"=\" -f2 | ~/bin/copy)' \
        --bind='alt-y:execute(echo {+} | cut -d\"=\" -f1 | ~/bin/copy)' \
        --header=\$'C-Y copy VALUE | A-Y copy KEY\n' \
        --header-lines=0 \
        --preview='echo {+}' \
        --preview-window=down,3,wrap \
        --layout=reverse \
        --height=80%"
}

mvz() {
    [[ $# -lt 2 ]] && { echo "Usage: mvz <file1> ... <dest>"; return 1; }
    local dest="${!#}" files=("${@:1:$#-1}") matches resolved

    matches=$(zoxide query -l "$dest" 2>/dev/null)
    [[ -z "$matches" ]] && { echo "Could not resolve destination: $dest"; return 1; }

    # auto-pick if only one match
    resolved=$(echo "$matches" | { read -r line && [[ -n $line ]] && echo "$line"; cat; }) 
    resolved=$(echo "$matches" | { [ $(echo "$matches" | wc -l) -eq 1 ] && echo "$matches" \
        || fzf --prompt="Select destination> "; }) || return

    mv "${files[@]}" "$resolved"
}

cpz() {
    [[ $# -lt 2 ]] && { echo "Usage: cpz <file1> ... <dest>"; return 1; }
    local dest="${!#}" files=("${@:1:$#-1}") matches resolved

    matches=$(zoxide query -l "$dest" 2>/dev/null)
    [[ -z "$matches" ]] && { echo "Could not resolve destination: $dest"; return 1; }

    # auto-pick if only one match
    resolved=$(echo "$matches" | { [ $(echo "$matches" | wc -l) -eq 1 ] && echo "$matches" \
        || fzf --prompt="Select destination> "; }) || return

    cp -r "${files[@]}" "$resolved"
}

# List all files via fd-fzf
fz() {
  local fd_flags=""
  if [[ "$1" == "-i" ]]; then
    fd_flags="--no-ignore --hidden"
  fi
  fd . --type f $fd_flags 2>/dev/null | fzf
}

# List all folders via FZF and cd to it
dz() {
  local fd_flags=""
  if [[ "$1" == "-i" ]]; then
    fd_flags="--no-ignore --hidden"
  fi

  local dir
  dir="$(fd . --type d --exclude .git $fd_flags 2>/dev/null | fzf)" || return
  [ -n "$dir" ] && cd "$dir"
}

gfile() {
    pushd "$(git rev-parse --show-toplevel)" > /dev/null || return 1

    local commit file
    if [ "$#" -eq 1 ]; then
        commit="$1"
    else
        commit=$(
            git log --oneline --all | \
            fzf \
                --layout=reverse \
                --height=80% \
                --header='Pick a commit to browse files' \
            | awk '{print $1}'
        ) || { popd > /dev/null; return 1; }

        [ -z "$commit" ] && { popd > /dev/null; return 1; }
    fi

    file=$(
        git ls-tree -r "$commit" --name-only | \
        fzf \
            --layout=reverse \
            --height=80% \
            --header="Files in $commit"
    ) || { popd > /dev/null; return; }

    [ -n "$file" ] && git show "$commit:$file"

    popd > /dev/null
}

# Use nvim fzf from CLI!
export FZF_LUA_PATH="~/.local/share/nvim/plugged/fzf-lua"
export FZF_LUA_CLI="$FZF_LUA_PATH/scripts/cli.lua"
alias fgrep="nvim -l $FZF_LUA_CLI live_grep_native"

# Get comfortable with using git log (very powerful)
# git log -G<regex> --grep=<commit-msg> [-p] [-- <path>]

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE="$HOME/bin/micromamba";
export MAMBA_ROOT_PREFIX="$HOME/micromamba";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
