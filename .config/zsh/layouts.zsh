# Dev layouts driven by `wezterm cli` — native WezTerm panes, no tmux.
# Works the same on macOS and inside WSL (where the Windows wezterm.exe is
# reachable through interop). All functions must run inside a WezTerm pane
# ($WEZTERM_PANE is how the CLI knows which window/tab to talk to).

# Resolve the wezterm binary: native on mac/Linux, wezterm.exe from WSL.
wez() {
  if command -v wezterm >/dev/null; then
    command wezterm "$@"
  elif command -v wezterm.exe >/dev/null; then
    command wezterm.exe "$@"
  else
    echo "wez: wezterm not found" >&2; return 127
  fi
}

# Type a command into a pane and press enter
_wez_run() {
  local pane=$1; shift
  printf '%s\n' "$*" | wez cli send-text --pane-id "$pane" --no-paste
}

# IDE layout: editor left, agent right (30%), terminal strip below editor.
# Usage: dev [agent] [second_agent]      e.g.  dev c    |  dev cx oc
dev() {
  [[ -z $WEZTERM_PANE ]] && { echo "dev: run inside WezTerm"; return 1 }
  local ai="${1:-claude}" ai2="$2"
  local editor=$WEZTERM_PANE dir=$PWD agent agent2

  # Terminal below (15%) — split first so the agent column spans full height
  wez cli split-pane --pane-id "$editor" --bottom --percent 15 --cwd "$dir" >/dev/null

  # Agent column on the right (30%)
  agent=$(wez cli split-pane --pane-id "$editor" --right --percent 30 --cwd "$dir")

  # Optional second agent below the first
  if [[ -n $ai2 ]]; then
    agent2=$(wez cli split-pane --pane-id "$agent" --bottom --percent 50 --cwd "$dir")
    _wez_run "$agent2" "$ai2"
  fi

  _wez_run "$agent" "$ai"
  wez cli activate-pane --pane-id "$editor"
  ${=EDITOR} .
}

# dev layout for every subdirectory, one tab each (old tdlm).
# Usage: devall [agent] [second_agent]
devall() {
  [[ -z $WEZTERM_PANE ]] && { echo "devall: run inside WezTerm"; return 1 }
  local ai="${1:-claude}" ai2="$2" dir pane first=true
  for dir in "$PWD"/*/; do
    [[ -d $dir ]] || continue
    if $first; then
      _wez_run "$WEZTERM_PANE" "cd '${dir%/}' && dev $ai $ai2"
      first=false
    else
      pane=$(wez cli spawn --cwd "${dir%/}")
      _wez_run "$pane" "dev $ai $ai2"
    fi
  done
}

# Swarm: N panes (max 8, two rows) all running the same command (old tsl).
# Usage: swarm <count> <command...>     e.g.  swarm 4 cx
swarm() {
  [[ -z $WEZTERM_PANE ]] && { echo "swarm: run inside WezTerm"; return 1 }
  (( $# >= 2 )) || { echo "Usage: swarm <count> <command...>"; return 1 }
  local n=$1; shift
  local cmd="$*"
  (( n > 8 )) && { echo "swarm: max 8 panes"; return 1 }

  local -a panes
  panes=($WEZTERM_PANE)
  local cols=$(( n > 3 ? (n + 1) / 2 : n ))

  # Build equal-width columns by repeatedly splitting the rightmost pane:
  # to end with even columns, each split takes (remaining-1)/remaining width.
  local i remaining pct
  for (( i = 2; i <= cols; i++ )); do
    remaining=$(( cols - i + 2 ))
    pct=$(( 100 * (remaining - 1) / remaining ))
    panes+=($(wez cli split-pane --pane-id "${panes[-1]}" --right --percent $pct --cwd "$PWD"))
  done

  # Second row: split each column in half until we have n panes
  local col=1
  while (( ${#panes[@]} < n )); do
    panes+=($(wez cli split-pane --pane-id "${panes[$col]}" --bottom --percent 50 --cwd "$PWD"))
    (( col++ ))
  done

  local pane
  for pane in "${panes[@]}"; do
    _wez_run "$pane" "$cmd"
  done
}
