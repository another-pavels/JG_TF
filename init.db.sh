#!/bin/bash
set -e 
echo "sudo apt update" >> /tmp/init.db.log
sudo apt update
uptime >> /tmp/init.db.log 

echo "sudo apt install apt-transport-https ..." >> /tmp/init.db.log
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
uptime >> /tmp/init.db.log

echo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg" >> /tmp/init.db.log
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
uptime >> /tmp/init.db.log

echo "echo deb keyrings" >> /tmp/init.db.log
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
uptime >> /tmp/init.db.log

echo "sudo apt update" >> /tmp/init.db.log
sudo apt update
uptime >> /tmp/init.db.log

echo "apt-cache policy docker-ce" >> /tmp/init.db.log
apt-cache policy docker-ce
uptime >> /tmp/init.db.log

echo "sudo apt install docker-ce -y" >> /tmp/init.db.log
sudo apt install docker-ce docker-compose mysql-client-core-8.0 net-tools -y
uptime >> /tmp/init.db.log

pwd >> /tmp/init.db.log
id >> /tmp/init.db.log

curl -s -o /opt/dbserver-compose https://raw.githubusercontent.com/pavljiks/JG_TF/main/dbserver-compose

docker-compose -f /opt/dbserver-compose up -d

echo "all done" >> /tmp/init.db.log 
