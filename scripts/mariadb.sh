#!/bin/bash

# Absolute path to config folder in script directory
CONFIG_PATH="$1"

# user account and password for MariaDB resolve user
RESOLVE_USER="$2"
RESOLVE_PASS="$3"

# version of MariaDB to install
MARIADB_VERSION=10.4

# INSTALL and CONFIGURE MARIADB

# Download and run the MariaDB repository setup script
echo "Downloading MariaDB Server version $MARIADB_VERSION"
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="$MARIADB_VERSION"
echo "Installing MariaDB Community server and package dependencies"
sudo dnf install MariaDB-server MariaDB-backup

# Configure MariaDB via custom config files for resolve
echo "Configure MariaDB to work with Resolve Action Pro"
cp "$CONFIG_PATH/template.resolve.cnf" /etc/my.cnf.d/resolve.cnf
cp "$CONFIG_PATH/template.limits.cnf" /etc/systemd/system/mariadb.service.d/limits.cnf

# Restart and enable MariaDB service
echo "Restart MariaDB to apply changes and enable MariaDB to start on reboot"
systemctl restart mariadb
systemctl enable mariadb

## Create Resolve User account within MariaDB
echo "Creating Resolve user account within MariaDB"
mysql -e "grant all on resolve.* to '$RESOLVE_USER'@'%' identified by '$RESOLVE_PASS';"
mysql -e "grant all on resolve.* to '$RESOLVE_USER'@'localhost' identified by '$RESOLVE_PASS';"
mysql -e "flush privileges;"
mysql -e "create database resolve;"
