# Setup kubeconfig for kubectl
mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
