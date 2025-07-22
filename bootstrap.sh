#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_pacman_packages
{
    sudo pacman -S --noconfirm - < ${SCRIPT_DIR}/pacman_package_list.txt
}

# Link kitty config
function link_kitty_config
{
    rm -rf ~/.config/kitty &> /dev/null
    
    ln -sf ${SCRIPT_DIR}/.config/kitty ~/.config/kitty
}

# Link bash aliases
function link_bash_aliases
{
    rm -rf ~/.bash_aliases
    ln -sf ${SCRIPT_DIR}/.bash_aliases ~/.bash_aliases

    touch ~/.bashrc

    cat ~/.bashrc | grep "source ~/.bash_aliases" &> /dev/null

    if [ $? != 0 ]; then
        echo "source ~/.bash_aliases" >> ~/.bashrc
    fi;
}

function install_nvim
{
    which nvim &> /dev/null

    if [ $? == 0 ]; then
        return
    fi

    rm -rf /tmp/nvim
    git clone https://github.com/neovim/neovim.git /tmp/nvim
    cd /tmp/nvim
    make -j$(nproc) CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
}

function install_oh_my_zsh
{
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function link_configs 
{
    rm -rf ~/.config/sway ~/.config/waybar ~/.config/wofi ~/.config/swaync ~/.config/wlogout ~/.config/hypr ~/.config/nvim
    ln -sf ${SCRIPT_DIR}/.config/sway ~/.config/sway
    ln -sf ${SCRIPT_DIR}/.config/waybar ~/.config/waybar
    ln -sf ${SCRIPT_DIR}/.config/rofi ~/.config/rofi
    ln -sf ${SCRIPT_DIR}/.config/swaync ~/.config/swaync
    ln -sf ${SCRIPT_DIR}/.config/wlogout ~/.config/wlogout
}

function install_yay
{
    which yay &> /dev/null

    if [ $? == 0 ]; then
        return
    fi

    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay
    makepkg -s -i --noconfirm 
    popd
}

function install_wlogout
{
    echo "1" | yay --noconfirm --useask wlogout
}

function install_wallpapers
{
    mkdir -p ~/.local

    rm -rf ~/.local/wallpapers

    ln -sf ${SCRIPT_DIR}/.local/wallpapers
}

link_bash_aliases
install_pacman_packages
install_yay
install_wlogout
install_nvim
install_oh_my_zsh
link_configs
link_kitty_config
install_wallpapers
