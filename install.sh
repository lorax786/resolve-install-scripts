#!/bin/bash

# Current root directory for scripts
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default credentials for Resolve MariaDB and Service Account
RESOLVE_USER=$(grep 'RESOLVE_USER=' .config | cut -d '=' -f2- | tr -d '"')
RESOLVE_PASS=$(grep 'RESOLVE_PASS=' .config | cut -d '=' -f2- | tr -d '"')

if [[ "$RESOLVE_USER" == "" ]]; then
  RESOLVE_USER="resolve"
fi

if [[ "$RESOLVE_PASS" == "" ]]; then
  RESOLVE_PASS="Resolve_2025"
fi

# ROOT USER
# Check if the script is run as root
if [[ "$EUID" -ne 0 ]]; then
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
GZ_FILE=$(find dist -maxdepth 1 -type f -name "*.gov.tar.gz" | head -n 1)

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
    echo "Downloading Files CLI App..."
    ARCH=$(rpm -q --qf '%{ARCH}' rpm)
    curl -L "https://github.com/Files-com/files-cli/releases/latest/download/files-cli_linux_$ARCH.deb" -o files-cli.deb

    echo "Download complete.Installing Files CLI APP..."
    dnf install ./files-cli.deb
    FILES_CLI_APP=$(files-cli --version)
    rm -rf ./files-cli.deb

    echo "Install complete. Files CLI App version: $FILES_CLI_APP"
    echo "Configuring Files CLI App..."
    FILES_API_KEY=$(grep 'FILES_API_KEY=' .config | cut -d '=' -f2- | tr -d '"')
    FILES_SUBDOMAIN=$(grep 'FILES_SUBDOMAIN=' .config | cut -d '=' -f2- | tr -d '"')
    files-cli config set --api-key $FILES_API_KEY $FILES_SUBDOMAIN
    echo "Configuration complete."

    echo "Downloading Resolve source code files..."
    RESOLVE_VERSION=$(grep 'RESOLVE_VERSION=' .config| cut -d '=' -f2- | tr -d '"')
    RESOLVE_CONVERTED_VERSION="${RESOLVE_VERSION//./_}"
    files-cli download "https://resolvesys.files.com/files/SE/Prospects/IntelliDyne/Software/$RESOLVE_CONVERTED_VERSION" "$CURRENT_DIR/dist"
    echo "Download files complete."
  fi
fi


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

# SET & CONFIGURE PERMISSIONS FOR INSTALLATION FOLDER
# Get Installation file directory
INSTALL_DIR="/opt"
read -rp "Enter the absolute path to the installation folder: " INSTALL_DIR

# Resolve to an absolute path
INSTALL_DIR="$(realpath "$INSTALL_DIR" 2>/dev/null)"

# Validate the path
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Error: '$INSTALL_DIR' is not a valid directory."
  exit 1
fi

# Give service account permissions to where resolve install files will be
RESOLVE_INSTALL_DEST="$INSTALL_DIR/resolve"
mkdir "$RESOLVE_INSTALL_DEST"
chown resolve "$RESOLVE_INSTALL_DEST"

RESOLVE_SOURCECODE_FILE=$(ls "$CURRENT_DIR/dist" | head -n 1)
RESOLVE_CONFIG_FILE="resolve-linux64-$RESOLVE_VERSION.gov.tar.gz"

# INSTALL RESOLVE ACTION PRO
"$CURRENT_DIR/scripts/resolve.sh" "$RESOLVE_USER" "$CURRENT_DIR/dist/$RESOLVE_SOURCECODE_FILE" "$CURRENT_DIR/configs/$RESOLVE_CONFIG_FILE" "$RESOLVE_INSTALL_DEST"

