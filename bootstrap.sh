#!/bin/bash

echo "Install pip"
sudo apt-get update
sudo apt-get -y install python3-pip
#curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#python3 get-pip.py --user

echo "Install ansible"
pip3 install --user ansible

# Python 3
#export PATH=$PATH:/Users/$(whoami)/Library/Python/3.7/bin
export PATH=$PATH:$HOME/.local/bin

git submodule init
git submodule foreach 'git fetch origin --tags && git checkout master && git pull'
git submodule update --init --recursive --remote
git checkout develop
git pull
