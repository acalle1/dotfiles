#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# programs.home-manager.enable installs the CLI, but it doesn't exist yet before
# the first switch, so fall back to running it straight from the flake.
if command -v home-manager >/dev/null 2>&1; then
  exec home-manager switch --flake ~/.dotfiles#calle
else
  exec nix run github:nix-community/home-manager/release-26.05 -- \
    switch -b backup --flake ~/.dotfiles#calle
fi
