# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export VISUAL="nvim"
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export DISABLE_AUTO_TITLE=true
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

[ -z "${XDG_RUNTIME_DIR}" ] && export XDG_RUNTIME_DIR=/run/user/$(id -ru)

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --sort 10000"
if [[ $(command -v fd) != "" ]]; then
	export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude '.git' --type f --type l"
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND="fd -t d . $HOME"
	_fzf_compgen_path() {
		fd . "$1"
	}
	_fzf_compgen_dir() {
		fd --type d . "$1"
	}
else
	export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden --glob "!{node_modules/*,.git/*,.venv/*}"'
fi

if [[ $- == *i* ]]; then
	[ -e "$HOME/.bash_secrets" ] && source "$HOME/.bash_secrets"
	[ -e "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"
	[ -e "$HOME/.bash_functions" ] && source "$HOME/.bash_functions"

	# Setup fzf keybindings
	[ -f ~/.fzf.bash ] && source ~/.fzf.bash
	shopt -s histappend
	HISTFILESIZE=1000000
	HISTSIZE=1000000
	HISTCONTROL=ignoreboth
	HISTIGNORE='ls:bg:fg:history'
	shopt -s cmdhist
	PROMPT_COMMAND='history -a'

	command -v "starship" &>/dev/null && eval "$(starship init bash)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Neovim
export PATH="$PATH:/opt/nvim/"
export PATH="$HOME/.local/share/flatpak/exports/bin:$PATH"
export AWS_REGION=us-east-1
