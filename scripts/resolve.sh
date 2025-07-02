#!/bin/bash

# Resolve service account
RESOLVE_USER="$1"
# Install file location
RESOLVE_INSTALL_FOLDER_PATH = "$2"
RESOLVE_INSTALL_FILE = "$3"
RESOLVE_CONFIG_FILE = "$4"
# Resolve install destination
RESOLVE_INSTALL_DEST = "$5"

# LOGIN AS RESOLVE SERVICE ACCOUNT 
su - $RESOLVE_USER

# TAR INSTALL FILES
tar -zxvf "$RESOLVE_INSTALL_FOLDER_PATH/$RESOLVE_INSTALL_FILE" -C "$RESOLVE_INSTALL_DEST"

# SET RESOLVE CONFIGURATION
cp -f "$RESOLVE_INSTALL_FOLDER_PATH/$RESOLVE_CONFIG_FILE" "$RESOLVE_INSTALL_DEST/blueprint.properties"

# LOGOUT OF RESOLVE SERVICE ACCOUNT
exit

# EXECUTE CONFIG SCRIPTS TO ENABLE RESOLVE CONFIGURATIONS
# change to bin folder to run scripts
cd "$RESOLVE_INSTALL_DEST/bin"

"./setup_limits.sh" --default --default --default --default
"./setup_sysctl.sh" --default
"./system_services.sh" all
