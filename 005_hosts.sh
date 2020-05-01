#!/bin/bash

# For each linux server to define local hostsname resolution

HOSTNAME=$(hostname -f)
IP=$(hostname -i)

sudo tee /etc/hosts << END
127.0.0.1       localhost
127.0.1.1       ubuntu

192.168.10.200 gw

192.168.10.110 kload1

192.168.10.120 ketcd1
192.168.10.121 ketcd2
192.168.10.122 ketcd3

192.168.10.130 kmast1
192.168.10.131 kmast2
192.168.10.132 kmast3

192.168.10.140 kwork1
192.168.10.141 kwork2
192.168.10.142 kwork3

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
END

sudo tee /etc/hosts << END
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens33:
            dhcp4: false
            addresses: [ $IP ]
            gateway4: 192.168.10.200
            nameservers:
              addresses: [ 8.8.8.8 ]
    version: 2
END

sudo netplan apply
