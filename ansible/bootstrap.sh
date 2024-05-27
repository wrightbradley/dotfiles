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
	[[ ! -x "$(command -v python3)" ]] && log "python3 is not installed." && install_system_deps python3
	[[ ! -x "$(command -v pip3)" ]] && log "pip3 is not installed." && install_system_deps pip3
	[[ ! -x "$(command -v git)" ]] && log "git is not installed." && install_system_deps git

	log "All required utilities are installed."
}

install_system_deps() {
	MISSING_PACKAGE=$1
	if [ $SYSTEM == 'debian' ]; then
		if [ "$MISSING_PACKAGE" == 'python3' ]; then
			log "Installing python3..."
			sudo apt-get update && sudo apt-get -y install python3
		elif [ "$MISSING_PACKAGE" == 'pip3' ]; then
			log "Installing pip..."
			sudo apt-get update && sudo apt-get -y install python3-venv
		elif [ "$MISSING_PACKAGE" == 'git' ]; then
			log "Installing git..."
			sudo apt-get update && sudo apt-get -y install git
		fi
	fi

	if [ $SYSTEM == 'rhel' ]; then
		if [ "$MISSING_PACKAGE" == 'python3' ]; then
			log "Installing python3..."
			sudo dnf install python3
		elif [ "$MISSING_PACKAGE" == 'pip3' ]; then
			log "Installing pip..."
			sudo dnf install python3-pip python3-wheel
		elif [ "$MISSING_PACKAGE" == 'git' ]; then
			log "Installing git..."
			sudo dnf install git
		fi
	fi

	if [ $SYSTEM == 'darwin' ]; then
		if [ "$MISSING_PACKAGE" == 'python3' ]; then
			die "macOS is missing python3..."
		elif [ "$MISSING_PACKAGE" == 'pip3' ]; then
			die "macOS is missing pip3..."
		elif [ "$MISSING_PACKAGE" == 'git' ]; then
			if [ "$(xcode-select -p >/dev/null 2>&1)" ]; then
				log "Installing git through xcode..."
				xcode-select --install
			else
				die "macOS is missing git..."
			fi
		fi
	fi
}

init_ansible_deps() {
	log "Installing ansible..."
	python3 -m venv /tmp/bootstrap/venv
	source /tmp/bootstrap/venv/bin/activate
	pip install ansible-core
	log "Installing git submodules..."
	git submodule init
	git submodule update --init --recursive --remote
	log "Installing Ansible Galaxy dependencies..."
	ansible-galaxy install -r requirements.yml
}

run_ansible_playbook() {
	if [ $SYSTEM == 'debian' ]; then
		if [[ -n "$CODESPACES" ]] && [[ -n "$CODESPACE_VSCODE_FOLDER" ]]; then
			ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/codespaces.yml"
		fi
	fi
	if [ $SYSTEM == 'rhel' ]; then
		ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/rhel.yml" -K
	fi
	if [ $SYSTEM == 'darwin' ]; then
		ansible-playbook -i inventory.ini main.yml --extra-vars "@vars/darwin.yml" -K
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
	export_metadata
	parse_params "$@"
	verify_deps
	init_ansible_deps
	run_ansible_playbook
	cleanup
}

main "$@"
