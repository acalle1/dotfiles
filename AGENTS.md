# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- Every piece of software on this machine is declared here: CLI tools in `home.nix`, system/GUI packages in `packages/dnf.txt` and `packages/flatpak.txt`. Do not install things ad hoc; add them to the right file so the machine stays reproducible.
  The one deliberate exception is Claude Code, which uses its own self-updating native installer; see README.md's "Not managed here".
- There is intentionally no Neovim config in this repo yet; it will be written from scratch. Do not restore the old one from git history.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
