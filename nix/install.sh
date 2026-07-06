#!/usr/bin/env bash
# One-shot setup for a fresh machine on the Nix + home-manager stack.
# Idempotent — safe to re-run. See nix/README.md for the full story.
#
#   macOS:        curl -fsSL https://raw.githubusercontent.com/erlorenz/dotfiles/main/nix/install.sh | bash
#   Ubuntu/WSL:   same
set -euo pipefail

REPO_URL="https://github.com/erlorenz/dotfiles.git"
REPO_DIR="$HOME/github/erlorenz/dotfiles"
USER_NAME="erik"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
os="$(uname -s)"

# --- 0. yadm migration preflight -------------------------------------------
# If this machine still runs yadm, its tracked files are REAL files in $HOME
# and home-manager won't overwrite them. The switch backs them up to *.backup
# (backupFileExtension on darwin, `-b backup` on Linux) rather than deleting —
# but first make sure yadm has NOTHING uncommitted, so no local edit is lost.
if command -v yadm >/dev/null 2>&1 && yadm rev-parse HEAD >/dev/null 2>&1; then
  say "Existing yadm setup detected"
  if [ -n "$(yadm status --porcelain 2>/dev/null)" ]; then
    echo "  yadm has UNCOMMITTED changes — sync them first so nothing is lost:"
    echo "      yadm add -u && yadm commit -m sync && yadm push"
    echo "  then re-run this script."
    exit 1
  fi
  echo "  yadm is clean (all tracked files are safe in the repo)."
  echo "  Conflicting files will be renamed to *.backup during the switch."
  echo "  After you confirm Nix works, decommission yadm — see nix/README.md."
fi

# --- 1. Ensure git + curl (needed only to fetch Nix and clone the repo) ----
# macOS: git/curl ship with the Xcode Command Line Tools (first `git` prompts).
# Ubuntu/WSL: minimal images often have NO git — install it (+ xz for Nix).
if [ "$os" = "Darwin" ]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    say "Installing Xcode Command Line Tools (git, curl) — accept the GUI prompt"
    xcode-select --install || true
    echo "Re-run this script once the tools finish installing."
    exit 0
  fi
  if ! command -v brew >/dev/null 2>&1; then
    say "Installing Homebrew (needed for the GUI casks nix-darwin declares)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
else
  if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
    say "Installing git + curl + xz (apt)"
    sudo apt-get update -y
    sudo apt-get install -y git curl xz-utils
  fi
fi

# --- 2. Install Nix (Determinate Systems installer) ------------------------
# This is the ONE thing you install by hand — it replaces brew+mise+yadm as the
# thing that installs everything else.
if ! command -v nix >/dev/null 2>&1; then
  say "Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install --no-confirm
  # Load Nix into THIS shell session so the switch below works.
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# --- 3. Clone the dotfiles repo (system git does this; Nix git takes over) --
if [ ! -d "$REPO_DIR/.git" ]; then
  say "Cloning dotfiles -> $REPO_DIR"
  mkdir -p "$(dirname "$REPO_DIR")"   # ensure ~/github/erlorenz exists
  git clone "$REPO_URL" "$REPO_DIR"
fi

# --- 4. Build & apply the environment --------------------------------------
# First run bootstraps darwin-rebuild / home-manager via `nix run`; after that
# use ./rebuild.sh. `-b backup` renames any pre-existing dotfile it would
# otherwise refuse to overwrite (important if this machine still has yadm files).
cd "$REPO_DIR/nix"
if [ "$os" = "Darwin" ]; then
  say "Applying nix-darwin config (first run bootstraps darwin-rebuild)"
  sudo nix run nix-darwin -- switch --flake ".#mac"
else
  say "Applying home-manager config"
  nix run home-manager/master -- switch -b backup --flake ".#${USER_NAME}"
fi

# --- 5. Claude Code (self-updating; deliberately NOT pinned in Nix) --------
if ! command -v claude >/dev/null 2>&1; then
  say "Installing Claude Code (self-updates thereafter)"
  curl -fsSL https://claude.ai/install.sh | bash \
    || echo "  (skipped — install Claude Code manually if you want it)"
fi

say "Done. Open a new terminal (or: exec zsh)."
echo "  - Multiplexer: run 'herdr' (installed via mise). prefix is ctrl+b."
echo "  - Windows/WSL: install WezTerm on the WINDOWS side with winget (see WORK-SETUP.md)."
