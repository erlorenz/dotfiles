# dotfiles

Cross-platform dotfiles managed by [chezmoi](https://chezmoi.io), targeting macOS (home) and WSL Ubuntu (work).

## Terminal

**Alacritty** is the terminal on all platforms, keeping in sync with Omarchy/Omadots/Omamac.

On Windows, Alacritty runs natively and its config needs to point into the WSL filesystem. Set this up once with PowerShell (run as Administrator):

```powershell
# Create a symlink from the Windows Alacritty config dir into the WSL config
New-Item -ItemType SymbolicLink `
  -Path "$env:APPDATA\alacritty" `
  -Target "\\wsl$\Ubuntu\home\erik\.config\alacritty"
```

After that, chezmoi managing `~/.config/alacritty/` in WSL is all that's needed — Windows picks it up automatically.

The theme files are not managed by chezmoi — clone them once per machine:

```bash
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

## Bootstrap

### 1. Install chezmoi

**macOS:**
```bash
brew install chezmoi
```

**WSL/Ubuntu:**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. Clone and apply

```bash
chezmoi init --apply git@github.com:erlorenz/dotfiles
```

This clones the repo to `~/.local/share/chezmoi` and applies all dotfiles in one shot.

## Daily use

```bash
chezmoi edit ~/.config/nvim/init.lua   # edit a managed file
chezmoi cd                              # jump to source dir
chezmoi apply                          # deploy changes
chezmoi re-add ~/.config/whatever      # sync target edits back to source
chezmoi diff                           # preview what would change
```

Never edit target files (e.g. `~/.config/...`) directly — always edit the source and apply.

## Private / Machine-Specific Config

For work-specific aliases, env vars, or anything not suitable for the public repo, create `~/.config/zsh/local.zsh` manually on that machine. It is sourced automatically by zshrc but never managed by chezmoi.

For secrets (API keys, tokens), use 1Password + chezmoi templates:
```
export WORK_API_KEY="{{ onepasswordRead "op://Work/api-key/credential" }}"
```
