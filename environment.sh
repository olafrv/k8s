#!/bin/bash

export IMAGE_NAME="ubuntu/bionic64"
export LOADBALANCERS=1
export MASTERS=1
export WORKERS=1
export ETCDS=2
export SUBNET="192.168.50" # Kubernetes Pods Subnet (kubeadm init)
export K8S_SSH_USER=vagrant # Change only if not using vagrant

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