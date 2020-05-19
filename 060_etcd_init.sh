#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# Stack Mode (etcd as pod managed by kubelet on all nodes)

# sudo tee /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf << EOF
# [Service]
# Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
# ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd
# Restart=always
# EOF
# sudo chmod 644 /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf

#sudo kubeadm init phase etcd local --config=kubeadmcfg.yaml
#sudo systemctl daemon-reload
#sudo systemctl restart kubelet
#sudo systemctl status kubelet

# External Mode (Simple Linux Service)

sudo rm -rf /var/lib/etcd/*

sudo systemctl disable kubelet
sudo systemctl stop kubelet
sudo systemctl daemon-reload

sudo systemctl enable etcd
sudo systemctl restart etcd
sudo systemctl status etcd
