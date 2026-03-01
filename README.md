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

### 3. Install mise tools

```bash
mise install
```

## Daily use

```bash
chezmoi edit ~/.config/nvim/init.lua   # edit a managed file
chezmoi cd                              # jump to source dir
chezmoi apply                          # deploy changes
chezmoi re-add ~/.config/whatever      # sync target edits back to source
chezmoi diff                           # preview what would change
```

Never edit target files (e.g. `~/.config/...`) directly — always edit the source and apply.
