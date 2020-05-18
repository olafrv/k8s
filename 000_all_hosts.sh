#!/bin/bash

if test -f environment.sh
then
  # Local
  source environment.sh
else
  # Remote (SSH or Vagrant)
  source ~/environment.sh
fi

# Define the common hosts file for all nodes

echo -e "\n#k8s" | sudo tee -a /etc/hosts

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
  echo "${SUBNET}."$((${i}+30))" kwork${i}"
done | sudo tee -a /etc/hosts
