# Git aliases

alias ga='git add'
alias gaa='git add --all'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gf='git fetch'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias grb='git rebase'
alias gst='git stash'
alias gstp='git stash pop'
alias gl='git log --oneline --graph --decorate --all'

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
    git fetch origin "${base#origin/}"
    git diff "$(git merge-base HEAD "$base")"
}
