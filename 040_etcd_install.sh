#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

kubeadm version
kubeadm config images list --kubernetes-version v1.18.0

# https://etcd.io/docs/v3.4.0/dl-build/
# https://etcd.io/docs/v3.4.0/op-guide/clustering/
# https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md

sudo apt -y install golang
rm -rf $HOME/go
mkdir -p $HOME/go

#git clone https://github.com/etcd-io/etcd.git
#cd etcd
#git fetch && git fetch --tags
#git checkout tags/v3.4.3
export GOPATH=$HOME/go
go get -v go.etcd.io/etcd
go get -v go.etcd.io/etcd/etcdctl
#./build

#sudo cp -ax $GOPATH/bin/etcd /usr/local/bin/etcd
#sudo cp -ax $GOPATH/bin/etcdctl /usr/local/bin/etcdctl
