#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# Stack Mode (etcd as pod managed by kubelet on all nodes)

# sudo tee /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf << EOF
# [Service]
# Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
# ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd
# ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=cgroupfs
# Restart=always
# EOF
# sudo chmod 644 /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf

#sudo kubeadm init phase etcd local --config=kubeadmcfg.yaml
#sudo systemctl daemon-reload
#sudo systemctl restart kubelet
#sudo systemctl status kubelet

# External Mode (Simple Linux Service)

sudo systemctl daemon-reload
sudo systemctl restart etcd
sudo systemctl status etcd
