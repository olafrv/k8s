#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

sudo kubeadm init phase certs etcd-server --config=kubeadmcfg-etcd.yaml
sudo kubeadm init phase certs etcd-peer --config=kubeadmcfg-etcd.yaml
sudo kubeadm init phase certs etcd-healthcheck-client --config=kubeadmcfg-etcd.yaml
sudo kubeadm init phase certs apiserver-etcd-client --config=kubeadmcfg-etcd.yaml

sudo find /etc/kubernetes/pki
