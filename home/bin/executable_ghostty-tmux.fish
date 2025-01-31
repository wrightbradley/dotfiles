#!/usr/bin/env fish

# Define the session name
set SESSION_NAME ghostty

# Define the path to the tmux binary
set TMUX_PATH /opt/homebrew/bin/tmux

# Function to check if tmux is installed
function check_tmux_installed
    if not type -q $TMUX_PATH
        echo "Error: tmux is not installed or not found at $TMUX_PATH"
        exit 1
    end
end

# Function to attach to an existing session or create a new one
function manage_tmux_session
    # Check if the session already exists
    if $TMUX_PATH has-session -t $SESSION_NAME ^/dev/null
        # If the session exists, reattach to it
        $TMUX_PATH attach-session -t $SESSION_NAME
    else
        # If the session doesn't exist, start a new one
        $TMUX_PATH new-session -s $SESSION_NAME -d
        $TMUX_PATH attach-session -t $SESSION_NAME
    end
end

# Main script execution
check_tmux_installed
manage_tmux_session
