#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# Install apt packages
function install_apt_packages()
{
    echo "Installing apt packages..."
    
    sudo apt update
    sudo apt install nala -y
    sudo nala update
    
    # Load packages into array
    APT_PACKAGES=$(<apt_packages.txt)

    # Install packages
    sudo nala install -y ${APT_PACKAGES}
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
    sudo nala install -y /tmp/ext_apt_packages/*
}

# Link i3 config
function link_i3_config
{
    rm -rf ~/.config/i3 &> /dev/null
    rm -rf ~/.config/dunst &> /dev/null
    rm -rf ~/.config/rofi &> /dev/null

    ln -sf ${SCRIPT_DIR}/.config/i3 ~/.config/i3
    ln -sf ${SCRIPT_DIR}/.config/dunst ~/.config/dunst
    ln -sf ${SCRIPT_DIR}/.config/rofi ~/.config/rofi
}

# Link kitty config
function link_kitty_config
{
    rm -rf ~/.config/kitty &> /dev/null
    
    ln -sf ${SCRIPT_DIR}/.config/kitty ~/.config/kitty
}

# Link nvim config
function link_nvim_config
{
    rm -rf ~/.config/nvim/lua/custom

    ln -sf ${SCRIPT_DIR}/.config/nvim/custom ~/.config/nvim/lua/custom
}

# Link bash aliases
function link_bash_aliases
{
    rm ~/.bash_aliases
    ln -sf ${SCRIPT_DIR}/.bash_aliases ~/.bash_aliases
}

function i3chmod
{
    echo "Setting i3 permissions"

    chmod +x ~/.config/i3/scripts/*
}

function install_nvim
{
    git clone https://github.com/neovim/neovim.git /tmp/nvim
    cd /tmp/nvim
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
}

function install_nvchad
{
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
}

function install_starship
{
    curl -sS https://starship.rs/install.sh | sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
}

function add_user_to_groups
{
    sudo usermod -a -G video $(whoami)
    sudo usermod -a -G dialout $(whoami)
}

install_apt_packages
install_external_apt_packages
install_nvim
install_nvchad
install_starship
link_i3_config
link_kitty_config
link_nvim_config
link_bash_aliases
add_user_to_groups