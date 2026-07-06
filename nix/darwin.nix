# macOS-only system layer: nix-darwin settings + GUI apps via Homebrew casks.
# (Linux/WSL never imports this — home-manager standalone has no system layer.)
{ pkgs, user, ... }:
{
  # Which user nix-darwin is configuring (required on recent versions).
  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";

  # Flakes + the modern `nix` CLI.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # zsh as the login shell, system-side (rc files come from home.nix symlinks).
  programs.zsh.enable = true;

  # === GUI apps: Homebrew casks, DECLARED but managed by nix-darwin =========
  # Casks are macOS .app bundles. Nix handles these poorly (signing, Spotlight,
  # auto-update), so Homebrew owns them and we just declare which ones. The
  # `homebrew` module does NOT install Homebrew itself — install.sh does that.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true; # refresh cask definitions on switch
      upgrade = true;    # keep casks up to date on switch
      cleanup = "none";  # never uninstall casks that aren't listed here
    };
    casks = [
      "wezterm"        # terminal EMULATOR (hosts herdr). WSL side: winget — see WORK-SETUP.md
      "orbstack"       # Docker + Linux VMs (also provides the `docker` CLI on mac)
      "tailscale"      # menubar app (bundles its own CLI — that's why home.nix skips it on darwin)
      "google-chrome"  # self-updates via Google Keystone (cask = initial install only)
      "firefox"        # self-updates too
      "claude"         # Claude Desktop (the GUI app; Claude Code CLI is separate — see install.sh)
    ];
  };

  # Pins state migrations; bump per nix-darwin release notes.
  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin"; # Intel: "x86_64-darwin"
}
