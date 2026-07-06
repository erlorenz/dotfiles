{
  description = "erlorenz cross-platform dotfiles (Nix + home-manager)";

  # Nix has its OWN package set (nixpkgs) and store — it never touches apt/brew
  # for CLI tools. `unstable` is the fresh channel (≈ Homebrew-fresh). Updates
  # are deliberate: `nix flake update` bumps flake.lock, then ./rebuild.sh.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # macOS system layer (defaults + declarative Homebrew casks). macOS only.
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User layer (packages + dotfile symlinks). Used on BOTH macOS and Linux.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # herdr multiplexer — its own flake (not in nixpkgs). No `nixpkgs.follows`:
    # herdr may not expose a nixpkgs input, and forcing follows would error.
    herdr.url = "github:ogulcancelik/herdr";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    user = "erik";
  in
  {
    # === macOS (Apple Silicon) =============================================
    # Apply:  ./rebuild.sh   (or: sudo darwin-rebuild switch --flake .#mac)
    # nix-darwin manages the system + GUI casks and pulls in home-manager for
    # the user env via the shared home.nix. The name "mac" is arbitrary — it
    # just has to match the --flake .#mac in rebuild.sh, regardless of hostname.
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Intel Mac: "x86_64-darwin"
      specialArgs = { inherit user inputs; };
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Migrating from yadm: back up any pre-existing real file (that yadm
          # laid down) to *.backup instead of erroring on the first switch.
          home-manager.backupFileExtension = "backup";
          home-manager.users.${user} = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit user inputs; };
        }
      ];
    };

    # === Ubuntu / WSL / remote Linux (x86_64) ==============================
    # Apply:  ./rebuild.sh   (or: home-manager switch --flake .#erik)
    # No system layer here — that's nix-darwin's job (macOS only). On plain
    # Ubuntu, home-manager standalone manages the whole user environment.
    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux"; # ARM box: "aarch64-linux"
      extraSpecialArgs = { inherit user inputs; };
      modules = [ ./home.nix ];
    };
  };
}
