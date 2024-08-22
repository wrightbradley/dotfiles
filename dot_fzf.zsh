#!/bin/bash

if ! command -v fzf &> /dev/null; then
  exit
fi

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
  export FZF_DEFAULT_OPTS='--ansi -m --height 50% --border'
else
  export FZF_DEFAULT_COMMAND='fd --type f -H --exclude ".git" --exclude "node_modules"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# bindkey -r '^T'
# bindkey '^Y' fzf-file-widget

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$(brew --prefix fzf)/shell/completion.zsh" 2> /dev/null

source "$(brew --prefix fzf)/shell/key-bindings.zsh"

export FZF_DEFAULT_OPTS='
    --bind ctrl-j:down,ctrl-k:up
    --exact
    --reverse
    --cycle
    --height=20%
    --info=inline
    --prompt=❯\
    --pointer=→
    --color=dark
    --color=fg:-1,bg:-1,hl:#9ece6a,fg+:#a9b1d6,bg+:#1D202F,hl+:#9ece6a
    --color=info:#9ece6a,prompt:#7aa2f7,pointer:#9ece6a,marker:#e5c07b,spinner:#61afef,header:#7aa2f7'


