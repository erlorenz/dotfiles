# .zshenv

# --- Editor Setup ---
export EDITOR=nvim
export VISUAL=nvim

# --- XDG Base Directory Standards ---
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}

# --- Zsh Config Location ---
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# --- Path Configuration ---
typeset -gU path fpath

# Define path using the (N) flag (Null Glob).
# Zsh will silently ignore directories that do not exist.
path=(
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  # macOS Homebrew & MacPorts
  /opt/{homebrew,local}/{,s}bin(N)

  # Standard System Paths
  /usr/local/{,s}bin(N)

  # Language specific
  $HOME/go/bin(N)

  # mise shims (for non-interactive contexts: VSCode, cron, scripts)
  $HOME/.local/share/mise/shims(N)

  # Append existing system path
  $path
)

# --- SSH Agent ---
# macOS: 1Password's agent. Guarded so Linux/WSL keeps its own agent.
# (This lives here, not in os.zsh, because non-interactive shells need it.)
[[ $OSTYPE == darwin* ]] && export SSH_AUTH_SOCK=$XDG_CONFIG_HOME/op/agent.sock



