#!/bin/bash

# VirtualBox Installer for Debian-based Linux distributions
# Version: 1.0
# License: GPLv3

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Detect distribution and codename
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    CODENAME=$VERSION_CODENAME
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
    CODENAME=$(lsb_release -cs)
else
    echo "Unsupported Linux distribution."
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "Only 64-bit architecture is supported."
    echo "Your architecture: $ARCH"
    exit 1
fi

# Validate supported distributions
case "$DISTRO-$CODENAME" in
    debian-stretch|debian-buster|debian-bullseye|debian-bookworm|ubuntu-xenial|ubuntu-bionic|ubuntu-focal|ubuntu-jammy|ubuntu-lunar|ubuntu-mantic)
        ;;
    *)
        echo "Unsupported distribution or version: $DISTRO-$CODENAME"
        echo "Please use a recent Debian or Ubuntu LTS version."
        exit 1
        ;;
esac

# Install required dependencies
echo "Installing required dependencies..."
apt-get update
apt-get install -y wget gnupg

# Add Oracle VirtualBox repository and key
echo "Adding VirtualBox repository..."

# Create keyring directory if it doesn't exist
mkdir -p /usr/share/keyrings

# Download and register Oracle public key
echo "Downloading and registering Oracle public key..."
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor

# Add repository to sources.list
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $CODENAME contrib" > /etc/apt/sources.list.d/virtualbox.list

# Update package list and install VirtualBox
echo "Updating package list..."
apt-get update

echo "Installing VirtualBox..."
apt-get install -y virtualbox-7.1

# Check installation status
if [ $? -eq 0 ]; then
    echo "VirtualBox installed successfully."
    echo "Version info:"
    VBoxManage --version
else
    echo "Error occurred during VirtualBox installation."
    # Clean up failed installation
    echo "Cleaning up..."
    apt-get remove -y virtualbox-7.1
    apt-get autoremove -y
    rm -f /etc/apt/sources.list.d/virtualbox.list
    exit 1
fi

# Install extension pack (optional)
read -p "Do you want to install the Extension Pack? [y/N] " yn
case $yn in
    [Yy]* )
        echo "Downloading Extension Pack..."
        LATEST_VERSION=$(VBoxManage --version | cut -d'_' -f1)
        wget "https://download.virtualbox.org/virtualbox/${LATEST_VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${LATEST_VERSION}.vbox-extpack" -O /tmp/extension_pack.vbox-extpack
        
        echo "Installing Extension Pack..."
        VBoxManage extpack install /tmp/extension_pack.vbox-extpack --replace
        rm /tmp/extension_pack.vbox-extpack
        echo "Extension Pack installed successfully."
        ;;
    * )
        echo "Skipping Extension Pack installation."
        ;;
esac

echo "Installation completed successfully."
