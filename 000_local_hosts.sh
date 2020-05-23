#!/bin/bash

source environment.sh

# Remove k8s servers in /etc/hosts
sudo sed -i -E -e '/#k8s/d' /etc/hosts
sudo sed -i -E -e '/^.*k(load|etcd|mast|work)[0-9]/d' /etc/hosts

if cat /etc/hosts | egrep "k(load|etcd|mast|work)"
then
  echo "Please clean /etc/hosts from any existing k(load|etcd|mast|work) hostname!"
  exit 2
fi 

# Create ./tmp/hosts
mkdir -p tmp/
echo -e "#k8s" | tee tmp/hosts

if [ "$K8S_SETUP" == "vagrant" ]
then

  for i in $(seq -s ' ' 1 $LOADBALANCERS)
  do
    echo "${SUBNET}."$((${i}+10))" kload${i}" 
  done | tee -a tmp/hosts

  for i in $(seq -s ' ' 1 $ETCDS)
  do
    echo "${SUBNET}."$((${i}+20))" ketcd${i}" 
  done | tee -a tmp/hosts

  for i in $(seq -s ' ' 1 $MASTERS)
  do
    echo "${SUBNET}."$((${i}+30))" kmast${i}"
  done | tee -a tmp/hosts

  for i in $(seq -s ' ' 1 $WORKERS)
  do
    echo "${SUBNET}."$((${i}+40))" kwork${i}"
  done | tee -a tmp/hosts

elif [ "$K8S_SETUP" == "multipass" ]
then

  multipass list --format csv | tail -n +2 | egrep "k(load|etcd|mast|work)" | cut -d ',' -f1,3 | sed 's/,/ /' | awk '{print $2 " " $1}' | tee -a tmp/hosts
else 

  echo "Execute: bash 000_local_hosts.sh [vagrant|multipass]"
  exit 2
fi

# Add k8s servers in /etc/hosts
cat tmp/hosts | sudo tee -a /etc/hosts