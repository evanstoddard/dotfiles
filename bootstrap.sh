#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_pacman_packages
{
    sudo pacman -S --noconfirm - < ${SCRIPT_DIR}/pacman_package_list.txt
}

function install_nvim
{
    which nvim &> /dev/null

    if [ $? == 0 ]; then
        echo "NeoVim already installed... skipping..."
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
    rm -rf ~/.config/sway ~/.config/waybar ~/.config/rofi ~/.config/swaync ~/.config/wlogout ~/.config/hypr ~/.config/nvim
    ln -sf ${SCRIPT_DIR}/.config/sway ~/.config/sway
    ln -sf ${SCRIPT_DIR}/.config/waybar ~/.config/waybar
    ln -sf ${SCRIPT_DIR}/.config/rofi ~/.config/rofi
    ln -sf ${SCRIPT_DIR}/.config/swaync ~/.config/swaync
    ln -sf ${SCRIPT_DIR}/.config/wlogout ~/.config/wlogout
    ln -sf ${SCRIPT_DIR}/.config/nvim ~/.config/nvim
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

function install_yay_packages
{
    echo "" | yay --noconfirm --useask - < ${SCRIPT_DIR}/yay_package_list.txt
}

function install_wallpapers
{
    mkdir -p ~/.local

    rm -rf ~/.local/wallpapers

    ln -sf ${SCRIPT_DIR}/.local/wallpapers ~/.local/wallpapers
}

install_pacman_packages
install_yay
install_yay_packages
install_nvim
install_oh_my_zsh
link_configs
install_wallpapers
