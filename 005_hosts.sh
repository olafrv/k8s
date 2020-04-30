#!/bin/bash

sudo tee /etc/hosts << END
127.0.0.1       localhost
127.0.1.1       ${HOSTNAME}

192.168.10.128 k8s-master1 km1
192.168.10.129 k8s-master2 km2
192.168.10.130 k8s-worker1 kw1
192.168.10.131 k8s-worker2 kw2
192.168.10.XXX k8s-etcd1 ke1
192.168.10.XXX k8s-etcd2 ke2
192.168.10.XXX k8s-etcd3 ke3
192.168.10.148 k8s-master-elb mlb k8s-elb

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
END
