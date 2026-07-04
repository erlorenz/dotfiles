# Interactive zsh config. Identical on macOS, WSL, and Linux dev boxes —
# OS-specific bits live in os.zsh (a yadm alternate, symlinked per machine).
# Env vars and PATH live in ~/.zshenv (loaded by all shells, not just
# interactive ones).

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Zsh Options ---
bindkey -e

setopt COMBINING_CHARS
setopt MENU_COMPLETE
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt CHASE_LINKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
unsetopt BEEP

# --- History ---
HISTSIZE=32768
SAVEHIST=32768
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history

# Arrow keys: history search matching current input
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[[C" forward-char
bindkey "^[[D" backward-char

# --- Completion ---
autoload -Uz compinit
if [[ -n $ZDOTDIR/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=* l:|=*'
zstyle ':completion:*' match-hidden-files off
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' select-prompt ''
zstyle ':completion:*' file-list all
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# --- Aliases ---
alias vim=nvim
alias v='vim'
n() { if [[ $# -eq 0 ]]; then nvim .; else nvim "$@"; fi; }

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Dotfiles (yadm: bare git repo, files live in place) ---
# dots st / dots add -u / dots commit -m "..." / dots push / dots pull
alias dots='yadm'
alias dotsync='yadm add -u && yadm commit -m "sync" && yadm push'

# Nudge once an hour if dotfiles have uncommitted or unpushed changes,
# so syncing doesn't rely on memory. Cheap: one git status over ~20 files.
_dots_nudge() {
  local stamp=$XDG_CACHE_HOME/dots-nudge
  [[ -n $stamp(#qN.mh-1) ]] && return
  command -v yadm >/dev/null || return
  local dirty ahead
  dirty=$(yadm status --porcelain -uno 2>/dev/null | wc -l | tr -d ' ')
  ahead=$(yadm rev-list --count '@{u}..HEAD' 2>/dev/null) || ahead=0
  if (( dirty > 0 || ahead > 0 )); then
    print -P "%F{yellow}dotfiles: ${dirty} uncommitted, ${ahead} unpushed — run dotsync%f"
  fi
  mkdir -p ${stamp:h} && touch $stamp
}
_dots_nudge

# Fuzzy find
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='$EDITOR $(ff)'

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Smart cd (zoxide fallback)
alias cd="zd"
zd() {
  if [[ $# -eq 0 ]]; then
    builtin cd ~ && return
  elif [[ -d $1 ]]; then
    builtin cd "$1"
  else
    z "$@" && printf "%s " "->" && pwd || echo "Error: Directory not found"
  fi
}

# Tools
alias c='claude'
alias cx='printf "\033[2J\033[3J\033[H" && claude --dangerously-skip-permissions'
alias oc='opencode'
alias d='docker'

# --- WezTerm dev layouts (replaces the old tmux tdl/tdlm/tsl) ---
source $ZDOTDIR/layouts.zsh

# --- OS-specific (yadm alternate: os.zsh##os.Darwin / os.zsh##os.WSL / ##default) ---
[[ -f $ZDOTDIR/os.zsh ]] && source $ZDOTDIR/os.zsh

# --- Tool Inits ---
command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)

# --- Plugins (cloned by yadm bootstrap; same path on every OS) ---
[[ -f $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] \
  && source $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- Local Overrides (machine-specific, never synced) ---
[[ -f $ZDOTDIR/local.zsh ]] && source $ZDOTDIR/local.zsh
