# Define the common hosts file for all nodes

SUBNET="192.168.10"

sudo tee /etc/hosts << END
127.0.0.1       localhost
127.0.1.1       ubuntu

${SUBNET}.10 kload1
${SUBNET}.11 ketcd1
${SUBNET}.12 ketcd2
${SUBNET}.13 ketcd3
${SUBNET}.14 kmast1
${SUBNET}.15 kmast2
${SUBNET}.16 kmast3
${SUBNET}.17 kwork1
${SUBNET}.18 kwork2
${SUBNET}.19 kwork3

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
END