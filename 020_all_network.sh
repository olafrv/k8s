#!/bin/bash

# On each linux node to define local hostsname resolution
# ssh 192.168.10.128 'bash -s hostname' < hosts.sh

if [ -z "$1" ]
then
    echo "Missing hostname!"
    exit 1
fi

# https://askubuntu.com/questions/1132933/unable-to-change-hostname-in-ubuntu-18-04-server-on-virtualbox
sudo hostnamectl set-hostname $1

# https://communities.vmware.com/thread/600978
# https://superuser.com/questions/1338510/wrong-ip-address-from-dhcp-client-on-ubuntu-18-04
# http://manpages.ubuntu.com/manpages/xenial/man1/systemd-machine-id-setup.1.html
sudo cat /sys/class/dmi/id/product_uuid
sudo tee > /etc/machine-id 
sudo systemd-machine-id-setup

IP=$(hostname -i)
sudo tee /etc/netplan/50-cloud-init.yaml << END
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens33:
            dhcp4: false
            addresses: [ $IP/24 ]
            gateway4: 192.168.10.2
            nameservers:
              addresses: [ 8.8.8.8 ]
    version: 2
END

sudo netplan apply
# sudo reboot
sudo poweroff
