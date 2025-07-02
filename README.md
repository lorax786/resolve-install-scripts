# Resolve Stand-Alone Install Script

## Introduction

This repository contains Bash scripts that automate the deployment of Resolve Action Pro. The main script, `install.sh`, checks for dependencies, configures the system and optionally downloads the Resolve distribution so that a stand-alone instance can be installed with minimal manual steps.

## Getting Started

1. Clone this repository and switch to its directory.
2. Run the script as the **root** user. The installer verifies this and exits if it is not executed with elevated privileges.
3. To allow the script to download Resolve packages, create an optional `.install_config` file in the project root with:

   ```
   FILES_API_KEY=<Files.com API key>
   FILES_SUBDOMAIN=<Files.com subdomain>
   RESOLVE_VERSION=<Resolve version>
   ```

4. Start the installation:

   ```bash
   bash install.sh
   ```

   The script installs required packages such as `curl`, sets up firewall rules, prompts to create a Resolve service user, and can install MariaDB using configuration files from the `configs` directory. You will be asked to provide the destination directory where Resolve should be extracted.

5. After completion the Resolve application files reside in the chosen directory under `resolve/`.

## Contribute

Contributions and suggestions are welcome. Feel free to open issues for bugs or improvements, or submit a pull request to add features or enhance the documentation.
