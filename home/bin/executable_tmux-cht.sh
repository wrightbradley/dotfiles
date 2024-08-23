#!/usr/bin/env bash

TMUXDIR="$HOME/.config/tmux"

selected=$(cat "$TMUXDIR/tmux-cht-languages" "$TMUXDIR/tmux-cht-command" | fzf)
if [[ -z $selected ]]; then
	exit 0
fi

read -p "Enter Query: " query

if grep -qs "$selected" "$TMUXDIR/tmux-cht-languages"; then
	query=$(echo "$query" | tr ' ' '+')
	TERM=xterm-256color tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
else
	TERM=xterm-256color tmux neww bash -c "curl -s cht.sh/$selected~$query | less"
fi
