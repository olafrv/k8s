#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

kubeadm version
kubeadm config images list --kubernetes-version v1.18.0

# https://etcd.io/docs/v3.4.0/dl-build/
# https://etcd.io/docs/v3.4.0/op-guide/clustering/
# https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md

### With Binary Releases

ETCD_VER=v3.4.8
# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/tmp/etcd-download-test/etcd --version
/tmp/etcd-download-test/etcdctl version

sudo cp -ax /tmp/etcd-download-test/etcd /usr/local/bin/etcd
sudo cp -ax /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl

# With GOPATH
# sudo apt -y install golang
# rm -rf $HOME/go
# mkdir -p $HOME/go
# export GOPATH=$HOME/go
# go get -v go.etcd.io/etcd
# go get -v go.etcd.io/etcd/etcdctl
# sudo cp -ax $GOPATH/bin/etcd /usr/local/bin/etcd
# sudo cp -ax $GOPATH/bin/etcdctl /usr/local/bin/etcdctl

# Without GOPATH
# git clone https://github.com/etcd-io/etcd.git
# cd etcd
# git fetch && git fetch --tags
# git checkout tags/v3.4.3
# ./build
