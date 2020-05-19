#!/bin/bash
test -f ~/environment.sh && source ~/environment.sh

mkdir nginx
cd nginx

tee Dockerfile <<EOF1
# https://hub.docker.com/_/nginx/
FROM nginx:1.18.0
RUN apt-get update && apt-get install -y iputils-ping && apt -y clean
WORKDIR /etc/nginx
COPY ./nginx.conf .
EOF1

tee nginx.conf <<EOF2
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
EOF2

cat /etc/hosts | egrep "kmast" | grep -v "^127\.0\." | awk '{print $2}' | while read host
do
tee -a nginx.conf <<EOF3
        server $host:6443;
EOF3
done

tee -a nginx.conf <<EOF4
    }
    upstream stream_etcd_2379 {
        hash $remote_addr consistent;
EOF4

cat /etc/hosts | egrep "ketcd" | grep -v "^127\.0\." | awk '{print $2}' | while read host
do
tee -a nginx.conf <<EOF5
        server $host:2379;
EOF5
done

tee -a nginx.conf <<EOF6
    }
    upstream stream_etcd_2380 {
        hash $remote_addr consistent;
EOF6

cat /etc/hosts | egrep "ketcd" | grep -v "^127\.0\." | awk '{print $2}' | while read host
do
tee -a nginx.conf <<EOF7
        server $host:2380;
EOF7
done

tee -a nginx.conf <<EOF8
    }
}
EOF8

cat nginx.conf

tee docker-compose.yaml <<EOF9
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
EOF9
cat /etc/hosts | egrep "k(etcd|mast|work)" | awk '{print "      - \"" $2 ":" $1 "\""}' | tee -a docker-compose.yaml
echo | tee -a docker-compose.yaml

docker-compose down
docker image rm olafrv/k8slb:latest 2>&1 >/dev/null
docker build -t olafrv/k8slb:latest .
docker-compose up -d	

sudo netstat -tlpn | grep "6443|2379|2380"

sudo tee /etc/rc.local <<EOF10
docker run k8slb
exit 0
EOF10

# docker logs k8slb
# docker exec -it k8slb /bin/bash
