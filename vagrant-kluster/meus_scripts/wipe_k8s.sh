#!/usr/bin/env bash
set -euo pipefail

echo ">> Parando kubelet (se existir)"
sudo systemctl stop kubelet 2>/dev/null || true

echo ">> kubeadm reset -f"
sudo kubeadm reset -f

echo ">> Limpando CNI"
sudo systemctl stop containerd 2>/dev/null || true
sudo rm -rf /etc/cni/net.d /var/lib/cni
sudo ip link del cni0 2>/dev/null || true
sudo ip link del flannel.1 2>/dev/null || true
sudo ip link del kube-ipvs0 2>/dev/null || true
sudo ip link del tunl0 2>/dev/null || true

echo ">> Limpando iptables"
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

echo ">> Removendo diretórios do k8s"
sudo rm -rf /etc/kubernetes /var/lib/etcd
# mantém /var/lib/kubelet, mas limpa conteúdo para evitar lixos
sudo rm -rf /var/lib/kubelet/*

echo ">> Limpando logs"
sudo rm -rf /var/log/containers /var/log/pods 2>/dev/null || true

echo ">> Limpando artefatos CRI (se crictl existir)"
if command -v crictl >/dev/null 2>&1; then
  sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock pods -q | xargs -r sudo crictl stopp
  sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -aq | xargs -r sudo crictl rm -f
  sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmi -a || true
fi

echo ">> Reiniciando containerd"
sudo systemctl restart containerd
sudo systemctl enable containerd 2>/dev/null || true

echo ">> Desativando swap e ajustando sysctl"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo modprobe br_netfilter 2>/dev/null || true
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf >/dev/null
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sudo sysctl --system >/dev/null

echo ">> OK: nó limpo."

