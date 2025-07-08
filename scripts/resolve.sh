#!/bin/bash

# Resolve service account
RESOLVE_USER="$1"
# Source code file location
RESOLVE_SOURCECODE_FILEPATH="$2"
RESOLVE_CONFIG_FILEPATH="$3"
# Resolve install destination
RESOLVE_INSTALL_DEST="$4"

# Current working directory
CURRENT_PWD=$(pwd)

# LOGIN AS RESOLVE SERVICE ACCOUNT 
echo "Logging into Resolve Service account..."
su - $RESOLVE_USER

# TAR INSTALL FILES
echo "Deploying Resolve Action Pro installation files to $RESOLVE_SOURCECODE_FILEPATH..."
tar -zxvf "$RESOLVE_SOURCECODE_FILEPATH" -C "$RESOLVE_INSTALL_DEST"
echo "Deploying Resolve Action Pro installation files complete."

# SET RESOLVE CONFIGURATION
echo "Deploying Resolve Action Pro configuration (blueprint.properties)..."
cp -f "$RESOLVE_CONFIG_FILEPATH" "$RESOLVE_INSTALL_DEST/blueprint.properties"
echo "Deploying Resolve Action Pro configuration complete."

# LOGOUT OF RESOLVE SERVICE ACCOUNT
exit
echo "Logging out of Resolve Service Account."

# EXECUTE CONFIG SCRIPTS TO ENABLE RESOLVE CONFIGURATIONS
# change to bin folder to run scripts
echo "Enabling Resolve Action Pro configurations..."
cd "$RESOLVE_INSTALL_DEST/bin"

bash "./setup_limits.sh" --default --default --default --default
bash "./setup_sysctl.sh" --default
bash "./system_services.sh" all
echo "Resolve ACtio Pro configuration complete."

cd $CURRENT_PWD
