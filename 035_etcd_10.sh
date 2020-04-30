# Node 1
ssh ke1 -c "sudo -Es kubeadm init phase certs etcd-ca"
scp ke1:/etc/kubernetes/pki/etcd/ca.crt etc-ca.crt
scp ke1:/etc/kubernetes/pki/etcd/ca.key etc-ca.key

# Node 2
scp etc-ca.* ke2:~
ssh ke2 -c "mv ~/etc-ca.* /etc/kubernetes/pki/etcd/"

# Node 3
scp etc-ca.* ke3:~
ssh ke3 -c "mv ~/etc-ca.* /etc/kubernetes/pki/etcd/"
