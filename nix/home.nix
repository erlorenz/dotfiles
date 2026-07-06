# Shared user environment — imported by BOTH the macOS (nix-darwin) and the
# Linux (home-manager standalone) builds. Everything here lands on every
# machine; OS-specific bits are guarded with pkgs.stdenv.isDarwin / isLinux.
#
# The "classes of citizen" — who owns what:
#   • Nix (this file)  — agnostic CLI tools you always want fresh, never
#                        versioned per project (rg, fd, az, gh, ...).
#   • mise (~/.config/mise/config.toml, symlinked below) — language RUNTIMES
#                        you version (go/node/python), LSP servers, hunkdiff,
#                        and per-project tool pins.
#   • Homebrew casks (darwin.nix) — macOS GUI apps.
#   • Claude Code — its own self-updating installer (see install.sh).
{ config, pkgs, lib, user, inputs, ... }:
let
  # The repo is cloned here by install.sh; out-of-store symlinks point at it so
  # editing a config in ~/dotfiles is instantly live (no rebuild for a keymap).
  repo = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.username = user;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";

  # Bump only when the home-manager release notes say to.
  home.stateVersion = "24.11";

  # === Packages: the agnostic CLI floor ===================================
  # These replace the equivalent lines in mise/config.toml. Once you commit to
  # Nix, delete them from mise (keep runtimes + LSP servers + neovim + herdr +
  # hunkdiff there — see nix/README.md "What stays in mise").
  home.packages = with pkgs; [
    # --- shell + login ---
    zsh              # the shell itself (rc files are symlinked below, not generated)

    # --- editor (moved here from mise) ---
    neovim           # needs 0.12+ for vim.pack — verify `nvim --version` on first
                     # build; if nixpkgs lags, add the neovim-nightly-overlay input

    # --- file / search / nav (were in mise) ---
    ripgrep          # rg — also powers nvim grep pickers
    fd               # friendlier find — powers file pickers
    eza              # ls replacement
    bat              # cat with syntax highlighting
    fzf              # fuzzy filter
    zoxide           # smarter cd (z)
    jq               # JSON
    yq-go            # YAML (jq-for-yaml) — suggested addition
    tree-sitter      # CLI nvim-treesitter uses to build parsers

    # --- git & friends ---
    git              # the UPDATED git (system git only bootstraps the clone)
    gh               # GitHub CLI
    lazygit          # git TUI
    delta            # nicer git diffs / pager — suggested addition

    # --- secrets ---
    sops
    age

    # --- prompt ---
    starship

    # --- cloud / infra CLIs (your requests) ---
    azure-cli        # az
    doctl            # DigitalOcean

    # --- misc suggested ---
    btop             # nicer top / system monitor  (drop if unwanted)
  ]
  # herdr — tmux-like agent multiplexer, from its OWN flake (not in nixpkgs).
  # Verify the output attr on first build: `nix run github:ogulcancelik/herdr`
  # implies packages.<system>.default exists.
  ++ [ inputs.herdr.packages.${pkgs.system}.default ]
  # tailscale CLI: Linux only. On macOS the Tailscale.app cask (darwin.nix)
  # ships its own CLI, so installing it here too would collide on PATH.
  ++ lib.optionals pkgs.stdenv.isLinux [
    tailscale
    # docker CLI on Linux/WSL. On macOS, OrbStack provides `docker`, so it is
    # deliberately absent for darwin. If your WSL uses Docker Desktop's WSL
    # integration instead, drop this line (that provides docker too).
    docker-client
  ];

  # === direnv: the Nix per-project workflow ===============================
  # `cd` into a project holding an .envrc (`use flake`) and its dev shell loads
  # automatically. This is how per-project toolchains work under Nix.
  # To activate it, add this line to your .zshrc "Tool Inits" block:
  #   command -v direnv >/dev/null && eval "$(direnv hook zsh)"
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # === Dotfiles: keep YOUR hand-written configs, edited live ==============
  # We do NOT let home-manager generate these — we out-of-store-symlink your
  # existing repo files, so `nvim ~/dotfiles/...` edits are live immediately.
  home.file = {
    ".zshenv".source                  = link "${repo}/.zshenv";
    ".config/zsh/.zshrc".source       = link "${repo}/.config/zsh/.zshrc";
    ".config/zsh/layouts.zsh".source  = link "${repo}/.config/zsh/layouts.zsh";
    ".config/nvim".source             = link "${repo}/.config/nvim";
    ".config/wezterm".source          = link "${repo}/.config/wezterm";
    ".config/herdr".source            = link "${repo}/.config/herdr";
    ".config/starship.toml".source    = link "${repo}/.config/starship.toml";
    ".config/git".source              = link "${repo}/.config/git";
    ".config/mise".source             = link "${repo}/.config/mise";

    # Track just the Claude settings file, not the whole ~/.claude dir (Claude
    # writes runtime state there — we don't want that landing in the repo).
    ".claude/settings.json".source    = link "${repo}/.claude/settings.json";
    ".claude/skills".source           = link "${repo}/.claude/skills";

    # THE ZSH OS-CONDITIONAL — replaces yadm's `os.zsh##os.*` alternates.
    # Your .zshrc sources ~/.config/zsh/os.zsh (unchanged, line 121); here we
    # pick which underlying file that points at, via a real conditional instead
    # of a filename tag. Same three files you already have.
    ".config/zsh/os.zsh".source = link (
      if pkgs.stdenv.isDarwin
      then "${repo}/.config/zsh/os.zsh##os.Darwin"
      else "${repo}/.config/zsh/os.zsh##os.WSL"
    );

    # zsh-autosuggestions at the path your .zshrc expects (line 130), provided
    # by nixpkgs instead of the git clone the yadm bootstrap did. (A store
    # symlink — it's a package, not something you edit.)
    ".local/share/zsh/plugins/zsh-autosuggestions".source =
      "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
  };
}
