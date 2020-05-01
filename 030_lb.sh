#!/bin/bash

# Only for the load balancer node for k8s kube and etcd apis

sudo apt -y install balance

sudo tee /root/balance.sh <<END
info=/tmp/balance-systemd-cat-pipe-info
mkfifo "\$info"
trap "exec 3>&-; rm \$info" EXIT
systemd-cat -p info < "\$info" &
exec 3>"\$info"

DATE=\`date '+%Y-%m-%d %H:%M:%S'\`
echo "Example service started at \${DATE}" | systemd-cat -p info

/usr/bin/balance -f 6443 -b mlb -B mlb km1 km2
END

sudo tee /etc/systemd/system/balance.service <<END
[Unit]
After=network.target
Description=Balance systemd service.

[Service]
User=root
Group=root
Type=simple
Restart=always
ExecStart=/bin/bash /root/balance.sh

[Install]
WantedBy=multi-user.target
END
sudo chmod 644 /etc/systemd/system/balance.service

sudo systemctl enable balance
sudo systemctl restart balance
sleep 3
sudo systemctl status balance
sudo netstat -ltpn