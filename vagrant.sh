#!/bin/bash
source environment.sh
bash 000_all_hosts.sh
vagrant up
bash 045_local_etcd1_ca_etcds.sh
cat /etc/hosts | grep ketcd | awk '{print $2}' | while read host
do
  ssh -q $(id -un)@$host < 050_etcd_configs.sh
  ssh -q $(id -un)@$host < 055_etcd_certs.sh
  ssh -q $(id -un)@$host < 060_etcd_init.sh
done
bash 065_local_etcd_test.sh
bash 070_local_etcd1_ca_masters.sh
mkdir -p secrets
bash 080_master_init.sh | tee secrets/join_command.txt
bash 090_local_download_kube_config