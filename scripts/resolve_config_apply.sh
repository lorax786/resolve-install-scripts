#!/bin/bash

# Where Resolve Action Pro source code is installed
RESOLVE_INSTALL_DEST="$1"

# Current working directory
CURRENT_PWD=$(pwd)

# EXECUTE CONFIG SCRIPTS TO ENABLE RESOLVE CONFIGURATIONS
# change to bin folder to run scripts
echo "Enabling Resolve Action Pro configurations..."
cd "$RESOLVE_INSTALL_DEST/bin"

bash "./setup_limits.sh" --default --default --default --default
bash "./setup_sysctl.sh" --default
bash "./system_services.sh" all
echo "Resolve Action Pro configuration complete."

cd $CURRENT_PWD
