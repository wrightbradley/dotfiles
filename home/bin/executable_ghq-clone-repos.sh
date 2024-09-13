#!/bin/bash

gh repo list tackle-io --limit 1000 --no-archived --source --json name --jq '.[] | "https://github.com/tackle-io/\(.name)"' | parallel -j 4 --halt-on-error 1 ghq clone -p --bare --silent {}

base_dir=$TKCODE

# Log a message to standard output
log_info() {
  echo "[INFO] $1"
}

# Log an error message to standard error
log_error() {
  echo "[ERROR] $1" >&2
}

# Log a warning message to standard error
log_warning() {
  echo "[WARNING] $1" >&2
}

# Define a function to process each directory
process_directory() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    log_info "Processing directory: $dir"

    # Use git -C to specify the directory
    if ! git -C "$dir" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"; then
      log_error "Failed to set git config in $dir"
      return 1
    fi

    if ! git -C "$dir" fetch origin; then
      log_error "Failed to fetch from origin in $dir"
      return 1
    fi

    # Determine the default branch
    local default_branch
    default_branch=$(git -C "$dir" remote show origin | grep 'HEAD branch' | awk '{print $NF}')

    # Create worktree based on the default branch
    case "$default_branch" in
    main)
      log_info "Default branch is 'main'."
      worktree_dir="$dir/main"
      ;;
    master)
      log_info "Default branch is 'master'."
      worktree_dir="$dir/master"
      ;;
    staging)
      log_info "Default branch is 'staging'."
      worktree_dir="$dir/staging"
      ;;
    *)
      log_warning "Default branch is neither 'main' nor 'master'. No worktree created."
      return 0
      ;;
    esac

    # Check if the worktree already exists
    if [[ ! -d "$worktree_dir" ]]; then
      log_info "Creating worktree for '$default_branch'..."
      if ! git -C "$dir" worktree add "$worktree_dir" "$default_branch"; then
        log_error "Failed to add worktree '$default_branch' in $dir"
        return 1
      fi
    else
      log_warning "Worktree '$worktree_dir' already exists."
    fi

    # Pull the latest changes on the appropriate branch
    log_info "Pulling latest changes on '$default_branch' in $dir..."
    if ! git -C "$worktree_dir" pull origin "$default_branch"; then
      log_error "Failed to pull latest changes on '$default_branch' in $dir"
      return 1
    fi

  else
    log_warning "$dir is not a directory."
    return 1
  fi
}

# Export the function defining it
export -f process_directory
export -f log_warning
export -f log_info
export -f log_error

# Use find to get directories and parallel to process them
find "$base_dir" -mindepth 1 -maxdepth 1 -type d | parallel -j 4 --halt-on-error 1 --no-notice 'process_directory {}'
