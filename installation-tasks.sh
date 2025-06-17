#!/bin/bash
## assuming script being run as root

## change location into install file directory
su - resolve
cd /opt/resolve || exit

#
# Install Resolve using blueprint property file
#
./install-resolve.sh blueprint.properties