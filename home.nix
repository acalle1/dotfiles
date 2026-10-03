{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    bat
    fastfetch
    tree
    neovim
    tmux
    uv
    # the font everything renders in
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  # Claude Code is installed with its own native installer (`claude install`) so it
  # self-updates to the latest version instead of waiting on a nixpkgs bump.
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.bash = {
    enable = true;
    # Fedora's system-wide defaults; the generated ~/.bashrc doesn't source them.
    bashrcExtra = ''
      if [ -f /etc/bashrc ]; then
        . /etc/bashrc
      fi
    '';
    shellAliases = {
      cl = "clear";

      ga = "git add";
      gaa = "git add --all";
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gc = "git commit";
      gcm = "git commit -m";
      gca = "git commit --amend";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpl = "git pull";
      gf = "git fetch";
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b";
      gm = "git merge";
      grb = "git rebase";
      gst = "git stash";
      gstp = "git stash pop";
      gl = "git log --oneline --graph --decorate --all";
    };
    initExtra = ''
      # Checkout main or master, whichever exists
      gomain() {
          if git rev-parse --verify main &>/dev/null; then
              git checkout main
          elif git rev-parse --verify master &>/dev/null; then
              git checkout master
          else
              echo "Neither 'main' nor 'master' branch found."
              return 1
          fi
      }

      # Diff current branch against the merge-base with main/master (fetches first)
      gdm() {
          local base
          if git rev-parse --verify origin/main &>/dev/null; then
              base="origin/main"
          elif git rev-parse --verify origin/master &>/dev/null; then
              base="origin/master"
          else
              echo "Neither origin/main nor origin/master found."
              return 1
          fi
          git fetch origin "''${base#origin/}"
          git diff "$(git merge-base HEAD "$base")"
      }
    '';
  };

  programs.readline = {
    enable = true;
    bindings = {
      "\\C-h" = "backward-kill-word";
      "\\e[3;5~" = "kill-word";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "acalle";
        email = "calleandersson2505@gmail.com";
      };
      init.defaultBranch = "master";
      core = {
        editor = "nvim";
        pager = "less -FX";
      };
      pull.rebase = true;
      diff = {
        tool = "nvimdiff";
        guitool = "nvimdiff";
      };
      merge = {
        tool = "nvimdiff";
        conflictstyle = "diff3";
      };
      mergetool = {
        keepBackup = false;
        trustExitCode = false;
        prompt = true;
        nvimdiff.layout = "LOCAL,MERGED,REMOTE";
      };
      difftool.prompt = false;
    };
  };

  # Nix installs mise; mise still manages per-project JVM tools (java, gradle, maven, sbt, scala).
  programs.mise = {
    enable = true;
    globalConfig.tools.usage = "latest";
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  home.file.".tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.tmux.conf";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
