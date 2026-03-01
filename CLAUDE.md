# Erik's Dotfiles

Cross-platform dotfiles managed by **chezmoi**, targeting macOS (home) and WSL Ubuntu (work).

## Philosophy

Follow DHH's Omarchy conventions wherever possible — don't reinvent the wheel. Before adding or changing config, check these repos for how they handle it:

| Repo | Description |
|---|---|
| [basecamp/omarchy](https://github.com/basecamp/omarchy) | Core Linux setup — primary reference |
| [omacom-io/omadots](https://github.com/omacom-io/omadots) | Shared dotfile configs |
| [omacom-io/omarchy-zsh](https://github.com/omacom-io/omarchy-zsh) | Zsh config |
| [omacom-io/omamac](https://github.com/omacom-io/omamac) | macOS-specific variant — primary reference for Mac |

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
├── .chezmoi.toml.tmpl                 # Per-machine chezmoi config
├── .chezmoiignore                     # Platform-conditional ignores
├── .chezmoitemplates/                 # Shared Go template partials
├── dot_zshenv.tmpl                    # → ~/.zshenv
├── dot_config/
│   ├── alacritty/
│   │   └── alacritty.toml             # Terminal config — Tokyo Night colors hardcoded
│   ├── btop/
│   │   ├── btop.conf.tmpl             # Platform-conditional (truecolor mac, TTY linux)
│   │   └── themes/
│   │       └── tokyo-night.theme      # Tokyo Night theme for btop
│   ├── tmux/
│   │   └── tmux.conf.tmpl            # Primary multiplexer config
│   ├── nvim/                          # LazyVim — track Omarchy closely
│   ├── git/                           # Git config
│   ├── zsh/                           # Zsh config
│   ├── starship.toml                  # Starship prompt theme
│   └── mise/
│       └── config.toml                # Global mise settings
```

## Themes

We follow how omarchy handles themes — each tool's colors are hardcoded per theme rather than using a theme importer. To switch themes, update these files:

| Tool | File | What to change |
|---|---|---|
| Alacritty | `dot_config/alacritty/alacritty.toml` | Replace `[colors.*]` sections |
| Neovim | `dot_config/nvim/` | Swap colorscheme plugin (e.g. `tokyonight.nvim`) |
| btop | `dot_config/btop/themes/tokyo-night.theme` | Swap theme file, update `color_theme` in btop.conf.tmpl |

Reference themes from the omarchy repo: `themes/<theme-name>/` has `colors.toml` (alacritty), `neovim.lua`, and `btop.theme` for each theme.

Tmux does **not** have a theme — it uses the terminal's colors passively. Style the statusbar in `tmux.conf` independently.

## WSL Windows-Side Config Sync

Alacritty runs on the Windows side but its config is symlinked into the WSL filesystem. Set up once with PowerShell (run as Administrator):

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$env:APPDATA\alacritty" `
  -Target "\\wsl$\Ubuntu\home\erik\.config\alacritty"
```

After that, chezmoi managing `~/.config/alacritty/` in WSL is sufficient.

## Private / Machine-Specific Config

For work-specific aliases, env vars, or anything not suitable for the public repo, create `~/.config/zsh/local.zsh` manually on that machine. It is sourced automatically by zshrc but never managed by chezmoi.

For secrets (API keys, tokens), use 1Password + chezmoi templates:
```
export WORK_API_KEY="{{ onepasswordRead "op://Work/api-key/credential" }}"
```

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
# 1. Install chezmoi
# macOS:
brew install chezmoi
# WSL/Ubuntu:
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Clone and apply dotfiles
chezmoi init --apply git@github.com:erlorenz/dotfiles
```

## Working on These Dotfiles

```bash
chezmoi apply         # deploy configs to their destinations
chezmoi diff          # preview what would change
chezmoi edit FILE     # edit a managed file
chezmoi add FILE      # start managing a new file
chezmoi re-add        # update source after editing targets directly
```
