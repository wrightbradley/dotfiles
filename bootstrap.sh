#!/bin/bash

# https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-dotfiles-for-codespaces

# https://packaging.python.org/guides/installing-using-linux-tools/
echo "Install pip"
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    sudo apt-get update
    sudo apt-get -y install python3-pip
fi

if [ "$(grep -Ei 'fedora|redhat' /etc/*release)" ]; then
    sudo dnf install python3-pip python3-wheel
fi

if [[ $OSTYPE == 'darwin'* ]]; then
    # Check if xcode is installed as it is needed for python3 support
    if [ "$(xcode-select -p > /dev/null 2>&1)" ]; then
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
git submodule foreach 'git fetch origin --tags && git checkout master && git pull'
git submodule update --init --recursive --remote

if [[ $OSTYPE == 'darwin'* ]]; then
    export PATH="$HOME/Library/Python/3.8/bin:/opt/homebrew/bin:$PATH"
fi

echo "Installing Ansible Galaxy Dependencies"
ansible-galaxy install -r requirements.yml

echo "BOOTSTRAP RAN" >> /tmp/bootstrap.txt

if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    if [[ -n "$CODESPACES" ]] && [[ -n "$CODESPACE_VSCODE_FOLDER" ]]; then
        ansible-playbook -i inventories/personal/inventory main.yml --extra-vars "@vars/codespaces.yml"
    else
        ansible-playbook -i inventories/personal/inventory main.yml --extra-vars "@vars/debian.yml" -K
    fi
fi

if [ "$(grep -Ei 'fedora|redhat' /etc/*release)" ]; then
    ansible-playbook -i inventories/personal/inventory main.yml --extra-vars "@vars/rhel.yml" -K
fi

if [[ $OSTYPE == 'darwin'* ]]; then
    ansible-playbook -i inventories/personal/inventory main.yml --extra-vars "@vars/darwin.yml" -K
fi