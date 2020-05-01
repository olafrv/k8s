#!/bin/bash

# https://github.com/upperstream/packer-templates/blob/master/ubuntu/ubuntu-18.04/README.mdown

# Fix: unknown configuration key: "ssh_wait_timeout"...
# https://github.com/mrlesmithjr/packer-templates/issues/59

export PACKER_VM_NAME=$1
cd packer-templates/ubuntu/ubuntu-18.04
packer build -only=vmware-iso --var-file=../../../build.json ubuntu-18.04-minimal.json
