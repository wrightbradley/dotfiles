#!/bin/bash

# https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-dotfiles-for-codespaces

# https://packaging.python.org/guides/installing-using-linux-tools/
echo "Install pip"
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release >/dev/null 2>&1)" ]; then
	sudo apt-get update
	sudo apt-get -y install python3-pip
fi

if [ "$(grep -Ei 'fedora|redhat' /etc/*release >/dev/null 2>&1)" ]; then
	sudo dnf install python3-pip python3-wheel
fi

if [[ $OSTYPE == 'darwin'* ]]; then
	# Check if xcode is installed as it is needed for python3 support
	if [ "$(xcode-select -p >/dev/null 2>&1)" ]; then
		echo "Install xcode"
		xcode-select --install
	fi

	# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	# python3 get-pip.py --user
	sudo pip3 install --upgrade pip
fi

echo "Install ansible"
pip3 install --user ansible

git submodule init
git submodule update --init --recursive --remote

# if [[ $OSTYPE == 'darwin'* ]]; then
#   export PATH="$HOME/Library/Python/3.10/bin:/opt/homebrew/bin:$PATH"
# fi

echo "Installing Ansible Galaxy Dependencies"
ansible-galaxy install -r requirements.yml

echo "BOOTSTRAP RAN" >>$HOME/.config/chezmoi/ansible_bootstrap.log

if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release >/dev/null 2>&1)" ]; then
	if [[ -n "$CODESPACES" ]] && [[ -n "$CODESPACE_VSCODE_FOLDER" ]]; then
		ansible-playbook -i inventories/personal/inventory main.yml --extra-vars "@vars/codespaces.yml"
	fi
fi

if [ "$(grep -Ei 'fedora|redhat' /etc/*release >/dev/null 2>&1)" ]; then
	ansible-playbook -i inventories/personal/inventory main.yml --extra-vars "@vars/rhel.yml" -K
fi

if [[ $OSTYPE == 'darwin'* ]]; then
	wget https://github.com/kcrawford/dockutil/releases/download/3.0.2/dockutil-3.0.2.pkg
	sudo installer -pkg dockutil-3.0.2.pkg -target /
	rm -f dockutil-3.0.2.pkg

	#   if [[ $(arch) == 'arm64' ]]; then
	#     sudo softwareupdate --install-rosetta
	#   fi

	ansible-playbook -i inventory.txt main.yml --extra-vars "@vars/darwin.yml" -K
fi
