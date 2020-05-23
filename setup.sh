#!/bin/bash

export K8S_SETUP=$1

source environment.sh $K8S_SETUP

if [ "$K8S_SETUP" == "vagrant" ]
then
  # See: Vagrantfile
  vagrant up
  vagrant snaphost --name before-setup

elif [ "$K8S_SETUP" == "multipass" ]
then

  for i in $(seq -s ' ' 1 $K8S_LOADBALANCERS)
  do
    multipass launch -c 2 -m 512M --name kload$i
  done
  for i in $(seq -s ' ' 1 $K8S_ETCDS)
  do
    multipass launch -c 2 -m 798M --name ketcd$i
  done
  for i in $(seq -s ' ' 1 $K8S_MASTERS)
  do
    multipass launch -c 2 -m 1536M --name kmast$i
  done
  for i in $(seq -s ' ' 1 $K8S_WORKERS)
  do
    multipass launch -c 2 -m 1024M --name kwork$i
  done

else

  echo "Execute: bash setup.sh [vagrant|multipass]"
  exit 2

fi

bash 000_local_hosts.sh "$K8S_SETUP"

cat /etc/hosts | egrep "k(load|etcd|mast|work)" | awk '{print $2}' | while read host
do
  ssh-keygen -f ~/.ssh/known_hosts -R $host
  if [ "$K8S_SETUP" == "multipass" ]
  then
    multipass exec $host -- tee -a ~/.ssh/authorized_keys < ~/.ssh/id_rsa.pub
  fi
  # k8s_scp_fu $host './environment.sh' '~/environment.sh'
  k8s_scp_fu $host './tmp/hosts' '~/hosts'
  k8s_ssh_s $host 005_all_hosts.sh
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

# Join Workers
k8s_scp_fd kmast1 '~/join-command-for-worker' tmp/join-command-for-worker
sed -i -e 's/^/sudo /' tmp/join-command-for-worker
cat /etc/hosts | grep kwork | awk '{print $2}' | while read host
do
  k8s_ssh_s $host tmp/join-command-for-worker
done

# Create local kubeconfig for kubectl
mkdir -p $HOME/.kube
cp $HOME/.kube/config $HOME/.kube/config.backup.$(date +%Y-%m-%d.%H:%M:%S)
k8s_scp_fd kmast1 '~/.kube/config' $HOME/.kube/config-k8s
KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config-k8s \
  kubectl config view --merge --flatten > \
  ~/.kube/config
