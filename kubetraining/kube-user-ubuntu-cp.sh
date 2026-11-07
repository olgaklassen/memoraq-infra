#exit

# start using cluster as regular user; configure kubectl client to talk to cluster
mkdir -p $HOME/.kube
#copy admin config file . this file contains api server endpoint, cluster cert , admin creds
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# make ubuntu owner, not root
sudo chown $(id -u):$(id -g) $HOME/.kube/config

wget https://cm.lf.training/LFS258/LFS258_V2025-03-06_SOLUTIONS.tar.xz --user=LFtraining --password=Penguin2014
tar -xvf LFS258_V2025-03-06_SOLUTIONS.tar.xz
# activate Cilium
kubectl apply -f /home/ubuntu/LFS258/SOLUTIONS/s_03/cilium-cni.yaml
# enable kubectl bash completion
sudo apt-get install bash-completion -y

# <exit and log back in>
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc

# generate join for worker
sudo kubeadm token create --print-join-command
# remove noSchedule taint
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl describe node | grep -i taint
# configure crictl to use containerd, sets endpoints to manage containers and images
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock
# download helm
wget https://get.helm.sh/helm-v3.15.2-linux-amd64.tar.gz
tar -xvf helm-v3.15.2-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm
