#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

# For all k8s nodes: etd, master and workers

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

sudo lsmod | grep br_netfilter
sudo tee /etc/sysctl.d/k8s.conf <<EOF
# K8s Network Requirements

net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo apt-get -y update && sudo apt-get install -y apt-transport-https curl ;
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ;
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get -y update ;
sudo apt-get install -y kubelet kubeadm kubectl ;
sudo apt-mark hold kubelet kubeadm kubectl ;
