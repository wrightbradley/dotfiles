#!/bin/bash

echo "Install pip"
#sudo apt-get update
#sudo apt-get -y install python3-pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user

echo "Install ansible"
pip3 install --user ansible

# Python 3
#export PATH=$PATH:/Users/$(whoami)/Library/Python/3.7/bin
export PATH=$PATH:$HOME/.local/bin

echo "Installing Ansible Galaxy Dependencies"
ansible-galaxy install -r requirements.yml

echo "BOOTSTRAP RAN" >> /tmp/bootstrap.txt
ansible-playbook -i localhost main.yml