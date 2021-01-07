#!/bin/bash
# Script to install packages for initial server configuration
# Copyright (C) 2020 John Tambi (jon.tambi@gmail.com)
# Last revised 2021/01/07

# Set hostname
#hostnamectl set-hostname "cka" --static
#hostnamectl set-hostname "Lab - CKA" --pretty

# Update OS CentOS 7
yum update -y

# Enable Epel Repository
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install tools
yum -y install -y net-tools wget vim htop git yum-plugin-security telnet

# Install Security updates
yum --security check-update
yum update -y --security

# Configure prerequisites Containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# (Install containerd)
## Set up the repository
### Install required packages
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

## Add docker repository
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

## Install containerd
sudo yum update -y && sudo yum install -y containerd.io

## Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml

#cat systemd-config.text >> containerd-config.toml

# Restart containerd
sudo systemctl enable containerd
sudo systemctl restart containerd

# Installing kubeadm, kubelet and kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Disable SELINUX
sudo setenforce 0
cp -p /etc/selinux/config /etc/selinux/config.ORI
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Install kubelet kubeadm kubectl
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

# Create user ansible
#useradd -s /bin/bash -c "Usuario de despliegue - DevOps" -U devops
#cat << 'EOF' > /etc/sudoers.d/devops
#User_Alias ANSIBLE_AUTOMATION = devops
#ANSIBLE_AUTOMATION ALL=(ALL)      NOPASSWD: ALL
#EOF