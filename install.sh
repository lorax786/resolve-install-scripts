#!/bin/bash

# Current root directory for scripts
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default credentials for Resolve MariaDB and Service Account
RESOLVE_USER="resolve"
RESOLVE_PASS="Resolve_2025"

# ROOT USER
# Check if the script is run as root
if [["$EUID" -ne 0]]; then
  echo "This script must be run as root. Please switch to the root user."
  exit 1
fi

# DEPENDENCY PACKAGES
PACKAGES=("curl")
for PACKAGE in "${PACKAGES[@]}"; do
  if ! rpm -q ${PACKAGE} &> /dev/null; then
    echo "$PACKAGE is not installed. Installing $PACKAGE now..."
    sudo dnf install -y "$PACKAGE"
  fi
done

# DOWNLOAD RESOLVE ACTION PRO DISTRIBUTION FOR INSTALL
# Ensure dist folder exists
mkdir -p dist

# Check if a gov.tar.gz file exists
GZ_FILES=$(find dist -maxdepth 1 -type f -name "*.gov.tar.gz" | head -n 1)

if [[ -f "$GZ_FILE" ]]; then
  echo "Found existing Resolve Action Pro Gov Edition installation file" 
else
  while true;do
  read -rp "Do you want to download the latest installation file: " ANSWER
  ANSWER="${ANSWER,,}" # Lowercase

    if [[ "$ANSWER" == "y" || "$ANSWER" == "yes" ]]; then
      DOWNLOAD_FILE=true
      break
    elif [[ "$ANSWER" == "n" || "$ANSWER" == "no" ]]; then
      DOWNLOAD_FILE=false
      break
    else
      echo "Invalid input. Please enter 'y' or 'n'."
    fi
  done

if [[ "$DOWNLOAD_FILE" == true ]]; then
  # TODO: setup REST API call to get latest file from files.com
else


# USER ACCOUNT CREATION FOR MARIADB AND SERVICE ACCOUNT
# Prompt user for changes
while true;do
read -rp "Do you want to default user '$RESOLVE_USER' with default password? (y/n): " ANSWER
ANSWER="${ANSWER,,}" # Lowercase

  if [[ "$ANSWER" == "y" || "$ANSWER" == "yes" ]]; then
    CREATE_USER=true
    break
  elif [[ "$ANSWER" == "n" || "$ANSWER" == "no" ]]; then
    CREATE_USER=false
    break
  else
    echo "Invalid input. Please enter 'y' or 'n'."
  fi
done

# Confirm what's being created
if [[ "$CREATE_USER" == true ]]; then
  read -rp "Entered desired username: " RESOLVE_USER
  read -rsp "Enter desired password for '$RESOLVE_USER': " RESOLVE_PASS
  echo
  echo "Creating user: $RESOLVE_USER"
else
  echo "User creation skipped. Using default user account and password settings."
fi

# INSTALLATION FILE DIRECTORY
# Get Installation file directory
read -rp "Enter the absolute path to the installation folder: " INSTALL_DIR

# Resolve to an absolute path
$INSTALL_DIR="$(realpath "$INSTALL_DIR" 2>/dev/null)"

# Validate the path
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Error: '$INSTALL_DIR' is not a valid directory."
  exit 1
fi

echo "Installation directory: $INSTALL_DIR"

# FIREWALL INSTALLATION & CONFIGURATION
# Configure firewall settings
echo "Prior to installing Resolve Action Pro, we will add ports to the firewall. First, I will check if firewalld is installed..."
"$CURRENT_DIR/scripts/firewall.sh"

# MARIADB INSTALLATION & CONFIGURATION
# Ask the user if they want to install MariaDB
read -rp "Do you want to install MariaDB on this server? (y/n): " INSTALL_MARIADB

INSTALL_MARIADB="${INSTALL_MARIADB,,}" #Convert to lowercase

if [[ "$INSTALL_MARIADB" == "y" || "$INSTALL_MARIADB" == "yes" ]]; then 
  echo "MariaDB will be installed."
  INSTALL_MARIADB=true
else
  echo "MariaDB installation skipped."
  INSTALL_MARIADB=false
fi

if [[ "$INSTALL_MARIADB" == true ]]; then
  "$CURRENT_DIR/scripts/mariadb.sh" "$CURRENT_DIR/configs" "$RESOLVE_USER" "$RESOLVE_PASS"
fi

# RESOLVE SERVICE ACCOUNT CREATION
"$CURRENT_DIR/scripts/service.sh" "$RESOLVE_USER" "$RESOLVE_PASS"

# Give service account permissions to where resolve install files will be
mkdir /opt/resolve
chown resolve /opt/resolve/





