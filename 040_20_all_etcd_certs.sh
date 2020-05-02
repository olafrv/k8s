#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

sudo kubeadm init phase certs etcd-server --config=kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-peer --config=kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-healthcheck-client --config=kubeadmcfg.yaml
sudo kubeadm init phase certs apiserver-etcd-client --config=kubeadmcfg.yaml

sudo find /etc/kubernetes/pki
