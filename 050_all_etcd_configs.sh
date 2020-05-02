#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/
LOADBALANCER=kload1
HOSTNAME=$(hostname -f)
NAME=${HOSTNAME}
IP=$(hostname -i)
INITIAL_CLUSTER=""
HOSTS=($(cat /etc/hosts | grep ketcd | awk '{print $1}' | sed 's/\n//' | xargs echo))
NAMES=($(cat /etc/hosts | grep ketcd | awk '{print $2}' | sed 's/\n//' | xargs echo))

for i in "${!HOSTS[@]}"; do
    if [ $i -eq 0 ]
    then
        INITIAL_CLUSTER="${NAMES[$i]}=https://${HOSTS[$i]}:2380"
    else
        INITIAL_CLUSTER="${INITIAL_CLUSTER},${NAMES[$i]}=https://${HOSTS[$i]}:2380"
    fi
done
echo "initial_cluster: ${INITIAL_CLUSTER}"
echo "name: ${NAME}"

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/
cat << EOF > kubeadmcfg-etcd.yaml
apiVersion: "kubeadm.k8s.io/v1beta2"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOSTNAME}"
        - "${LOADBALANCER}"
        peerCertSANs:
        - "${HOSTNAME}"
        - "${LOADBALANCER}"
        extraArgs:
            initial-cluster: ${INITIAL_CLUSTER}
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${IP}:2380
            listen-client-urls: https://${IP}:2379
            advertise-client-urls: https://${IP}:2379
            initial-advertise-peer-urls: https://${IP}:2380
EOF

# http://dockerlabs.collabnix.com/kubernetes/beginners/Install-and-configure-a-multi-master-Kubernetes-cluster-with-kubeadm.html
# https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/clustering.md
# https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/
sudo tee /etc/systemd/system/etcd.service << EOF
[Unit]
After=network.target
Description=etcd
Documentation=$(date)

[Service]
User=root
Group=root
Type=Simple
ExecStart=/usr/local/bin/etcd --name="${NAME}" --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt --peer-key-file=/etc/kubernetes/pki/etcd/peer.key --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt --peer-client-cert-auth --client-cert-auth --initial-advertise-peer-urls="https://${IP}:2380" --listen-peer-urls="https://${IP}:2380" --listen-client-urls="https://${IP}:2379,http://127.0.0.1:2379" --advertise-client-urls="https://${IP}:2379" --initial-cluster-token=etcd-cluster --initial-cluster="${INITIAL_CLUSTER}" --initial-cluster-state new --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo chmod 644 /etc/systemd/system/etcd.service

# These systemctl use only if you are debugging!!!

# Stack Mode (etcd as pod managed by kubelet on all nodes)

# sudo systemctl daemon-reload
# sudo systemctl restart kubelet
# sudo systemctl status kubelet

# External Mode (Simple Linux Service)

# sudo systemctl daemon-reload
# sudo systemctl restart etcd
# sudo systemctl status etcd