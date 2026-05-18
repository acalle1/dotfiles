# dotfiles

## Install dependencies

- [Ghostty](https://ghostty.org/docs/install) — terminal emulator
- [Starship](https://starship.rs) — shell prompt
- [mise](https://mise.jdx.dev) — dev tools manager
- [stow](https://www.gnu.org/software/stow/) — symlink manager

## Setup

Clone the repo:

```bash
git clone https://github.com/acalle/dotfiles ~/dotfiles
```

Create symlinks:

```bash
cd ~/dotfiles && stow --target=$HOME .
```

Reload the shell:

```bash
source ~/.bashrc
```

## Adding a new dotfile

1. Create the file at the mirrored path inside `~/dotfiles/` (e.g. `~/.inputrc` → `~/dotfiles/.inputrc`)
2. Run `stow --target=$HOME .` from `~/dotfiles/`