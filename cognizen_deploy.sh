#!/bin/bash


apt-get update
apt-get -y install apt-transport-https ca-certificates curl software-properties-common unzip

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -y update
apt-get -y install docker-ce

curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir cognizen
cd cognizen
unzip ../cognizen.zip
docker build -t cognizen .

docker-compose up -d

#Currently fails because:
# 1. Need "RUN chmod +x /usr/src/app/server/run.sh" line
# 2. cognizen container just exits. 
# docker-compose -f docker-compose.yml -f docker-compose-cognizen.yml up -d cognizen mongo