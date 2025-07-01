#!/bin/bash

# Get current workspace
current_workspace=$(aerospace list-workspaces --focused)

# Find PiP window ID
pip_win_id=$(aerospace list-windows --all | grep "Picture in Picture" | awk '{print $1}')

# Move PiP window to current workspace
aerospace move-node-to-workspace --window-id "$pip_win_id" "$current_workspace"
