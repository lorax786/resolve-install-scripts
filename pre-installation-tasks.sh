#!/bin/bash

## assuming script being run as root

mkdir ~/resolve
cd ~/resolve || exit

#
# Install wget
#
yum install wget

#
# Download Resolve Install Files
#

## Download files
wget https://itdresolvedemostorage.blob.core.windows.net/resolve/template.blueprint.properties
wget https://itdresolvedemostorage.blob.core.windows.net/resolve/blueprint-rsremote.properties
wget https://itdresolvedemostorage.blob.core.windows.net/resolve/template.limits.cnf
wget https://itdresolvedemostorage.blob.core.windows.net/resolve/template.resolve.cnf
wget https://itdresolvedemostorage.blob.core.windows.net/resolve/resolve-linux64-7.5.0.4.gov.tar.gz 

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

## Reload firewall
# firewall-cmd --reload

#
# Install and Configure MariaDB
#

## Configure the YUM package repository
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.4"

## Install MariaDB Community Server and package dependencies
yum install MariaDB-server MariaDB-backup

## Configure MariaDB
## here take a template file for my.cnf and copy to /etc/my.conf
cp template.resolve.cnf /etc/my.cnf.d/resolve.cnf
cp template.limits.cnf /etc/systemd/system/mariadb.service.d/limits.cnf

## Restart and Enable MariaDB Service
systemctl restart mariadb
systemctl enable mariadb

## Create Resolve User account within MariaDB
mysql -e "grant all on resolve.* to 'resolve'@'%' identified by 'Resolve_2022';"
mysql -e "grant all on resolve.* to 'resolve'@'localhost' identified by 'Resolve_2022';"
mysql -e "flush privileges;"
mysql -e "create database resolve;"

#
# Create Resolve Service Account for Install
#

## Create Resolve service account
useradd -c "Resolve Service" -m resolve
echo "resolve:Resolve_2022" | chpasswd # originally password was resolve_2022

## Give Resolve service account permissions to where files in Resolve folder
cd ..
mkdir /opt/resolve
chown resolve /opt/resolve/
chown resolve ~/resolve/

#
# move resolve folder to tmp folder
#
mv ~/resolve/ /tmp/

#
# Log in as Resolve service account
#
su - resolve

## tar install files
cd /opt/resolve
tar -zxvf /tmp/resolve/resolve-linux64-7.5.0.0.gov.tar.gz

## TODO: do you need to do anything with blueprint.properiies? Check video at before 50:00, we had to change the 
## TODO: DB User Password in the template. Where should the template be copied?
cp -f template.blueprint.properties /opt/resolve/bin/blueprint.properties

# 
# log back into root account here
#
exit

#
# Execute script to set server limits on memory etc
#

cd /opt/resolve/bin

## TODO: Ask Jim what these default parameters stand for
./setup_limits.sh --default --default --default --default
./setup_sysctl.sh --default 
./system_services.sh all

exit
exit
exit

