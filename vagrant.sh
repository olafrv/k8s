#!/bin/bash

source environment.sh

bash 000_all_hosts.sh

vagrant up

cat /etc/hosts | egrep "k(load|etcd|mast|work)" | awk '{print $2}' | while read host
do
  ssh-keygen -f ~/.ssh/known_hosts -R $host
  k8s_scp_fu kmast1 './environment.sh' '~/environment.sh'
  k8s_ssh_s $host 000_all_hosts.sh
  k8s_ssh_s $host 010_all_docker.sh
done

cat /etc/hosts | egrep "k(etcd|mast|work)" | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 015_all_k8s.sh
done

cat /etc/hosts | egrep "kload" | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 030_lb_docker_compose.sh
  k8s_ssh_s $host 035_lb_nginx.sh
done

cat /etc/hosts | grep ketcd | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 040_etcd_install.sh
done

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# Temporal
mkdir /tmp/etcd

# Node 1
k8s_ssh_c ketcd1 "sudo -Es kubeadm init phase certs etcd-ca"
k8s_ssh_c ketcd1 "sudo cp /etc/kubernetes/pki/etcd/ca.* /home/$K8S_SSH_USER/; sudo chown $K8S_SSH_USER /home/$K8S_SSH_USER/ca.*"
k8s_ssh_c ketcd1 "ls -l /etc/kubernetes/pki/etcd"
k8s_scp_fd ketcd1 '~/ca.*' '/tmp/etcd/'

# Node 2 ... N
cat /etc/hosts | grep ketcd | grep -v ketcd1 | awk '{print $2}' | while read host
do
    k8s_scp_fu $host '/tmp/etcd/ca.*' '~'
    k8s_ssh_c $host "sudo mkdir -p /etc/kubernetes/pki/etcd/; sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
    k8s_ssh_c $host "ls -l /etc/kubernetes/pki/etcd"
done

cat /etc/hosts | grep ketcd | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 050_etcd_configs.sh
  k8s_ssh_s $host 055_etcd_certs.sh
  k8s_ssh_s $host 060_etcd_init.sh
done

cat /etc/hosts | grep ketcd | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 065_etcd_test.sh
done

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# etcd (any node)
mkdir /tmp/etcd
k8s_ssh_c ketcd1 "sudo cp /etc/kubernetes/pki/etcd/ca.* /home/$K8S_SSH_USER/; sudo chown $K8S_SSH_USER /home/$K8S_SSH_USER/ca.*"
k8s_ssh_c ketcd1 "sudo cp /etc/kubernetes/pki/apiserver-etcd-client.* /home/$K8S_SSH_USER/; sudo chown $K8S_SSH_USER /home/$K8S_SSH_USER/apiserver-etcd-client.*"
k8s_scp_fd ketcd1 '~/ca.*' '/tmp/etcd/'
k8s_scp_fd ketcd1 '~/apiserver-etcd-client.*' '/tmp/etcd/'
ls -l /tmp/etcd/

# k8s masters all nodes
NAMES=($(cat /etc/hosts | grep kmast | awk '{print $2}' | sed 's/\n//' | xargs echo))
for i in "${!NAMES[@]}"; do
  k8s_scp_fu ${NAMES[$i]} '/tmp/etcd/ca.*' '~'
  k8s_scp_fu ${NAMES[$i]} '/tmp/etcd/apiserver-etcd-client.*' '~'
  k8s_ssh_c ${NAMES[$i]} "sudo mkdir -p /etc/kubernetes/pki/etcd/;"
  k8s_ssh_c ${NAMES[$i]} "sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
  k8s_ssh_c ${NAMES[$i]} "sudo mv ~/apiserver-etcd-client.* /etc/kubernetes/pki/; sudo chown root:root /etc/kubernetes/pki/apiserver-etcd-client.*; "
  k8s_ssh_c ${NAMES[$i]} "sudo find /etc/kubernetes/pki"
done

mkdir -p secrets

k8s_ssh_s kmast1 080_master_init.sh | tee secrets/join_command.txt
cat /etc/hosts | grep kmast | grep -v kmast1 | awk '{print $2}' | while read host
do 
  k8s_ssh_s $host 082_master_kubeconfig.sh
done

bash 090_local_download_kube_config
