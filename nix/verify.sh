#!/usr/bin/env bash
# Post-install sanity check for the Nix + home-manager setup.
# Read-only — touches nothing. Prints ✓/✗ per check; exits non-zero if any fail.
#   ./verify.sh
set -uo pipefail

REPO="$HOME/github/erlorenz/dotfiles"
os="$(uname -s)"
pass=0; fail=0; warn=0

ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; pass=$((pass+1)); }
no()   { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=$((fail+1)); }
meh()  { printf '  \033[33m!\033[0m %s\n' "$1"; warn=$((warn+1)); }
hdr()  { printf '\n\033[1m%s\033[0m\n' "$1"; }

# Resolve a symlink fully (readlink -f, with a realpath fallback for old macOS).
resolve() { readlink -f "$1" 2>/dev/null || realpath "$1" 2>/dev/null; }

# Is $1 a symlink that ultimately points into the repo?
link_ok() { # $1 path, $2 label
  local r; r="$(resolve "$1")"
  if [ -L "$1" ] && [ -n "$r" ] && [ "${r#"$REPO"}" != "$r" ]; then
    ok "$2 → repo"
  else
    no "$2 (expected a symlink into $REPO)"
  fi
}

# Is a command present, and (optionally) does it resolve into the nix store?
have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
hdr "Dotfile symlinks (edit-live into the repo)"
[ -d "$REPO" ] && ok "repo cloned at $REPO" || no "repo missing at $REPO"
link_ok "$HOME/.zshenv"                ".zshenv"
link_ok "$HOME/.config/zsh/.zshrc"     ".config/zsh/.zshrc"
link_ok "$HOME/.config/nvim"           ".config/nvim"
link_ok "$HOME/.config/wezterm"        ".config/wezterm"
link_ok "$HOME/.config/herdr"          ".config/herdr"
if git -C "$HOME" rev-parse >/dev/null 2>&1; then
  no "\$HOME is a git repo (yadm not decommissioned?)"
else
  ok "\$HOME is NOT a git repo"
fi

hdr "OS-conditional zsh"
osfile="$(resolve "$HOME/.config/zsh/os.zsh")"
case "$os" in
  Darwin) [ "${osfile%os.Darwin}" != "$osfile" ] && ok "os.zsh → os.Darwin" || no "os.zsh not → os.Darwin ($osfile)" ;;
  *)      [ "${osfile%os.WSL}"    != "$osfile" ] && ok "os.zsh → os.WSL"    || meh "os.zsh → $osfile (expected WSL/default)" ;;
esac

hdr "CLI tools from Nix"
for t in rg fd eza bat jq yq zoxide tree-sitter git gh lazygit delta sops age \
         starship az doctl btop direnv; do
  have "$t" && ok "$t" || no "$t missing"
done
# Prove ripgrep is the Nix one, not brew/mise.
if have rg; then
  case "$(resolve "$(command -v rg)")" in
    *nix/store*) ok "rg resolves into /nix/store" ;;
    *)           meh "rg found but not from /nix/store ($(command -v rg))" ;;
  esac
fi

hdr "Editor + multiplexer (moved to Nix)"
if have nvim; then
  ver="$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  maj="${ver%%.*}"; min="${ver#*.}"
  if [ "${maj:-0}" -gt 0 ] 2>/dev/null || { [ "${maj:-0}" -eq 0 ] && [ "${min:-0}" -ge 12 ]; } 2>/dev/null; then
    ok "neovim $ver (has vim.pack)"
  else
    no "neovim $ver is < 0.12 — your config needs vim.pack (add neovim-nightly-overlay)"
  fi
else
  no "nvim missing"
fi
have herdr && ok "herdr installed (flake output built)" || no "herdr missing (check the flake attr)"

hdr "Runtimes still owned by mise"
have mise && ok "mise present" || no "mise missing"
for r in go node python; do
  have "$r" && ok "$r" || meh "$r not on PATH (mise not activated in this shell?)"
done

if [ "$os" = "Darwin" ]; then
  hdr "GUI apps (Homebrew casks)"
  installed="$(brew list --cask 2>/dev/null)"
  for c in wezterm orbstack google-chrome firefox claude tailscale; do
    printf '%s\n' "$installed" | grep -qx "$c" && ok "$c" || no "$c cask missing"
  done
fi

hdr "Result"
printf '  %d passed, %d failed, %d warnings\n' "$pass" "$fail" "$warn"
[ "$fail" -eq 0 ] && printf '  \033[32mLooks good.\033[0m\n' || printf '  \033[31mSome checks failed — see above.\033[0m\n'
exit "$([ "$fail" -eq 0 ] && echo 0 || echo 1)"
