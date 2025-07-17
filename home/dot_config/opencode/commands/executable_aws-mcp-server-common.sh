#!/bin/bash
set -euo pipefail

run_aws_mcp_server() {
  local server_name="$1"
  local aws_profile="$2"
  local logdir="$HOME/.local/share/opencode/mcp-log"
  mkdir -p "$logdir"
  local logfile="$logdir/${server_name}-stdio-$(date +%Y%m%d-%H%M%S).log"
  local start_time=$(date +%s)

  # Usage help
  if [[ "${1:-}" == "--help" ]]; then
    echo "Usage: $0"
    exit 0
  fi

  {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting $server_name"
    # Check for uv binary
    if ! command -v uv >/dev/null 2>&1; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: uv is not installed or not in PATH"
      exit 1
    fi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Invoking $server_name..."
  } >"$logfile"

  # Run the server, log output to file and also show in terminal
  AWS_PROFILE="$aws_profile" uvx "${server_name}@latest" 2>&1 | tee -a "$logfile"
  local exit_code=${PIPESTATUS[0]}

  {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $server_name exited with code $exit_code"
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script finished in ${duration}s"
  } >>"$logfile"
}
