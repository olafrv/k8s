#!/bin/bash

# https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md
# https://etcd.io/docs/v3.4.0/dl-build/
kubeadm version
kubeadm config images list --kubernetes-version v1.18.0

sudo apt -y install golang

rm -rf /home/ubuntu/go
mkdir -p /home/ubuntu/go
export GOPATH=/home/ubuntu/go
cd /home/ubuntu/go
git clone https://github.com/etcd-io/etcd.git
cd etcd
git fetch && git fetch --tags
git checkout tags/v3.4.3
go get -v go.etcd.io/etcd
go get -v go.etcd.io/etcd/etcdctl

sudo cp -ax /home/ubuntu/go/bin/etcd /usr/local/bin/etcd
sudo cp -ax /home/ubuntu/go/bin/etcdctl /usr/local/bin/etcdctl