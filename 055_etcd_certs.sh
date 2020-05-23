#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

sudo rm -f /etc/kubernetes/pki/etcd/healthcheck-client.*
sudo rm -f /etc/kubernetes/pki/etcd/peer.*
sudo rm -f /etc/kubernetes/pki/etcd/server.*
sudo rm -f /etc/kubernetes/pki/apiserver-etcd-client.*

sudo kubeadm init phase certs etcd-server --config=kubeadmcfg-etcd.yaml
sudo kubeadm init phase certs etcd-peer --config=kubeadmcfg-etcd.yaml
sudo kubeadm init phase certs etcd-healthcheck-client --config=kubeadmcfg-etcd.yaml
sudo kubeadm init phase certs apiserver-etcd-client --config=kubeadmcfg-etcd.yaml

sudo find /etc/kubernetes/pki
