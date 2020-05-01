mkdir nginx
cd nginx

tee Dockerfile <<EOF
# https://hub.docker.com/_/nginx/
FROM nginx:1.18.0
RUN apt-get update && apt-get install -y iputils-ping && apt -y clean
WORKDIR /etc/nginx
COPY ./nginx.conf .
EOF

tee nginx.conf <<EOF
events {}
stream {
    server {
        listen 6443;
        proxy_pass stream_master;
        proxy_timeout 3s;
        proxy_connect_timeout 1s;
    }
    server {
        listen 2379;
        proxy_pass stream_etcd_2379;
        proxy_timeout 3s;
        proxy_connect_timeout 1s;
    }
    server {
        listen 2380;
        proxy_pass stream_etcd_2380;
        proxy_timeout 3s;
        proxy_connect_timeout 1s;
    }
    upstream stream_master {
        hash $remote_addr consistent;
        server kmast1:6443;
        server kmast2:6443;
        server kmast3:6443;
    }
    upstream stream_etcd_2379 {
        hash $remote_addr consistent;
        server ketcd1:2379;
        server ketcd1:2379;
        server ketcd1:2379;
    }
    upstream stream_etcd_2380 {
        hash $remote_addr consistent;
        server ketcd1:2380;
        server ketcd1:2380;
        server ketcd1:2380;
    }
}
EOF

tee docker-compose.yaml <<EOF
version: '2'
services:
  web:
    image: olafrv/k8slb:latest
    build:
     context: .
     dockerfile: Dockerfile
    container_name: k8slb
    restart: unless-stopped
    ports:
      - 2379:2379
      - 2380:2380
      - 6443:6443
    extra_hosts:
EOF
cat /etc/hosts | grep 192.168.10 | awk '{print "      - \"" $2 ":" $1 "\""}' | tee -a docker-compose.yaml
echo | tee -a docker-compose.yaml

docker-compose down
docker image rm olafrv/k8slb:latest 2>&1 >/dev/null
docker build -t olafrv/k8slb:latest .
docker-compose up -d	

sudo netstat -tlpn | grep "6443|2379|2380"

sudo tee /etc/rc.local <<EOF
docker run k8slb
exit 0
EOF

# docker logs k8slb
# docker exec -it k8slb /bin/bash
