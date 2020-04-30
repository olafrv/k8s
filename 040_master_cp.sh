# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#manual-certs

# Set up a High Availability etcd cluster with kubeadm
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#external-etcd-nodes

# On the first master node:
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/implementation-details/
sudo kubeadm init [--config kubeadm-with-etd.yaml] --control-plane-endpoint=mlb --upload-certs --pod-network-cidr=192.168.11.0/24

# [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/

# On any master node:
# https://kubernetes.io/docs/concepts/cluster-administration/addons/
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
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
