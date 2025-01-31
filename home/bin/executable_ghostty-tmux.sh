#!/bin/bash
# SESSION_NAME="ghostty"
#
# # Check if the session already exists
# /opt/homebrew/bin/tmux has-session -t $SESSION_NAME 2>/dev/null
#
# if [ $? -eq 0 ]; then
#   # If the session exists, reattach to it
#   /opt/homebrew/bin/tmux attach-session -t $SESSION_NAME
# else
#   # If the session doesn't exist, start a new one
#   /opt/homebrew/bin/tmux new-session -s $SESSION_NAME -d
#   /opt/homebrew/bin/tmux attach-session -t $SESSION_NAME
# fi

SESSION_NAME="ghostty"
TMUX_PATH="/opt/homebrew/bin/tmux"
if ! command -v $TMUX_PATH &>/dev/null; then
  echo "Error: tmux is not installed or not found at $TMUX_PATH."
  exit 1
fi
$TMUX_PATH attach-session -t $SESSION_NAME || {
  echo "Creating new tmux session: $SESSION_NAME"
  $TMUX_PATH new-session -s $SESSION_NAME
}
exec $TMUX_PATH attach-session -t $SESSION_NAME
