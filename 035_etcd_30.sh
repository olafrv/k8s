# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/

docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes k8s.gcr.io/etcd:${ETCD_TAG} etcdctl \
--cert /etc/kubernetes/pki/etcd/peer.crt \
--key /etc/kubernetes/pki/etcd/peer.key \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--endpoints https://${HOST0}:2379 endpoint health --cluster

# https://[HOST0 IP]:2379 is healthy: successfully committed proposal: took = 16.283339ms
# https://[HOST1 IP]:2379 is healthy: successfully committed proposal: took = 19.44402ms
# https://[HOST2 IP]:2379 is healthy: successfully committed proposal: took = 35.926451ms

# Set ${ETCD_TAG} to the version tag of your etcd image. For example 3.4.3-0. 
# To see the etcd image and tag that kubeadm uses execute kubeadm config images
# list --kubernetes-version ${K8S_VERSION}, where ${K8S_VERSION} is for example v1.17.0
# Set ${HOST0}to the IP address of the host you are testing.