#!/bin/bash
SESSION_NAME="ghostty"
TMUX_PATH="/opt/homebrew/bin/tmux"
if ! command -v $TMUX_PATH &>/dev/null; then
  echo "Error: tmux is not installed or not found at $TMUX_PATH."
  exit 1
fi
$TMUX_PATH attach-session -t $SESSION_NAME || {
  $TMUX_PATH new-session -s $SESSION_NAME
}
exec $TMUX_PATH attach-session -t $SESSION_NAME
