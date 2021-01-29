#!/bin/bash

echo "Update repos"
sudo apt update

echo "Upgrade packeges"
sudo apt upgrade -y

echo "Install ansible"
sudo apt install -y ansible jq

echo "Setup VIM editor"
ansible-playbook -K config-vim.yaml

echo "Check ansible version"
ansible --version

echo "Add user ansible"
groupadd devops -g 1001
useradd -u 1001 -g devops -d /home/devops -s /bin/bash -c "Usuario devops - ansible" -m devops
echo "devops:devops" | chpasswd

echo "Configure ansible user password-less sudo access"
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
