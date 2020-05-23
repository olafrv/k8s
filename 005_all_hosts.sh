#!/bin/bash

# Remove k8s servers in /etc/hosts
sudo sed -i -E -e '/#k8s/d' /etc/hosts
sudo sed -i -E -e '/^.*k(load|etcd|mast|work)[0-9]/d' /etc/hosts

if cat /etc/hosts | egrep "k(load|etcd|mast|work)"
then
  echo "Please clean /etc/hosts from any existing k(load|etcd|mast|work) hostname!"
  exit 2
fi 

# Add k8s servers in /etc/hosts
cat ~/hosts | sudo tee -a /etc/hosts
