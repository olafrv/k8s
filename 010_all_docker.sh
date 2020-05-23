#!/bin/bash

# Install and configure docker

# https://docs.docker.com/engine/install/ubuntu/

sudo apt-get -y remove docker docker-engine docker.io containerd runc 2>&1 > /dev/null;
sudo apt-get -y update ;
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common ;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ;
sudo apt-key fingerprint 0EBFCD88 ;
sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" ;
sudo apt-get -y update;
sudo apt-get -y install docker-ce docker-ce-cli containerd.io;

sudo usermod -aG docker $(id -un)
docker version;

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl restart docker
