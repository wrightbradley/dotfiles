# Setup fzf
# ---------
if [[ ! "$PATH" == *${FZF_PATH}/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  export PATH="$PATH:${FZF_PATH}/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${FZF_PATH}/shell/completion.bash" 2>/dev/null

# Key bindings
# ------------
source "${FZF_PATH}/shell/key-bindings.bash"
