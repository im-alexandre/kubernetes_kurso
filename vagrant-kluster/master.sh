#!/bin/bash

set -e

cat >kubeadm-config.yml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 172.89.0.11
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
networking:
  podSubnet: 10.244.0.0/16
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF

export KUBECONFIG=/etc/kubernetes/admin.conf

sudo kubeadm init --config kubeadm-config.yml

cat >>/root/.bashrc <<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF
cat >>/home/vagrant/.bashrc <<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubeadm token create --print-join-command >/vagrant/join-command.sh
chmod +x /vagrant/join-command.sh
