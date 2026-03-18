#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_pacman_packages
{
    local packages=$(comm -23 \
        <(sort ${SCRIPT_DIR}/pacman_package_list.txt) \
        <(pacman -Qq | sort))

    if [ -z "$packages" ]; then
        echo "All pacman packages already installed... skipping..."
        return
    fi

    echo "$packages" | sudo pacman -S --noconfirm -
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
    for dir in ${SCRIPT_DIR}/.config/*/; do
        name=$(basename "$dir")
        rm -rf ~/.config/${name}
        ln -sf ${dir%/} ~/.config/${name}
    done
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
    local packages=$(comm -23 \
        <(sort ${SCRIPT_DIR}/yay_package_list.txt) \
        <(yay -Qq | sort))

    if [ -z "$packages" ]; then
        echo "All yay packages already installed... skipping..."
        return
    fi

    echo "" | yay --noconfirm --useask - <<< "$packages"
}

function install_wallpapers
{
    mkdir -p ~/.local

    rm -rf ~/.local/wallpapers

    ln -sf ${SCRIPT_DIR}/.local/wallpapers ~/.local/wallpapers
}

function setup_zsh_extras
{
    local extras_file="${SCRIPT_DIR}/.zshrc_extras"
    local source_line="source ~/.zshrc_extras"

    ln -sf "$extras_file" ~/.zshrc_extras

    if ! grep -qF "$source_line" ~/.zshrc; then
        echo $'\nsource ~/.zshrc_extras' >> ~/.zshrc    
    fi
}

install_pacman_packages
install_yay
install_yay_packages
install_nvim
install_oh_my_zsh
link_configs
install_wallpapers
setup_zsh_extras
