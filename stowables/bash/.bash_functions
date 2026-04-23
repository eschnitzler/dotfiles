#!/bin/bash -i

function getBranch() {
	BRANCH=$(git symbolic-ref --short HEAD)
	echo $BRANCH
}
function getRepo() {
	repo=$(basename "$PWD")
	echo $repo
}

function calc() {
	awk "BEGIN {print $@}"
}

extract() {
	if [ -z ${1} ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Usage: extract <archive> [directory]"
		echo "Example: extract presentation.zip."
		echo "Valid archive types are:"
		echo "tar.bz2, tar.gz, tar.xz, tar, bz2, gz, tbz2,"
		echo "tbz, tgz, lzo, rar, zip, 7z, xz, txz, lzma and tlz"
	else
		case "$1" in
		*.tar.bz2 | *.tbz2 | *.tbz) tar xvjf "$1" ;;
		*.tgz) tar zxvf "$1" ;;
		*.tar.gz) tar xvzf "$1" ;;
		*.tar.xz) tar xvJf "$1" ;;
		*.tar) tar xvf "$1" ;;
		*.rar) 7z x "$1" ;;
		*.zip) unzip "$1" ;;
		*.7z) 7z x "$1" ;;
		*.lzo) lzop -d "$1" ;;
		*.gz) gunzip "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.Z) uncompress "$1" ;;
		*.xz | *.txz | *.lzma | *.tlz) xz -d "$1" ;;
		*) echo "Sorry, '$1' could not be decompressed." ;;
		esac
	fi
}

function whatsNewUpstream() {
	BRANCH=$(git symbolic-ref --short HEAD)
	git fetch

	git log HEAD..origin/"$BRANCH"

	if [[ "$1" == "--diff" ]] || [[ "$1" == "-d" ]]; then
		git difftool HEAD...origin/"$BRANCH"
	fi
	if [[ "$1" == "--patch" ]] || [[ "$1" == "-p" ]]; then
		git log -p HEAD..origin/"$BRANCH"
	fi
}

function makeKinyan() {
	sudo chown -R "$USER:$USER" $@
}


mg() {
    selection=$(manage | grep -vE '^\[.*\]|^Type|^Available|^\s*$' | awk '{print $1}' | fzf --prompt="Select Command:");
    [[ -n $selection ]] && manage "$selection" || echo "Selection cancelled"
}
