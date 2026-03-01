# Erik's Dotfiles

Cross-platform dotfiles managed by **chezmoi**, targeting macOS (home) and WSL Ubuntu (work).

## Philosophy

Follow DHH's **Omarchy/Omadots** conventions wherever possible — don't reinvent the wheel. Before adding or changing config, check the latest [Omarchy repo](https://github.com/basecamp/omarchy) and [Omadots docs](https://learn.omacom.io/2/the-omarchy-manual/65/dotfiles) for how they handle it. Watch for **Omamac** (macOS-specific variant) at [omamac.org](https://www.omamac.org/) — may adopt when released.

## Environments

| Environment | OS | Use |
|---|---|---|
| Home Mac | macOS | Work + side projects |
| Work | WSL Ubuntu | Work |

**Shell**: zsh on both platforms.

## Core Tools

| Tool | Role | Notes |
|---|---|---|
| **Alacritty** | Terminal emulator | Synced with Omarchy/Omadots/Omamac. Keep minimal — tmux handles splits/tabs |
| **Tmux** | Multiplexer | Primary window/split/tab manager. Prefix: `Ctrl+Space` |
| **Neovim + LazyVim** | Editor | Minimal divergence from Omarchy defaults. Leader: `Space` |
| **VSCode** | IDE | With AI extensions, used alongside terminal workflow |
| **Lazygit** | Git TUI | Omarchy standard |
| **Lazydocker** | Docker TUI | Omarchy standard |
| **Starship** | Prompt | Cross-shell prompt theme |
| **Mise** | Dev tool manager | Runtimes, CLI tools, chezmoi itself |
| **Chezmoi** | Dotfile sync | Deploys configs from this repo to `~/.config/` and `~/` |
| **1Password** | SSH agent | Platform-specific socket/alias config |

## Key Omarchy Keybindings We Follow

- Tmux prefix: `Ctrl+Space` (fallback `Ctrl+B`)
- Neovim leader: `Space`
- `Space Space` — fuzzy find files
- `Space S G` — grep search
- `Space E` — toggle file tree
- `Space G G` — lazygit

## Tool Management with Mise

**System packages** (terminals, fonts, core utils): Homebrew (mac) / apt (linux).

**Everything else** through mise:
- **Global runtimes**: `mise use --global node@lts go@latest python@latest` etc.
- **Per-project tools**: Each project gets its own `mise.toml` with the CLI tools it needs
- **This repo**: `mise.toml` at root installs chezmoi

## Chezmoi Setup

This repo IS the chezmoi source directory. Chezmoi-managed files (prefixed with `dot_`, `private_dot_`, etc.) live at the repo root alongside non-chezmoi files like this CLAUDE.md.

### Naming Conventions

- `dot_config/` → `~/.config/`
- `dot_zshenv.tmpl` → `~/.zshenv`
- `private_dot_ssh/` → `~/.ssh/` (restricted permissions)
- `.tmpl` suffix → processed as Go template before deploying

### Platform Conditionals

Use chezmoi templates for OS-specific config:

```
{{ if eq .chezmoi.os "darwin" -}}
# macOS stuff
{{ else if eq .chezmoi.os "linux" -}}
# Linux/WSL stuff
{{ end -}}
```

Use `.chezmoiignore` to skip files per platform:

```
{{ if ne .chezmoi.os "darwin" }}
# mac-only files to ignore on linux
{{ end }}
```

## Target Repo Structure

```
~/.local/share/chezmoi/                # Chezmoi source directory (standard location)
├── CLAUDE.md                          # This file
├── mise.toml                          # Bootstrap: installs chezmoi
├── .chezmoi.toml.tmpl                 # Per-machine chezmoi config
├── .chezmoiignore                     # Platform-conditional ignores
├── .chezmoitemplates/                 # Shared Go template partials
├── dot_zshenv.tmpl                    # → ~/.zshenv
├── dot_config/
│   ├── alacritty/
│   │   └── alacritty.toml.tmpl        # Terminal config (minimal — tmux does the work)
│   ├── tmux/
│   │   └── tmux.conf.tmpl            # Primary multiplexer config
│   ├── nvim/                          # LazyVim — track Omarchy closely
│   ├── git/                           # Git config
│   ├── zsh/                           # Zsh config
│   ├── starship.toml                  # Starship prompt theme
│   └── mise/
│       └── config.toml                # Global mise settings
```

## WSL Windows-Side Config Sync

Alacritty runs on the Windows side but its config is symlinked into the WSL filesystem. Set up once with PowerShell (run as Administrator):

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$env:APPDATA\alacritty" `
  -Target "\\wsl$\Ubuntu\home\erik\.config\alacritty"
```

After that, chezmoi managing `~/.config/alacritty/` in WSL is sufficient.

## SSH / 1Password

**macOS**: Set the SSH agent socket to 1Password's:

```
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

**WSL**: Alias ssh to the Windows 1Password SSH via ssh.exe:

```zsh
alias ssh="ssh.exe"
```

## Platform Detection

All scripts and configs must check the OS. In shell scripts:

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux/WSL
fi
```

In chezmoi templates: `{{ .chezmoi.os }}` (values: `darwin`, `linux`).

For WSL specifically: check for `/proc/version` containing "microsoft".

## Neovim Notes

- Use LazyVim distribution, same as Omarchy
- Minimal custom plugins/overrides — keep close to upstream
- Watch for **Neovim 0.12+** which introduces its own native package manager — may change how LazyVim works
- Config lives in `dot_config/nvim/`

## Bootstrap

```bash
# 1. Install mise
# macOS:
brew install mise
# WSL/Ubuntu:
curl https://mise.run | sh

# 2. Clone and install
git clone git@github.com:erlorenz/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
mise install          # installs chezmoi via mise.toml

# 3. Apply dotfiles
chezmoi init --apply
```

## Working on These Dotfiles

```bash
mise run apply        # deploy configs to their destinations
mise run diff         # preview what would change
chezmoi edit FILE     # edit a managed file
chezmoi add FILE      # start managing a new file
chezmoi re-add        # update source after editing targets directly
```
