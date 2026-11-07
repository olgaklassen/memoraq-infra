# sudo -i
wget https://cm.lf.training/LFS258/LFS258_V2025-03-06_SOLUTIONS.tar.xz --user=LFtraining --password=Penguin2014
tar -xvf LFS258_V2025-03-06_SOLUTIONS.tar.xz
# set auto restart for needrestart. Needed when updating system services
echo "\$nrconf{restart} = 'a';"  | sudo tee -a /etc/needrestart/needrestart.conf
# install ca certificates
apt-get update && apt-get upgrade -y
apt install apt-transport-https software-properties-common ca-certificates socat -y
# disable swap. Requirenment for k8s to have 100% comtrol over ram
swapoff -a
# load overlay filesystem. Filesystem used by container runtimes
modprobe overlay
# load the bridge network filtering module. Required to bridge networking traffic
modprobe br_netfilter
# update kernel networking
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# apply changes to kernel
sudo sysctl --system
# download docker public keys
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install -y containerd.io
# generate default config for containerd
containerd config default | tee /etc/containerd/config.toml
# set use systemd for control group driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
# download k8s keys
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y containerd.io
apt-get install -y kubeadm=1.31.1-1.1 kubelet=1.31.1-1.1 kubectl=1.31.1-1.1
apt-mark hold kubelet kubeadm kubectl

#install additional linux useful packages
apt install tree

# assign ip to alias to use them with lb
echo "$(hostname -i) k8scp" | sudo tee -a /etc/hosts
echo "$(hostname -i) cp" | sudo tee -a /etc/hosts

######## init cp
kubeadm init --config=LFS258/SOLUTIONS/s_03/kubeadm-config.yaml --upload-certs --node-name=cp | tee kubeadm-init.out
