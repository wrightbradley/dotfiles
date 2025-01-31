# Set environment variables
set -g fish_greeting
set -gx EDITOR nvim
set -gx GIT_EDITOR "$EDITOR"
set -gx JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION true
set -gx KUBECONFIG "$HOME/.kube/config"
set -gx KUBE_EDITOR "$EDITOR"
set -gx NODE_OPTIONS "--no-deprecation --max-old-space-size=4096"
set -gx PAGER delta
set -gx PATH "$HOME/.cargo/bin:$PATH"
set -gx PATH "$HOME/bin:$HOME/.local/bin:/usr/local/sbin:$PATH"
set -gx VISUAL "$EDITOR"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx YSU_IGNORED_ALIASES vi vim G
set -gx YSU_IGNORED_GLOBAL_ALIASES
if test -d "$HOME/.bun/bin"
    set -p PATH -p "$HOME/.bun/bin"
end

set -g fish_key_bindings fish_vi_key_bindings

# Homebrew Setup
if test -d /home/linuxbrew/.linuxbrew # Linux
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
else if test -d /opt/homebrew # MacOS
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/homebrew"
end
fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
! set -q MANPATH; and set MANPATH ''
set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH
! set -q INFOPATH; and set INFOPATH ''
set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH


set -gx SSH_AUTH_SOCK ~/.gnupg/S.gpg-agent.ssh
set -gx GPG_TTY $(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# tool setup
command -q direnv && direnv hook fish | source
# command -q zoxide && zoxide init --cmd cd fish | source
command -q zoxide && zoxide init fish | source
command -q mise && mise activate fish | source
command -q starship && starship init fish | source
