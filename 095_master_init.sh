# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#manual-certs

# Set up a High Availability etcd cluster with kubeadm
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#external-etcd-nodes

# On the first master node:
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/implementation-details/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/control-plane-flags/
LOADBALANCER=kload1
PNETWORKCIDR=192.168.11.0/24
cat > kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: "${PNETWORKCIDR}"
kubernetesVersion: stable
controlPlaneEndpoint: "${LOADBALANCER}:6443"
etcd:
    external:
        endpoints:
        - https://${LOADBALANCER}:2379
        caFile: /etc/kubernetes/pki/etcd/ca.crt
        certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
        keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: "systemd"
EOF
# sudo kubeadm init --config kubeadm-config.yaml --control-plane-endpoint=kload --upload-certs --pod-network-cidr=${PNETWORKCIDR}
sudo kubeadm init --config kubeadm-config.yaml --upload-certs

# [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/

# On any master node:
# https://kubernetes.io/docs/concepts/cluster-administration/addons/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
# https://rancher.com/blog/2019/2019-03-21-comparing-kubernetes-cni-providers-flannel-calico-canal-and-weave/
kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml

# https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
# kubeadm config view

# On each master to detroy (reset)
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/
# kubeadm reset

# Check Nodes/Pods
watch kubectl get nodes -o wide
watch kubectl get pods --all-namespaces

# Node Labels (Role)
kubectl label node k8s-worker1 node-role.kubernetes.io/worker=worker
kubectl label node k8s-worker2 node-role.kubernetes.io/worker=worker

# Cluster Info
kubectl cluster-info
kubectl cluster-info dump
