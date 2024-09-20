#!/bin/bash

set -Eeuo pipefail

trap cleanup SIGINT SIGTERM ERR EXIT
[[ ! -x "$(command -v date)" ]] && echo "💥 date command not found." && exit 1

# export initial variables
export_metadata() {
  export TODAY=$(date +"%Y-%m-%d")

  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
    debian | ubuntu | linuxmint)
      log "This system is Debian-based."
      export SYSTEM="debian"
      export PATH="$HOME/linuxbrew/.linuxbrew/bin:$PATH"
      ;;
    fedora | centos | rhel)
      log "This system is RHEL-based."
      export SYSTEM="rhel"
      export PATH="$HOME/linuxbrew/.linuxbrew/bin:$PATH"
      ;;
    *)
      die "This system's distribution is not identified by this script."
      ;;
    esac
  elif [[ "$(uname)" == "Darwin" ]]; then
    log "This system is Darwin-based (macOS)."
    export SYSTEM="darwin"
    export PATH="/opt/homebrew/bin:$PATH"
  else
    die "This system's distribution is not identified by this script."
  fi
}

# help text
usage() {
  cat <<EOF
Usage: bootstrap.sh [-h] [-v]

This script will set up dependencies and run ansible to configure the system.

Available options:

-h, --help                Print this help and exit

-v, --verbose             Print script debug info

EOF
  exit
}

# Parse command line args and set flags accordingly
parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  log "Starting up..."

  return 0
}

# verify that system dependancies are in-place
verify_deps() {
  log "Checking for required utilities..."
  [[ ! -x "$(command -v uv)" ]] && log "uv is not installed." && install_system_deps uv
  [[ ! "$(git --version)" ]] && log "git is not installed." && install_system_deps git

  log "All required utilities are installed."
}

install_system_deps() {
  MISSING_PACKAGE=$1
  if [ $SYSTEM == 'debian' ]; then
    if [ "$MISSING_PACKAGE" == 'git' ]; then
      log "Installing git..."
      sudo apt-get update && sudo apt-get -y install git
    fi
  fi

  if [ $SYSTEM == 'rhel' ]; then
    if [ "$MISSING_PACKAGE" == 'git' ]; then
      log "Installing git..."
      sudo dnf install git
    fi
  fi

  if [ $SYSTEM == 'darwin' ]; then
    if [ "$MISSING_PACKAGE" == 'git' ]; then
      die "macOS is missing git...please run 'xcode-select --install'"
      # if [ ! "$(xcode-select -p >/dev/null 2>&1)" ]; then
      #   log "Installing git through xcode..."
      #   xcode-select --install
      # fi
    fi
  fi

  if [ "$MISSING_PACKAGE" == 'uv' ]; then
    log "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log "Installing python..."
    uv python install 3.12
  fi
}

init_chezmoi() {
  log "Installing chezmoi and initializing..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --exclude=encrypted --apply $GITHUB_USERNAME
}

init_ansible_deps() {
  log "Installing git submodules..."
  git submodule init
  git submodule update --init --recursive --remote
  log "Installing Ansible Galaxy dependencies..."
  uvx --from ansible-core ansible-galaxy install -r requirements.yml
}

run_ansible_playbook() {
  if [ $SYSTEM == 'debian' ]; then
    if [[ -n "$CODESPACES" ]] && [[ -n "$CODESPACE_VSCODE_FOLDER" ]]; then
      uvx --from ansible-core ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/codespaces.yml"
    fi
  fi
  if [ $SYSTEM == 'rhel' ]; then
    uvx --from ansible-core ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/rhel.yml" -K
  fi
  if [ $SYSTEM == 'darwin' ]; then
    if [ $WORK_MACHINE ]; then
      uvx --from ansible-core ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/darwin-work.yml" -K
    else
      uvx --from ansible-core ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/darwin.yml" -K
    fi
  fi
}

# Cleanup folders we created
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # if [ -n "${TMP_DIR+x}" ]; then
  # 	#rm -rf "${TMP_DIR}"
  # 	#rm -rf "${BUILD_DIR}"
  # 	log "Deleted temporary working directory ${TMP_DIR}"
  # fi
}

# Logging method
log() {
  echo >&2 -e "[$(date +"%Y-%m-%d %H:%M:%S")] ${1-}"
}

# kill on error
die() {
  local MSG=$1
  local CODE=${2-1} # Bash parameter expansion - default exit status 1. See https://wiki.bash-hackers.org/syntax/pe#use_a_default_value
  log "${MSG}"
  exit "${CODE}"
}

main() {
  export PATH="$HOME/.cargo/bin:$PATH"
  export_metadata
  parse_params "$@"
  verify_deps
  init_chezmoi
  init_ansible_deps
  run_ansible_playbook
  cleanup
}

main "$@"
