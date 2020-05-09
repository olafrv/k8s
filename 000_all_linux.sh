#!/bin/bash

# This script should be run with copy and paste!
exit 0

# For each linux nodes or the one used as base image

# Ensure you can ssh into every node from your admin desktop!
ssh-copy-id ubuntu@server

# Ensure other scripts are be able to run sudo without password!
# After SSH into ubuntu@server run the following command:
sudo tee -a /etc/sudoers.d/k8s <EOF
ubuntu  ALL=(ALL:ALL) NOPASSWD:ALL
EOF

