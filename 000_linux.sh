#!/bin/bash

# For each linux nodes or the one used as base image

#################################################################
# Ensure you can ssh into every node from your admin desktop!!! #
# ssh-copy-id ubuntu@<node>                                     #
#################################################################

# Unique hostname for kubernetes
echo hostname?
read hostname

# Run sudo without password (k8s)
sudo tee -a /etc/sudoers.d/k8s <<EOF
ubuntu  ALL=(ALL:ALL) NOPASSWD:ALL
EOF

# https://askubuntu.com/questions/1132933/unable-to-change-hostname-in-ubuntu-18-04-server-on-virtualbox
sudo hostnamectl set-hostname $hostname

# https://communities.vmware.com/thread/600978
# https://superuser.com/questions/1338510/wrong-ip-address-from-dhcp-client-on-ubuntu-18-04
# http://manpages.ubuntu.com/manpages/xenial/man1/systemd-machine-id-setup.1.html
sudo cat /sys/class/dmi/id/product_uuid
sudo tee > /etc/machine-id 
sudo systemd-machine-id-setup

sudo reboot
