#!/usr/bin/env zsh

###############################
# EXPORT ENVIRONMENT VARIABLE #
###############################

export TERM='rxvt-256color'

## XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

## Editor
export EDITOR="nvim"
export VISUAL="nvim"

## Shell Config
export DOTFILES="$XDG_CONFIG_HOME"
export ZDOTDIR="$DOTFILES/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

## Other
export OHMYZSH="$DOTFILES/ohmyzsh"
export VIMCONFIG="$DOTFILES/nvim"
export VOLTA_HOME="$DOTFILES/.volta"

## Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"


## Path
export PATH="/opt/homebrew/bin:$PATH"       # Homebrew
export PATH="$GOBIN:$PATH"                  # Go
export PATH="$VOLTA_HOME/bin:$PATH"         # Volta

