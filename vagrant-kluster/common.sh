#!/bin/bash

# enable ip forwarding
echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.d/k8s.conf
sysctl --system

# containerd installation
apt update
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update
apt install containerd.io -y

# container configuration
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd

# disable swap
swapoff -a

# install kubectl and kubeadm
apt install -y apt-transport-https ca-certificates curl gpg -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install kubelet kubeadm kubectl -y
apt-mark hold kubelet kubeadm kubectl

# enable br_netfilter module for flannel
echo "br_netfilter" >>/etc/modules-load.d/modules.conf
modprobe br_netfilter
