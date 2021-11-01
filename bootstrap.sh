#!/bin/bash

# https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-dotfiles-for-codespaces

# Python 3
PATH=$PATH:/Users/$(whoami)/Library/Python/3.8/bin
PATH=$PATH:$HOME/.local/bin
export PATH

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

echo "Installing Ansible Galaxy Dependencies"
ansible-galaxy install -r requirements.yml

echo "BOOTSTRAP RAN" >> /tmp/bootstrap.txt
ansible-playbook -i inventories/personal/inventory main.yml -K
