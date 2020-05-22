#!/bin/bash

if test -f ./environment.sh
then
  # Local
  source ./environment.sh
else
  # Remote (SSH or Vagrant)
  source ~/environment.sh
fi

# Remove k8s servers in /etc/hosts
sudo sed -i -E -e '/#k8s/d' /etc/hosts
sudo sed -i -E -e '/^.*k(load|etcd|mast|work)[0-9]/d' /etc/hosts

# Add k8s servers in /etc/hosts

if cat /etc/hosts | egrep "k(load|etcd|mast|work)"
then
  echo "Please clean /etc/hosts from any existing k(load|etcd|mast|work) hostname!"
  exit 2
fi 

echo -e "#k8s" | sudo tee -a /etc/hosts

for i in $(seq -s ' ' 1 $LOADBALANCERS)
do
  echo "${SUBNET}."$((${i}+10))" kload${i}" 
done | sudo tee -a /etc/hosts

for i in $(seq -s ' ' 1 $ETCDS)
do
  echo "${SUBNET}."$((${i}+20))" ketcd${i}" 
done | sudo tee -a /etc/hosts

for i in $(seq -s ' ' 1 $MASTERS)
do
  echo "${SUBNET}."$((${i}+30))" kmast${i}"
done | sudo tee -a /etc/hosts

for i in $(seq -s ' ' 1 $WORKERS)
do
  echo "${SUBNET}."$((${i}+40))" kwork${i}"
done | sudo tee -a /etc/hosts
