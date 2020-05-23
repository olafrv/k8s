#!/bin/bash

export K8S_LOADBALANCERS=1
export K8S_MASTERS=1
export K8S_WORKERS=1
export K8S_ETCDS=2
export K8S_SETUP=$1

if [ "$K8S_SETUP" == "vagrant" ]
then
  export K8S_SSH_USER=vagrant
  export K8S_IMAGE_NAME="ubuntu/bionic64" # Only used by vagrant not by multipass!
  export K8S_SUBNET="192.168.50"          # Only used by vagrant not by multipass!
elif [ "$K8S_SETUP" == "multipass" ]
then
  export K8S_SSH_USER=ubuntu
else
  echo "Execute: source environment.sh [vagrant|multipass]"
fi

function k8s_ssh_c
{
  host=$1
  cmd=$2
  ssh -o 'StrictHostKeyChecking no' -q $K8S_SSH_USER@$host $cmd
}
function k8s_ssh_s
{
  host=$1
  script=$2
  ssh -o 'StrictHostKeyChecking no' -q $K8S_SSH_USER@$host < $script
}
function k8s_scp_fu
{
  host=$1
  src=$2
  dst=$3
  scp -o 'StrictHostKeyChecking no' -q $src $K8S_SSH_USER@$host:$dst
}
function k8s_scp_fd
{
  host=$1
  src=$2
  dst=$3
  scp -o 'StrictHostKeyChecking no' -q $K8S_SSH_USER@$host:$src $dst
}
