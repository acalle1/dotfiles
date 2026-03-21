# dotfiles

## Install dependencies

- [Ghostty](https://ghostty.org/docs/install) — terminal emulator
- [Starship](https://starship.rs) — shell prompt: `curl -sS https://starship.rs/install.sh | sh`
- [mise](https://mise.jdx.dev) — dev tools manager: `curl https://mise.run | sh`

## Setup

Clone the repo:

```bash
git clone https://github.com/acalle/dotfiles ~/dotfiles
```

Create symlinks:

```bash
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

rm -rf ~/.bashrc.d
ln -s ~/dotfiles/.bashrc.d ~/.bashrc.d

mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config.ghostty ~/.config/ghostty/config.ghostty

mkdir -p ~/.config
ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml
```

Reload the shell:

```bash
source ~/.bashrc
```
