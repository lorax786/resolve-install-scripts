#!/bin/bash

# Pre-Installation Tasks

## apply updates to all installed packages
yum update -y && \
yum upgrade -y

#
# Configure Ports
#

## Add ports to firewall
firewall-cmd --zone=public --permanent --add-port=4004/tcp
firewall-cmd --zone=public --permanent --add-port=3306/tcp
firewall-cmd --zone=public --permanent --add-port=1521/tcp
firewall-cmd --zone=public --permanent --add-port=9300/tcp
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --zone=public --permanent --add-port=8443/tcp
firewall-cmd --zone=public --permanent --add-port=35197/tcp
firewall-cmd --zone=public --permanent --add-port=15672/tcp
firewall-cmd --zone=public --permanent --add-port=9330/tcp
firewall-cmd --zone=public --permanent --add-port=9200/tcp
firewall-cmd --zone=public --permanent --add-port=4369/tcp
firewall-cmd --zone=public --permanent --add-port=25672/tcp

## Creating a Linux User for Actions Pro 

groupadd resolve
useradd -c "Resolve Service" -g resolve resolve
#passwd resolve
echo "resolve:Resolve_2023" | chpasswd

### Assume you are in azureuser home folder '~/'
### Create 'resolve' where we will download resolve source code
mkdir resolve
cd ./resolve

### download source code and the property files
curl -X GET -o resolve-linux64-7.5.0.8.gov.tar.gz "https://devresolvestoarge.blob.core.windows.net/install-packages/resolve-linux64-7.5.0.8.gov.tar.gz"
cd ..

### change ownership to "Resolve Service" account
chown -R resolve:resolve ./resolve
mv ./resolve /tmp/

### create and change ownership of /opt/resolve directory
mkdir /opt/resolve
chown resolve /opt/resolve

### log in as "Resolve Service" account
su - resolve

### download bluprint.properties property file
curl -X GET -o blueprint.properties "https://devresolvestoarge.blob.core.windows.net/install-packages/blueprint.properties" 

## extract the tar files
cd /opt/resolve
tar -zxvf /tmp/resolve/resolve-linux64-7.5.0.8.gov.tar.gz

exit

cd /opt/resolve/bin

./setup_limits.sh --default --default --default --default
./setup_sysctl.sh --default 
./setup_services.sh all

su - resolve
cd /opt/resolve

./install-resolve.sh /home/resolve/blueprint.properties