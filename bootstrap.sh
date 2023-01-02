#!/bin/bash

# Install apt packages
function install_apt_packages()
{
    echo "Installing apt packages..."

    # Load packages into array
    APT_PACKAGES=$(<apt_packages.txt)

    # Install packages
    sudo apt install -y ${APT_PACKAGES}
}

# Install apt packages downloaded
function install_external_apt_packages()
{
    echo "Installing external apt packages..."

    # Clear out previous downloads
    rm -rf /tmp/ext_apt_packages

    # Download packages
    wget --content-disposition -i external_apt_packages.txt -P /tmp/ext_apt_packages

    # Install packages
    sudo apt install -y /tmp/ext_apt_packages/*
}

# Copy config folder
function copy_config_folder
{
    echo "Copying configs folder..."
    cp -r .config ~/
}

# Copy Hyper config
function copy_hyper_config
{
    echo "Copying hyper config..."
    cp .hyper.js ~/
}

# Copy bash aliases
function copy_bash_aliases
{
    echo "Copy bash aliases"
    cp .bash_aliases ~/
}

function i3chmod
{
    echo "Setting i3 permissions"

    chmod +x ~/.config/i3/scripts/*
}

install_apt_packages
install_external_apt_packages
copy_config_folder
copy_hyper_config
copy_bash_aliases