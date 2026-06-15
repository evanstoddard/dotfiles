#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ARCH=$(uname -m)

function install_apt_packages
{
    sudo apt-get update

    local packages
    packages=$(grep -v '^#' "${SCRIPT_DIR}/apt_package_list.txt" | tr '\n' ' ')
    # shellcheck disable=SC2086
    sudo apt-get install -y $packages
}

function install_nodejs
{
    which node &>/dev/null && { echo "Node.js already installed... skipping..."; return; }

    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

function install_nvim
{
    which nvim &>/dev/null && { echo "NeoVim already installed... skipping..."; return; }

    local version
    version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)

    local archive="nvim-linux-x86_64.tar.gz"
    [ "$ARCH" = "aarch64" ] && archive="nvim-linux-arm64.tar.gz"

    curl -fsSL "https://github.com/neovim/neovim/releases/download/${version}/${archive}" \
        -o /tmp/nvim.tar.gz
    sudo tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1
    rm /tmp/nvim.tar.gz
}

function install_zellij
{
    which zellij &>/dev/null && { echo "Zellij already installed... skipping..."; return; }

    local version
    version=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)

    local archive="zellij-x86_64-unknown-linux-musl.tar.gz"
    [ "$ARCH" = "aarch64" ] && archive="zellij-aarch64-unknown-linux-musl.tar.gz"

    curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${version}/${archive}" \
        | sudo tar -xz -C /usr/local/bin
}

function install_glow
{
    which glow &>/dev/null && { echo "glow already installed... skipping..."; return; }

    curl -fsSL https://repo.charm.sh/apt/gpg.key \
        | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/charm.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/charm.gpg] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y glow
}

function install_ghostty
{
    which ghostty &>/dev/null && { echo "Ghostty already installed... skipping..."; return; }

    local ubuntu_ver
    ubuntu_ver=$(. /etc/os-release && echo "$VERSION_ID")

    if [[ ! "$ubuntu_ver" =~ ^(24\.04|25\.10|26\.04)$ ]]; then
        echo "Ghostty prebuilts require Ubuntu 24.04+."
        echo "  On Ubuntu ${ubuntu_ver}, use Kitty instead (~/.config/kitty)."
        return
    fi

    local tag
    tag=$(curl -s https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)

    # Convert tag (e.g. "1.3.1-0-ppa2") to deb version ("1.3.1-0.ppa2")
    local deb_ver="${tag%-*}.${tag##*-}"

    local arch="amd64"
    [ "$ARCH" = "aarch64" ] && arch="arm64"

    curl -fsSL \
        "https://github.com/mkasberg/ghostty-ubuntu/releases/download/${tag}/ghostty_${deb_ver}_${arch}_${ubuntu_ver}.deb" \
        -o /tmp/ghostty.deb
    sudo apt-get install -y /tmp/ghostty.deb
    rm /tmp/ghostty.deb
}

function install_bluetui
{
    which bluetui &>/dev/null && { echo "bluetui already installed... skipping..."; return; }

    local version
    version=$(curl -s https://api.github.com/repos/pythops/bluetui/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)

    local binary="bluetui-x86_64-linux-musl"
    [ "$ARCH" = "aarch64" ] && binary="bluetui-aarch64-linux-musl"

    curl -fsSL "https://github.com/pythops/bluetui/releases/download/${version}/${binary}" \
        -o /tmp/bluetui
    sudo install -m 755 /tmp/bluetui /usr/local/bin/bluetui
    rm -f /tmp/bluetui
}

function install_nerd_fonts
{
    if fc-list | grep -qi "Iosevka Nerd"; then
        echo "Iosevka Nerd Font already installed... skipping..."
        return
    fi

    local version
    version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)

    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/Iosevka.zip" \
        -o /tmp/iosevka-nerd.zip
    sudo mkdir -p /usr/local/share/fonts/nerd-fonts/Iosevka
    sudo unzip -o /tmp/iosevka-nerd.zip -d /usr/local/share/fonts/nerd-fonts/Iosevka '*.ttf'
    rm /tmp/iosevka-nerd.zip
    sudo fc-cache -fv
}

function install_phosphor_icons
{
    if fc-list | grep -qi "Phosphor"; then
        echo "Phosphor Icons already installed... skipping..."
        return
    fi

    local version
    version=$(curl -s https://api.github.com/repos/phosphor-icons/homepage/releases \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4)

    curl -fsSL \
        "https://github.com/phosphor-icons/homepage/releases/download/${version}/phosphor-icons.zip" \
        -o /tmp/phosphor-icons.zip
    sudo mkdir -p /usr/local/share/fonts/phosphor
    sudo unzip -o /tmp/phosphor-icons.zip 'Fonts/**/*.ttf' -d /usr/local/share/fonts/phosphor
    rm /tmp/phosphor-icons.zip
    sudo fc-cache -fv
}

function install_oh_my_zsh
{
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh already installed... skipping..."
        return
    fi

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

function link_configs
{
    for dir in ${SCRIPT_DIR}/.config/*/; do
        name=$(basename "$dir")
        rm -f ~/.config/${name}
        ln -sf "${dir%/}" ~/.config/${name}
    done
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

function setup_flatpak
{
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub app.zen_browser.zen
}


install_apt_packages
install_nodejs
install_zellij
install_glow
install_ghostty
install_bluetui
install_nerd_fonts
install_phosphor_icons
install_nvim
install_oh_my_zsh
link_configs
install_wallpapers
setup_zsh_extras
setup_flatpak
