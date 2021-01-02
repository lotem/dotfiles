#!/bin/bash

install_dotfiles_recur() {
    local dir="$1"
    local prefix="$2"
    if [[ -z "$(ls "$dir")" ]]; then
        fancy_echo 'directory is empty: %s' "$dir"
        return
    fi
    local dotfile
    local target
    for dotfile in "$dir"/*
    do
	[[ "$dotfile" -ef "$0" ]] && continue
	[[ "$dotfile" =~ .*~$ ]] && continue
        target="${prefix}$(basename "$dotfile")"
	if [[ -d "$dotfile" ]]
	then
	    install_dotfiles_recur "$dotfile" "$target/"
	else
	    fancy_echo 'linking dotfile: %s' "$target"
	    mkdir -p "$(dirname "$target")"
	    ln -snf "$dotfile" "$target"
	fi
    done
}

install_dotfiles() {
    local dir="${1:-dot}"
    dir="$(cd "$(dirname "$0")" >/dev/null 2>&1; cd "$dir" >/dev/null 2>&1; pwd)"
    fancy_echo 'installing dotfiles from %s ...' "$dir"
    install_dotfiles_recur "$dir" "$HOME/."
}
