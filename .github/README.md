# dotfiles

One development environment for every machine: macOS at home, WSL at work,
SSH dev boxes when needed. Managed with [yadm](https://yadm.io) — files live
in their real locations, git tracks them in place. No apply step.

**Stack**: WezTerm (native panes, no tmux) · zsh + starship · Neovim 0.12
(native `vim.pack`, ~6 plugins, no distro) · mise for every tool.

## Daily workflow

```sh
dots status                  # what changed (dots = yadm = git)
dotsync                      # add -u + commit "sync" + push, one shot
dots pull                    # on the other machine
```

A yellow one-liner appears in new shells (max once/hour) if anything is
uncommitted or unpushed — that's the reminder to `dotsync`.

## New machine

```sh
# prereqs — macOS: brew;  Linux/WSL: sudo apt install -y git curl zsh build-essential unzip
yadm clone --bootstrap https://github.com/erlorenz/dotfiles.git
```

Bootstrap installs mise, all global tools + LSP servers, zsh plugins, and
neovim plugins (exact versions from `nvim-pack-lock.json`). For the work
WSL machine, see [WORK-SETUP.md](WORK-SETUP.md).

## Where things go (the rules)

| Thing | Where | Why |
|---|---|---|
| CLI tools, runtimes, LSP servers | global mise (`~/.config/mise/config.toml`) | identical on every machine; LSPs on PATH serve nvim *and* Claude Code |
| GUI / system-level (WezTerm, OrbStack) | brew / winget / apt | mise can't |
| project tool versions | `mise.toml` in the project | pins per repo |
| machine-only shell config | `~/.config/zsh/local.zsh` | sourced if present, never tracked |
| OS-specific shell config | `os.zsh##os.Darwin` / `##os.WSL` / `##default` | yadm alternates — right one symlinked per machine |

## Neovim philosophy

Minimal and owned: every option is commented, plugins are added only on felt
need (most future wants have a one-line `mini.*` module). LSP and the plugin
manager are Neovim-native — no Mason (LSP servers come from mise so agents
can use them too), no lazy.nvim. Completion is blink.cmp (the one place
"top-notch" beat "built-in"). `Ctrl+Space` triggers completion, as decades
of VS Code demand.

## Layouts (inside WezTerm, replaces tmux scripts)

```sh
dev [agent] [agent2]   # editor left, agent(s) right, terminal below
devall [agent]         # a dev tab for every subdirectory
swarm 4 cx             # N panes running the same command
```
