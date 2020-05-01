#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/
# https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md

# bash +4.2
HOSTNAME=$(hostname)
INITIAL_CLUSTER=""
HOSTS=("k8s-etcd1" "k8s-etcd2" "k8s-etcd3")
NAMES=("ke1" "ke2" "ke3")
declare -A HMAP
for i in "${!HOSTS[@]}"; do
    HMAP[${HOSTS[$i]}]=${NAMES[$i]}
    if [ $i -eq 0 ]
    then
        INITIAL_CLUSTER="${NAMES[$i]}=https://${HOSTS[$i]}:2380"
    else
        INITIAL_CLUSTER="${INITIAL_CLUSTER},${NAMES[$i]}=https://${HOSTS[$i]}:2380"
    fi
done
echo "initial_cluster: $INITIAL_CLUSTER"
echo "name: ${HMAP[${HOSTNAME}]}"

cat << EOF > kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1beta2"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOSTNAME}"
        peerCertSANs:
        - "${HOSTNAME}"
        extraArgs:
            initial-cluster: ${INITIAL_CLUSTER}
            initial-cluster-state: new
            name: ${HMAP[${HOSTNAME}]}
            listen-peer-urls: https://${HOSTNAME}:2380
            listen-client-urls: https://${HOSTNAME}:2379
            advertise-client-urls: https://${HOSTNAME}:2379
            initial-advertise-peer-urls: https://${HOSTNAME}:2380
EOF

echo ---
cat kubeadmcfg.yaml
echo ---
echo Is YAML file OK (yes/no)?
read answer

if [ "answer" == "yes" ]
then
    kubeadm init phase certs etcd-server --config=kubeadmcfg.yaml
    kubeadm init phase certs etcd-peer --config=kubeadmcfg.yaml
    kubeadm init phase certs etcd-healthcheck-client --config=kubeadmcfg.yaml
    kubeadm init phase certs apiserver-etcd-client --config=kubeadmcfg.yaml
    
    kubeadm init phase etcd local --config=kubeadmcfg.yaml
fi