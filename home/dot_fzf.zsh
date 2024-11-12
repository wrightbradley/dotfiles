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

export FZF_DEFAULT_OPTS="\
    --no-mouse \
    --height='80%' \
    --preview='if [ -d {} ]; then tree -C -L 2 {}; elif [ -f {} ]; then bat -f --style=numbers {}; fi' \
    --preview-window='right:60%:wrap,<50(bottom,50%)' \
    --history='$HOME/.fzf_history' --history-size=50 \
    --bind='f3:execute(bat --style=numbers {} || less -f {})' \
    --bind='f4:execute($EDITOR {})' \
    --bind='alt-w:toggle-preview-wrap' \
    --bind='ctrl-j:down,ctrl-k:up' \
    --bind='ctrl-d:half-page-down' \
    --bind='ctrl-u:half-page-up' \
    --bind='ctrl-x:execute(rm -i {+})+abort' \
    --bind='ctrl-l:clear-query+first' \
    --bind='ctrl-y:execute-silent(echo {+} | pbcopy)+abort' \
    --bind='ctrl-\:change-preview-window(hidden|bottom,50%|right:60%)'
    --exact \
    --border='none' \
    --marker='+' \
    --reverse \
    --cycle \
    --no-scrollbar \
    --multi \
    --info=inline \
    --prompt='❯ ' \
    --pointer='→' \
    --color='dark' \
    --color='fg:-1,bg:-1,hl:#9ece6a,fg+:#a9b1d6,bg+:#1D202F,hl+:#9ece6a' \
    --color='info:#9ece6a,prompt:#7aa2f7,pointer:#9ece6a,marker:#e5c07b,spinner:#61afef,header:#7aa2f7'"

# # 'junegunn/fzf', command line fuzzy finder
# export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l $FD_OPTIONS"

# CTRL-T - Paste the selected files and directories onto the command-line
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview='if [ -d {} ]; then tree -C -L 2 {}; elif [ -f {} ]; then bat -f --style=numbers {}; fi'"

# CTRL-R - Paste the selected command from history onto the command-line
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --height 60%
  --preview-window='bottom:3:wrap:border-top,<50(bottom:3:wrap:border-top)'
  --with-nth '2..'
  --preview 'echo {2..}'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --bind 'change:first'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# Override built-in 'cd' shell command to show all subdirs in fzf if called without args (like ALT+C does)
# Alt-C, cd into the selected directory
# export FZF_ALT_C_OPTS="--preview 'tree -C -L 2 {}'"
# export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
# cd() {
#   if [ $# -gt 0 ]; then
#     builtin cd "$@" || return;
#     return;
#   fi
#
#   selected_dir=$(fd --type d $FD_OPTIONS | fzf \
#     --no-multi \
#     --height 60% \
#     --preview 'tree -C -L 2 {}')
#
#   if [ -n "$selected_dir" ]; then
#     cd "$selected_dir" || return;
#   fi
# }

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# for fzf '**' shell completions (vim **<Tab>)
# - The first argument to the function ($1) is the base path to start traversal
_fzf_compgen_path() {
  fd . "$1"
}

# Use fd to generate the list for directory completion (cd **<Tab>)
_fzf_compgen_dir() {
  fd --type d . "$1"
}

# # Enable fuzzy search key bindings and auto completion
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
