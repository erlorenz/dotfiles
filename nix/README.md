# Nix + home-manager setup (experimental — parallel to yadm)

This directory is a **self-contained, opt-in** alternative to the yadm setup at
the repo root. Nothing here touches or breaks yadm — you can try it on one
machine and keep yadm as the fallback everywhere else.

## The idea

One `flake.nix`, two entry points:

- **macOS** → `nix-darwin` (system + GUI casks) + `home-manager` (user env)
- **Ubuntu / WSL / remote Linux** → `home-manager` standalone (user env only;
  there is no nix-darwin on Linux)

Nix becomes the single thing you install by hand; it installs everything else.
Your dotfiles live in `~/dotfiles` (a normal repo you edit directly — **home is
no longer a git repo**), and home-manager symlinks them into place with
`mkOutOfStoreSymlink`, so edits are **live** without a rebuild.

## Fresh machine

```sh
curl -fsSL https://raw.githubusercontent.com/erlorenz/dotfiles/main/nix/install.sh | bash
```

`install.sh` ensures git/curl (Xcode CLT on mac, apt on Ubuntu), installs
Homebrew on mac (for casks), installs **Nix**, clones the repo to `~/dotfiles`,
runs the switch, and installs Claude Code. The **system git** does the initial
clone; Nix then installs the updated git you actually use.

Day-to-day after that: edit configs live in `~/dotfiles`; run `./rebuild.sh`
only when you change **packages** or the Nix files; `nix flake update` +
`./rebuild.sh` to update everything (deliberate, pinned via `flake.lock`).

> ⚠️ **Testing on a machine that still has yadm files?** home-manager refuses to
> clobber existing dotfiles. `install.sh` passes `-b backup` on Linux (renames
> them to `*.backup`); on macOS, move the yadm-managed files aside first, or
> test in a fresh VM. Don't run yadm and Nix over the same `$HOME` files at once.

## Who owns what (classes of citizen)

| Class | Owner | Where |
|---|---|---|
| Agnostic CLI tools, always-fresh (rg, fd, eza, az, gh, doctl…) | **Nix** | `home.nix` `home.packages` |
| Editor (neovim) + multiplexer (herdr) | **Nix** | `home.nix` (herdr via its own flake input) |
| Language runtimes you version (go, node, python) | **mise** | `~/.config/mise/config.toml` |
| LSP servers, hunkdiff | **mise** | same |
| Per-project tool pins (e.g. Business Central AL tools) | **mise** | project `mise.toml` |
| macOS GUI apps (WezTerm, OrbStack, Chrome, …) | **Homebrew cask** | `darwin.nix`, declared |
| Windows-side WezTerm (work laptop) | **winget** | outside Nix — see `../.github/WORK-SETUP.md` |
| Claude Code (self-updating) | **its own installer** | `install.sh` |

### What stays in mise

Language **runtimes** (go/node/python/ruby/deno), **LSP servers**, and
`npm:hunkdiff`. Everything else — agnostic CLIs, **neovim**, and **herdr** — now
comes from Nix. neovim needs 0.12+ for `vim.pack`; nixpkgs-unstable should have
it, but check `nvim --version` on first build and fall back to the
neovim-nightly overlay if it lags.

## Terminal & multiplexer

**WezTerm stays** as the terminal *emulator* (the GUI window). **herdr** is the
tmux-like, agent-aware *multiplexer* that runs inside it and owns panes/sessions
— replacing WezTerm's native panes and the old `layouts.zsh` helpers. herdr
comes from Nix (its own flake input); its config is `../.config/herdr/config.toml`
— defaults except pane splits, overridden to core-tmux `%` / `"` to match
WezTerm. WezTerm's own muxing stays on a `Ctrl+A` leader (herdr is `Ctrl+B`) so
you can A/B both with identical split keys.

## Files

| File | Purpose |
|---|---|
| `flake.nix` | inputs + the macOS / Linux outputs |
| `home.nix` | shared user env: packages, direnv, dotfile symlinks, zsh OS-conditional |
| `darwin.nix` | macOS system + Homebrew casks |
| `install.sh` | fresh-machine bootstrap (installs Nix, clones, switches) |
| `rebuild.sh` | apply changes / updates |

## Before first run — check these

- `flake.nix` / `darwin.nix`: `aarch64-darwin` assumes Apple Silicon; switch to
  `x86_64-darwin` for Intel. Linux assumes `x86_64-linux`.
- `home.nix`: `home.stateVersion` / `darwin.nix`: `system.stateVersion` — fine as
  defaults, bump per release notes.
- `herdr/config.toml`: the split keybinding syntax was written from herdr's web
  docs, not a live binary — verify with `ctrl+b ?` on first use.
- This whole scaffold is **untested** (no Nix in the authoring environment).
  Treat the first `./rebuild.sh` as a shakeout; expect to nudge a package name
  or two.
