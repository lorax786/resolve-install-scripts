#!/bin/bash

PORTS=("4004" "3306" "1521" "9300" "8080" "8443" "35197" "15672" "9330" "9200" "4369" "25672")

# Check if firewalld is installed
if ! rpm -q firewalld &> /dev/null; then
  echo "firewalld is not installed. Installing firewalld now..."
  sudo dnf install firewalld
fi

# Check if firewalld service is active
if ! systemctl is-active --quiet firewalld; then
  echo "firewalld is installed by not running. Starting it now..."
  systemctl start firewalld
fi

# Check if firewalld service is enabled at boot
if ! systemctl is-enabled firewalld &> /dev/null; then
  echo "firewalld is installed but not enabled to start at boot"
  systemctl enable firewalld
fi
echo "firewalld is avaible, enabled at boot, and running"
echo "configuring ports on the firewall"

# Add the port permanently
for PORT in "${PORTS[@]}"; do
  firewall-cmd --permanent --add-port="$PORT"/tcp
  echo "Port added to firewall: $PORT/tcp"
done

# Reload the firewall to apply changes
firewall-cmd --reload
echo "Reloaded firewall to apply changes"

# Listing added ports
firewall-cmd --list-ports

