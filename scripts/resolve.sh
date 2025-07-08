#!/bin/bash

# Source code file location
RESOLVE_SOURCECODE_FILEPATH="$1"
RESOLVE_CONFIG_FILEPATH="$2"
# Resolve install destination
RESOLVE_INSTALL_DEST="$3"

# TAR INSTALL FILES
echo "Deploying Resolve Action Pro installation files to $RESOLVE_SOURCECODE_FILEPATH..."
tar -zxvf "$RESOLVE_SOURCECODE_FILEPATH" -C "$RESOLVE_INSTALL_DEST"
echo "Deploying Resolve Action Pro installation files complete."

# SET RESOLVE CONFIGURATION
echo "Deploying Resolve Action Pro configuration (blueprint.properties)..."
cp -f "$RESOLVE_CONFIG_FILEPATH" "$RESOLVE_INSTALL_DEST/blueprint.properties"
echo "Deploying Resolve Action Pro configuration complete."
