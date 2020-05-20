# k8s

## Pre-Requisites

This scripts where tested using the following freaky/nested setup:

- HP Pavilion Gaming Laptop (i9300H 32 GB RAM Windows 10)
  - VMWare Workstation 15 
    - Ubuntu Linux 18.04 (4 vCPU 16 GB RAM)
      - Virtualbox 6.1 w/Oracle Extension Pack
        - Ubuntu Linux 18.04 (K8s servers / Vagrant)

But of course, it should work on any Ubuntu Linux 18.04 host with Virtualbox 6.1.

Nodes will be created with the following hostnames according to the numbers defined in *environment.sh*:
```
* kload1, ..., 1 <= $LOADBALANCERS <= 9 - 2 vCPU +  512 MB RAM
* ketcd1, ..., 2 <= $ETCDS <= 9         - 2 vCPU +  798 MB RAM
* kmast1, ..., 1 <= $MASTERS <= 9       - 2 vCPU + 1536 MB RAM
* kwork1, ..., 1 <= $WORKERS <= 9       - 2 vCPU + 1024 MB RAM
--------------------------------------------------------------
                                          8 vCPU + 7740 MB RAM
```

**Maximum 9 servers are meant to be created per type**, if more needed you need to modify networks in *000_all_hosts.sh*.

You can modify the CPU and RAM values in the *Vagrant* file but the minimums are already set there as described before.

## Create Cluster (Vagrant) - RECOMMENDED

Clone the repo and setup the permissions:
```
git@github.com:olafrv/k8s.git
cd k8s
chmod +x *.sh
```

Edit *environment.sh* global variables and then run:
```
source environment.sh
vagrant up
bash setup.sh
```

If everything goes well, in the *./secrets/init.txt* will be the output of kubeadm init command.

Also in the server *kmast1:~/join-command* will the command to join additional worker nodes.

You can connected to any nodes using the following commands:
```
vagrant ssh kwork1
k8s_ssh_c kwork1
```

## Create Cluster (Without Vagrant)

If you are not using vagrant, you must use the same hostnames listed in the pre-requisites.

You must allow ssh and sudo to the servers from you host (admin) machine:
```
# For each linux node or the one used as base image

# Ensure you can ssh into every node from your admin machine!
ssh-copy-id ubuntu@server

# Ensure other scripts are be able to run sudo without password!
# After SSH into ubuntu@server run the following command:
sudo tee -a /etc/sudoers.d/k8s <EOF
ubuntu  ALL=(ALL:ALL) NOPASSWD:ALL
EOF
```

Change the environment.sh variable K8S_SSH_USER=ubuntu before creating the cluster with *setup.sh*

Finally, configure the network on each server, see the *network.sh*.

# References

*NNN_*.sh* called from *setup.sh* includes all the references use for creating the k8s cluster.
