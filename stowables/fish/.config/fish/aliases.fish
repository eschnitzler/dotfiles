# Basic aliases
alias l="ls --color=auto"
alias ls="ls --color=auto"
alias la="ls -a --color=auto"
alias ll="ls -l --color=auto"
alias cl="clear && ls --color=auto"
alias cla="clear && ls -a --color=auto"
alias c="clear"
alias q="exit"
alias grep="grep --color=auto"

# Docker aliases
alias dc="docker compose"
alias dcf="docker compose -f docker-compose.yml -f .devcontainer/docker-compose.dev.yml"
alias dca='docker attach (dc ps --format {{.Name}}| grep -o -E "[a-zA-Z0-9-]*-web\b")'
alias da='docker attach (docker ps --format "{{.Names}}" | grep -E ".*-web\$" | fzf --prompt="Select a container: ")'
alias cdd='cd ~/dev/(find ~/dev ~/dev/dynpy/packages -mindepth 1 -maxdepth 1 -type d | sed "s|$HOME/dev/||" | fzf --prompt="Select a project: ")'
alias dev='devcontainer open ~/dev/(ls ~/dev|fzf --prompt="Select a project: ")'
alias logx='docker logs -f (docker ps --format {{.Names}} | fzf)'
alias logs='dc logs -f --tail 20'
alias p='docker container exec -it (docker ps --format "{{.Names}}" | grep -E ".*(-dev|dev-1|_dev_1)\$" | fzf --prompt="Select a container: ") bash -c "source /app/.venv/bin/activate && nvim"'
alias restart='docker restart (docker ps --format "{{.Names}}" | grep -E ".*-dev\$" |sed "s/-dev//"| fzf --prompt="Select a container: ")-dev'
alias dcd="docker-compose -f .devcontainer/docker-compose.yml"
alias dls="dyn-liveserve"
alias dup='dc down && dc up -d'
alias dterm="dcf exec dev bash"
alias dpterm="dcd exec dev bash"

# Git workflow aliases
alias amend='git commit --amend --no-edit'
alias wip='git add . && git commit -m "WIP" --no-verify'
alias ctdb='docker exec -it ar-db psql -U docker -w -d postgres -t -c "SELECT datname FROM pg_database WHERE datname <> \'template0\' AND datname <> \'template1\' AND datname <> \'postgres\'" | grep test_ | xargs -I{} docker exec ar-db psql -U docker -w -d postgres -c "DROP DATABASE {};"'
alias cpr='gh pr create -w'
alias vpr='gh pr view -w'

# Python and dev tools
alias python="ptpython --vi"
alias devc="devcontainer open"
alias tmuxa="tmux attach-session -t"

# Git Log
alias gll="git log"
alias gl="git log --oneline"
alias gls="clear && git log --oneline -12"
alias glb="git log --pretty='format:%C(auto)%h%d %B' --color=always | sed '/^\$/d' | less -r"
alias glst="git log --stat"
alias gs="git show"
alias gd="git diff"
alias ghf="git hotfix"

# Git Status / Checkout / Branch
alias g="git status"
alias gb="git branch"
alias gc="git checkout"
alias gcb="git checkout -b"
alias grc="rollcheck"

# Git Add
alias ga="git add ."
alias gca="git add . && git commit -a"

# Git Push
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpp="git pushu"
alias gpl="git pull"

# Git Fetch
alias gf="git fetch"
alias gfa="git fetch --all"

# Git Rebase
alias grb="git rebase"
alias grbi="git rebase -i"
alias gcont="git rebase --continue"
alias gabort="git rebase --abort"
alias gskip="git rebase --skip"

# Git Advanced
alias gitfix="git diff --name-only | uniq | xargs \$EDITOR"
alias gmt="git mergetool"

# Poetry
alias pr="poetry run"
alias migrate="poetry run python manage.py migrate"
alias manage="poetry run python manage.py"

# Project specific
alias pc="dc exec dev pre-commit run"
alias pca="dc exec dev pre-commit run --all-files"
alias po="dc exec dev poetry"
alias ya="dc exec dev yarn"
alias dj="dc exec dev poetry run python manage.py"
alias refresh="latte-dock --replace &>/dev/null &"
