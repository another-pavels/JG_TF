#!/bin/bash
set -e 
echo "sudo apt update" >> /tmp/init.web.log 
sudo apt update
uptime >> /tmp/init.web.log 

echo "sudo apt install apt-transport-https ..." >> /tmp/init.web.log
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
uptime >> /tmp/init.web.log 

echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg" >> /tmp/init.web.log
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
uptime >> /tmp/init.web.log 

echo "echo deb keyrings" >> /tmp/init.web.log 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
uptime >> /tmp/init.web.log 

echo "sudo apt update" >> /tmp/init.web.log 
sudo apt update
uptime >> /tmp/init.web.log 

echo "apt-cache policy docker-ce" >> /tmp/init.web.log 
apt-cache policy docker-ce
uptime >> /tmp/init.web.log 

echo "sudo apt install docker-ce etc." >> /tmp/init.web.log 
sudo apt install docker-ce docker-compose mysql-client-core-8.0 net-tools -y
uptime >> /tmp/init.web.log 

pwd >> /tmp/init.web.log 
id >> /tmp/init.web.log 

curl -s -o /opt/webserver-compose https://raw.githubusercontent.com/pavljiks/JG_TF/main/webserver-compose

docker-compose -f /opt/webserver-compose up -d

echo "all done" >> /tmp/init.web.log 