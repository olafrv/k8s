# Define the common hosts file for all nodes

sudo tee /etc/hosts << END
127.0.0.1       localhost
127.0.1.1       ubuntu

192.168.10.10 kload1
192.168.10.11 ketcd1
192.168.10.12 ketcd2
192.168.10.13 ketcd3
192.168.10.14 kmast1
192.168.10.15 kmast2
192.168.10.16 kmast3
192.168.10.17 kwork1
192.168.10.18 kwork2
192.168.10.19 kwork3

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
END