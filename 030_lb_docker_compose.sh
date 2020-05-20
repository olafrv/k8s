#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

# This is needed to run nginx TCP in the load balancer servers

# https://docs.docker.com/compose/install/
sudo curl -s -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
