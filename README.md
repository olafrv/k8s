# k8s

This scripts creates a kubernetes cluster with separated etcd cluster:

```
------------------------------------------------------------------
 Admin Machine                                     | Host
---|-----------------------------------------------| -------------
 kload1  ......... Load Balancer                   | Guests VM 
   |                                               | - Vagrant
   |----kwork* ... K8s Workers                     | - Multipass
   |----kmast* ... K8s Masters                     |
   |----ketcd* ... Cluster Key-Value Store (etcd)  |
------------------------------------------------------------------
```

## Pre-Requisites

This scripts where tested using the following freaky/nested setup:

- HP Pavilion Gaming Laptop (i9300H 32 GB RAM Windows 10)
  - VMWare Workstation 15 
    - Ubuntu Linux 18.04 (4 vCPU 16 GB RAM)
      - Virtualbox 6.1 w/Oracle Extension Pack
        - Ubuntu Linux 18.04 (K8s servers => Vagrant or Multipass)

But of course, it should work on any Ubuntu Linux 18.04 host with Virtualbox 6.1 + Vagrant or Multipass.

Nodes will be created with the following hostnames according to the numbers defined in *environment.sh*:
```
---------------------------------------------------------
 Name   | Quantity                | Capacity             
---------------------------------------------------------
 kload* | 1 <= LOADBALANCERS <= 9 | 2 vCPU +  512 MB RAM
 ketcd* | 2 <= ETCDS <= 9         | 2 vCPU +  798 MB RAM
 kmast* | 1 <= MASTERS <= 9       | 2 vCPU + 1536 MB RAM
 kwork* | 1 <= WORKERS <= 9       | 2 vCPU + 1024 MB RAM
---------------------------------------------------------
                                  | 8 vCPU + 7740 MB RAM
---------------------------------------------------------
```

**Maximum 9 servers are meant to be created per type**, if more needed you need to modify networks in *000_all_hosts.sh*.

You can modify the CPU and RAM values in the *Vagrant* file but the minimums are already set there as described before.

If you use several kload* you should modify the *080_master_init.sh* accordingly before running *setup.sh*. For example, adding more etcd endpoints (e.g. kload2). 

Defining *"controlPlaneEndpoint:"* as *kload* is not possible, even if resolved from *kload1* and *kload2* via DNS, authentication will fail due to certificates not provisioned for *kload* hostname (at least with this scripts).

Pod network CIDR (Subnet) is defined in the *080_master_init.sh*, you can change it to fit your needs.

## Create Cluster

### Prepare Scripts

Clone the repo and setup the permissions:
```
git@github.com:olafrv/k8s.git
cd k8s
chmod +x *.sh
```

Edit *environment.sh* global variables.
```
source environment.sh
```

### Setup Virtual Machines (Multipass) - RECOMMENDED (LIGHTER)
```
./setup.sh multipass
```

### Setup Virtual Machines (Vagrant) - ALTERNATIVE (HEAVIER)

```
./setup.sh vagrant
```

If you need to run again setup, you can revert every virtual machine to their initial state:
```
vagrant snapshot list
vagrant snapshot restore <vm> before-setup
```

### Output

If everything goes well:

You can use kubectl from you admin machine.
```
kubectl get nodes
```

In the *./secrets/init.txt* will be the output of kubeadm init command.

In the server *kmast1:~/join-command-for-worker* will have the command to join worker nodes.

# K8s Tools (Admin Machine)

The *setup.sh* already download the kubeconfig, but you can rerun it as needed:
```
bash 090_local_download_kube_config.sh
```

If you want to install the kubernetes dashboard:
```
bash 200_local_dashboard.sh   # See more information in this script on how to use it
```

If you want to install more k8s command lines tools:
```
bash 300_local_user_tools.sh  # You can do it manually selection the tools you like
```

It is highly recommended for GUI to try https://k8slens.dev/ in your admin machine, it can deploy metrics server and prometheus for you.

# References

*NNN_*.sh* called from *setup.sh* includes all the references use for creating the k8s cluster.
