#!/bin/bash
source environment.sh

mkdir -p $HOME/.kube
cp $HOME/.kube/config $HOME/.kube/config.backup.$(date +%Y-%m-%d.%H:%M:%S)
scp $(id -u)@kmast1:~/.kube/config $HOME/.kube/config-k8s
KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config-k8s \
  kubectl config view --merge --flatten > \
  ~/.kube/config
