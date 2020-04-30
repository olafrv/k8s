#!/bin/bash

# Run sudo without password (k8s)
sudo tee -a /etc/sudoers.d/k8s <<EOF
ubuntu  ALL=(ALL:ALL) NOPASSWD:ALL
EOF

# https://communities.vmware.com/thread/600978
# https://superuser.com/questions/1338510/wrong-ip-address-from-dhcp-client-on-ubuntu-18-04
# http://manpages.ubuntu.com/manpages/xenial/man1/systemd-machine-id-setup.1.html
sudo cat /sys/class/dmi/id/product_uuid
sudo tee > /etc/machine-id 
sudo systemd-machine-id-setup

# Unique hostname for kubernetes
echo hostname?
read hostname
sudo hostnamectl set-hostname $hostname

sudo reboot