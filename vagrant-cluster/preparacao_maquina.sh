sudo apt update && sudo apt upgrade -y &&
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF \
# Apply sysctl params without reboot
&& sudo sysctl --system

# verificar o ip_forward
sysctl net.ipv4.ip_forward

# instalar o containerd()
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
#########################

sudo mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml 

# NÃO pode ter "disabled_plugins = [ ... 'cri' ... ]"
sudo sed -i 's/disabled_plugins *= *\[[^]]*\]/disabled_plugins = []/' /etc/containerd/config.toml

# Use systemd cgroup (recomendado pelo kubeadm)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl enable --now containerd
sudo systemctl restart containerd 

sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock version
# Deve mostrar "Runtime API Version: v1"
#
# DESABILITAR SWAP!!!
#
#
# # Instalar o kubectl, kubelet e kubeadm
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release containerd.io cri-tools
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Habiulitar o serviço kubelet no início
systemctl enable --now kubelet

#APENAS NO NODE MASTER!!!!
export KUBECONFIG=/etc/kubernetes/admin.conf
#
# Para configurar via parâmetros:
# kubeadm init --apiserver-advertise-address 172.89.0.11 --pod-network-cidr 10.244.0.0/16
#
# Para configurar utilizando o arquivo yml:
kubeadm init --config kubeadm-config.yml
