#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# etcd (any node)
mkdir /tmp/etcd
ssh ketcd1 "sudo cp /etc/kubernetes/pki/etcd/ca.* /home/ubuntu/; sudo chown ubuntu:ubuntu /home/ubuntu/ca.*"
ssh ketcd1 "sudo cp /etc/kubernetes/pki/apiserver-etcd-client.* /home/ubuntu/; sudo chown ubuntu:ubuntu /home/ubuntu/apiserver-etcd-client.*"
scp ketcd1:~/ca.* /tmp/etcd/
scp ketcd1:~/apiserver-etcd-client.* /tmp/etcd/
ls -l /tmp/etcd/

# k8s masters all nodes
NAMES=($(cat /etc/hosts | grep kmast | awk '{print $2}' | sed 's/\n//' | xargs echo))
for i in "${!NAMES[@]}"; do
  scp /tmp/etcd/ca.* ${NAMES[$i]}:~
  scp /tmp/etcd/apiserver-etcd-client.* ${NAMES[$i]}:~
  ssh ${NAMES[$i]} "sudo mkdir -p /etc/kubernetes/pki/etcd/;"
  ssh ${NAMES[$i]} "sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
  ssh ${NAMES[$i]} "sudo mv ~/apiserver-etcd-client.* /etc/kubernetes/pki/; sudo chown root:root /etc/kubernetes/pki/apiserver-etcd-client.*; "
done
