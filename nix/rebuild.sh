#!/usr/bin/env bash
# Apply config changes after editing flake.nix / home.nix / darwin.nix, or to
# pick up package updates after `nix flake update`.
#
# NOTE: editing a SYMLINKED config (nvim, zsh, wezterm, herdr) is live already
# and needs NO rebuild — this is only for package/environment changes.
set -euo pipefail
cd "$(dirname "$0")"

if [ "$(uname -s)" = "Darwin" ]; then
  sudo darwin-rebuild switch --flake ".#mac"
else
  home-manager switch --flake ".#erik"
fi
