#!/bin/bash
# Script to install packages for initial server configuration
# Copyright (C) 2020 John Tambi (jon.tambi@gmail.com)
# Last revised 2020/10/26

# Set hostname
hostnamectl set-hostname "cka" --static
hostnamectl set-hostname "Lab - CKA" --pretty

# Update OS CentOS 7
yum update -y

# Enable Epel Repository
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install tools
yum -y install -y net-tools wget vim htop git yum-plugin-security telnet yum-utils

# Install Security updates
yum --security check-update
yum update -y --security

# Install ansible
yum install -y ansible

# Setup stable repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
yum install -y docker-ce docker-ce-cli containerd.io

usermod -aG docker $USER

# Start Docker Engine
systemctl enable docker
systemctl start docker

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Disable SELINUX
cp -p /etc/selinux/config /etc/selinux/config.ORI
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Create user ansible
#useradd -s /bin/bash -c "Usuario de despliegue - DevOps" -U devops
#cat << 'EOF' > /etc/sudoers.d/devops
#User_Alias ANSIBLE_AUTOMATION = devops
#ANSIBLE_AUTOMATION ALL=(ALL)      NOPASSWD: ALL
#EOF