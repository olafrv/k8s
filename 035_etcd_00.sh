#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
#  Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
# ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=cgroupfs
Restart=always
EOF

systemctl daemon-reload
systemctl restart kubelet
