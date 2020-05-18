#!/bin/bash
source environment.sh

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# Node 1
mkdir /tmp/etcd
ssh ketcd1 "sudo -Es kubeadm init phase certs etcd-ca"
ssh ketcd1 "sudo cp /etc/kubernetes/pki/etcd/ca.* /home/ubuntu/; sudo chown ubuntu:ubuntu /home/ubuntu/ca.*"
scp ketcd1:~/ca.* /tmp/etcd/
ssh ketcd1 "ls -l /etc/kubernetes/pki/etcd"

# Node 2
scp /tmp/etcd/ca.* ketcd2:~
ssh ketcd2 "sudo mkdir -p /etc/kubernetes/pki/etcd/; sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
ssh ketcd2 "ls -l /etc/kubernetes/pki/etcd"

# Node 3
scp /tmp/etcd/ca.* ketcd3:~
ssh ketcd3 "sudo mkdir -p /etc/kubernetes/pki/etcd/; sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
ssh ketcd3 "ls -l /etc/kubernetes/pki/etcd"
