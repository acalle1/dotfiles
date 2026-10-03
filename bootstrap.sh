#!/usr/bin/env bash
# Takes a fresh Fedora install from nothing to a built home-manager config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

# home-manager configures the invoking user's $HOME, so this must not run under sudo.
# The steps that need root call sudo themselves.
if [ "$(id -u)" -eq 0 ]; then
  echo "Run ./bootstrap.sh as your normal user, not with sudo." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1 || [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi
# Nix only lands on PATH in new shells; load it here so step 3 can find it.
if ! command -v nix >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: first home-manager switch"
# home-manager isn't installed yet, so run it straight from the flake this once.
# -b backup moves aside any existing ~/.bashrc etc. instead of failing.
nix run github:nix-community/home-manager/release-26.05 -- \
  switch -b backup --flake ~/.dotfiles#calle

echo "==> Step 4: system packages (dnf + flatpak)"
grep -v '^\s*#' "$DIR/packages/dnf.txt" | sed 's/#.*//' | xargs \
  sudo dnf install -y --skip-unavailable
xargs flatpak install -y flathub < "$DIR/packages/flatpak.txt"

echo "==> Done. Open a new terminal, then use ./rebuild.sh for future changes."
