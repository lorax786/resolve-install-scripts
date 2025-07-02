#!/bin/bash

# Resolve service account
RESOLVE_USER="$1"
# Source code file location
RESOLVE_SOURCECODE_FILEPATH = "$2"
RESOLVE_CONFIG_FILEPATH = "$3"
# Resolve install destination
RESOLVE_INSTALL_DEST = "$4"

# Current working directory
CURRENT_PWD=$(pwd)

# LOGIN AS RESOLVE SERVICE ACCOUNT 
su - $RESOLVE_USER

# TAR INSTALL FILES
tar -zxvf "$RESOLVE_SOURCECODE_FILEPATH" -C "$RESOLVE_INSTALL_DEST"

# SET RESOLVE CONFIGURATION
cp -f "$RESOLVE_CONFIG_FILEPATH" "$RESOLVE_INSTALL_DEST/blueprint.properties"

# LOGOUT OF RESOLVE SERVICE ACCOUNT
exit

# EXECUTE CONFIG SCRIPTS TO ENABLE RESOLVE CONFIGURATIONS
# change to bin folder to run scripts
cd "$RESOLVE_INSTALL_DEST/bin"

"./setup_limits.sh" --default --default --default --default
"./setup_sysctl.sh" --default
"./system_services.sh" all

cd $CURRENT_PWD
