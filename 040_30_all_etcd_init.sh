#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/
# https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md
# https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

# Stack Mode (Inside K8s Cluster as Etcd Pod)

#sudo kubeadm init phase etcd local --config=kubeadmcfg.yaml
#sudo systemctl daemon-reload
#sudo systemctl restart kubelet

# External Mode (Simple Linux Server)

sudo systemctl daemon-reload
sudo systemctl restart etcd
sudo systemctl status etcd
