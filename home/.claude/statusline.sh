#!/usr/bin/env bash
# Claude Code status line. Reads session JSON on stdin, prints one line:
#   Opus · dotfiles · nix +1 ~2 ?3 · 31% 62k/200k · $1.23
# Schema: https://code.claude.com/docs/en/statusline#available-data

input=$(cat)

eval "$(jq -r '@sh "
model=\(.model.display_name // "?")
dir=\(.workspace.current_dir // .cwd // "")
pct=\(.context_window.used_percentage // 0 | floor)
ctx_size=\(.context_window.context_window_size // 0)
cost=\(.cost.total_cost_usd // 0)
agent=\(.agent.name // "")
worktree=\(.worktree.name // "")
vim_mode=\(.vim.mode // "")
"' <<<"$input")"

# TokyoNight
rgb() { printf '\033[38;2;%sm' "$1"; }
blue=$(rgb '122;162;247')
cyan=$(rgb '125;207;255')
green=$(rgb '158;206;106')
yellow=$(rgb '224;175;104')
orange=$(rgb '255;158;100')
red=$(rgb '247;118;142')
magenta=$(rgb '187;154;247')
dim=$(rgb '86;95;137')
reset=$'\033[0m'
sep=" ${dim}·${reset} "

# green below 50%, yellow below 80%, red above
level() {
  if (($1 >= 80)); then printf '%s' "$red"
  elif (($1 >= 50)); then printf '%s' "$yellow"
  else printf '%s' "$green"
  fi
}

# 61500 -> 62k
human_tokens() {
  if (($1 >= 1000000)); then printf '%dM' $((($1 + 500000) / 1000000))
  else printf '%dk' $((($1 + 500) / 1000))
  fi
}

# Model, directory, git
line="${blue}${model}${reset}${sep}${cyan}${dir##*/}${reset}"

if branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null ||
            git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  status=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(grep -c '^[MADRC]' <<<"$status")
  modified=$(grep -c '^.[MD]' <<<"$status")
  untracked=$(grep -c '^??' <<<"$status")
  git_info="${magenta} ${branch}${reset}"
  ((staged)) && git_info+=" ${green}+${staged}${reset}"
  ((modified)) && git_info+=" ${yellow}~${modified}${reset}"
  ((untracked)) && git_info+=" ${dim}?${untracked}${reset}"
  line+="${sep}${git_info}"
fi

[[ -n $worktree ]] && line+="${sep}${orange}worktree:${worktree}${reset}"
[[ -n $agent ]] && line+="${sep}${orange}agent:${agent}${reset}"
[[ -n $vim_mode ]] && line+="${sep}${dim}${vim_mode}${reset}"

# Context, cost
used_tokens=$((ctx_size * pct / 100))

line+="${sep}$(level "$pct")${pct}%${reset}"
((ctx_size)) && line+=" ${dim}$(human_tokens "$used_tokens")/$(human_tokens "$ctx_size")${reset}"
line+="${sep}${yellow}\$$(printf '%.2f' "$cost")${reset}"

printf '%s\n' "$line"
