#!/bin/bash

source environment.sh

bash 000_all_hosts.sh

cat /etc/hosts | egrep "k(load|etcd|mast|work)" | awk '{print $2}' | while read host
do
  ssh-keygen -f ~/.ssh/known_hosts -R $host
  k8s_scp_fu $host './environment.sh' '~/environment.sh'
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

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# Temporal
mkdir /tmp/etcd

# ketcd 1 - Generate and download CA that will be used bv etcd
k8s_ssh_c ketcd1 "sudo rm -rf /etc/kubernetes/pki/etcd/ca.*"
k8s_ssh_c ketcd1 "sudo -Es kubeadm init phase certs etcd-ca"
k8s_ssh_c ketcd1 "sudo cp /etc/kubernetes/pki/etcd/ca.* /home/$K8S_SSH_USER/; sudo chown $K8S_SSH_USER /home/$K8S_SSH_USER/ca.*"
k8s_ssh_c ketcd1 "ls -l /etc/kubernetes/pki/etcd /home/$K8S_SSH_USER/"
k8s_scp_fd ketcd1 '~/ca.*' '/tmp/etcd/'

# ketcd N+1 - Upload CA that will be used by etcd 
cat /etc/hosts | grep ketcd | grep -v ketcd1 | awk '{print $2}' | while read host
do
    k8s_scp_fu $host '/tmp/etcd/ca.*' '~'
    k8s_ssh_c $host "sudo mkdir -p /etc/kubernetes/pki/etcd/; sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
    k8s_ssh_c $host "ls -l /etc/kubernetes/pki/etcd"
done

cat /etc/hosts | grep ketcd | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 040_etcd_install.sh
  k8s_ssh_s $host 050_etcd_configs.sh
  k8s_ssh_s $host 055_etcd_certs.sh
  k8s_ssh_s $host 060_etcd_init.sh
done

cat /etc/hosts | grep ketcd | awk '{print $2}' | while read host
do
  k8s_ssh_s $host 065_etcd_test.sh
done

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

# ketcd 1 - Download etcd CA and API certs that will be used bv masters
mkdir -p /tmp/etcd
k8s_ssh_c ketcd1 "sudo cp /etc/kubernetes/pki/etcd/ca.* /home/$K8S_SSH_USER/; sudo chown $K8S_SSH_USER /home/$K8S_SSH_USER/ca.*"
k8s_ssh_c ketcd1 "sudo cp /etc/kubernetes/pki/apiserver-etcd-client.* /home/$K8S_SSH_USER/; sudo chown $K8S_SSH_USER /home/$K8S_SSH_USER/apiserver-etcd-client.*"
k8s_scp_fd ketcd1 '~/ca.*' '/tmp/etcd/'
k8s_scp_fd ketcd1 '~/apiserver-etcd-client.*' '/tmp/etcd/'
ls -l /tmp/etcd/

# kmast * - Upload etcd CA and API certs to all the masters 
cat /etc/hosts | grep kmast | awk '{print $2}' | while read host
do
  k8s_scp_fu $host '/tmp/etcd/ca.*' '~'
  k8s_scp_fu $host '/tmp/etcd/apiserver-etcd-client.*' '~'
  k8s_ssh_c $host "sudo mkdir -p /etc/kubernetes/pki/etcd/;"
  k8s_ssh_c $host "sudo mv ~/ca.* /etc/kubernetes/pki/etcd/; sudo chown root:root /etc/kubernetes/pki/etcd/*; "
  k8s_ssh_c $host "sudo mv ~/apiserver-etcd-client.* /etc/kubernetes/pki/; sudo chown root:root /etc/kubernetes/pki/apiserver-etcd-client.*; "
  k8s_ssh_c $host "sudo find /etc/kubernetes/pki"
done

# Create folder to save the kubernetes cluster initiliazation output
mkdir -p secrets

k8s_ssh_s kmast1 080_master_init.sh | tee secrets/init.txt
cat /etc/hosts | grep kmast | grep -v kmast1 | awk '{print $2}' | while read host
do 
  k8s_ssh_s $host 082_master_kubeconfig.sh
done

bash 090_local_download_kube_config.sh
