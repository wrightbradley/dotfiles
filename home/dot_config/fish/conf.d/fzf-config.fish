#if not command -sq fzf
#    exit
#end
#
#if command -sq rg
#    set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
#    set -gx FZF_DEFAULT_OPTS '--ansi -m --height 50% --border'
#else
#    set -gx FZF_DEFAULT_COMMAND 'fd --type f -H --exclude ".git" --exclude "node_modules"'
#end

# Main fzf configuration
set -gx FZF_DEFAULT_OPTS "\
    --no-mouse \
    --height='80%' \
    --preview='if test -d {}; tree -C -L 2 {}; else; bat -f --style=numbers {}; end' \
    --preview-window='right:60%:wrap,<50(bottom,50%)' \
    --history=$HOME/.fzf_history --history-size=50 \
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

## CTRL-T configuration
#set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
#set -gx FZF_CTRL_T_OPTS "--preview='if test -d {}; tree -C -L 2 {}; else; bat -f --style=numbers {}; end'"
#
## CTRL-R configuration
#set -gx FZF_CTRL_R_OPTS "
#  --height 60%
#  --preview-window='bottom:3:wrap:border-top,<50(bottom:3:wrap:border-top)'
#  --with-nth '2..'
#  --preview 'echo {2..}'
#  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
#  --bind 'change:first'
#  --color header:italic
#  --header 'Press CTRL-Y to copy command into clipboard'"

## Use fd for path completion
#function _fzf_compgen_path
#    fd . $argv[1]
#end
#
## Use fd for directory completion
#function _fzf_compgen_dir
#    fd --type d . $argv[1]
#end
#
## Optional: Custom cd function with fzf integration
#function cd_with_fzf --description "Change directory using fzf"
#    if test (count $argv) -gt 0
#        cd $argv
#        return
#    end
#
#    set -l selected_dir (fd --type d | fzf \
#        --no-multi \
#        --height 60% \
#        --preview 'tree -C -L 2 {}')
#
#    if test -n "$selected_dir"
#        cd $selected_dir
#    end
#end
