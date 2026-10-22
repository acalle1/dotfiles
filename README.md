# dotfiles

My Fedora setup, managed with Nix and home-manager.
Modeled on [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles), adapted from nix-darwin to standalone home-manager on Linux.

## What you get

- Nix user packages (ripgrep, fd, fzf, jq, bat, fastfetch, tree, Neovim, tmux, uv)
- Shell (bash, aliases, git helpers, readline bindings, starship prompt, local-only atuin history search)
- Git config
- mise
- Ghostty and tmux configs, symlinked from `home/`
- Global agent instructions (`home/AGENTS.md` -> `~/.claude/CLAUDE.md`)
- Claude Code status line (`home/.claude/statusline.sh` -> `~/.claude/statusline.sh`)
- A declared list of system/GUI packages that stay on dnf and flatpak (`packages/`)

## Fresh-machine setup

```sh
git clone https://github.com/acalle/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh`:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles` (`home.nix` points at config files through it).
3. Runs the first `home-manager switch` (existing dotfiles get a `.backup` suffix).
4. Installs `packages/dnf.txt` and `packages/flatpak.txt`.
   Third-party repos (coprs, RPM Fusion, Docker, Tailscale, VS Code) must be enabled first; see comments in `dnf.txt`.

### Validate without applying

```sh
nix flake check
home-manager build --flake .#calle
```

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

Rollback: `home-manager generations`, then run the `activate` script of the previous generation.

## Where things go

- CLI tool -> `home.packages` (or a `programs.*` block) in `home.nix`
- GUI app or system service -> `packages/dnf.txt` or `packages/flatpak.txt`
- Config file you want to edit live -> `home/`, plus a `mkOutOfStoreSymlink` line in `home.nix`

## How the symlinks work

The files under `home/` are the real files.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/ghostty` straight at `home/.config/ghostty` in this repo, so edits apply without a rebuild.
Run `./rebuild.sh` only when you change `home.nix` itself.
