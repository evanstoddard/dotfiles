#!/bin/bash
# Validates bootstrap steps in CI / Docker.

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ARCH=$(uname -m)

PASS=0
FAIL=0
SKIP=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() {
    local name="$1"
    shift
    echo -n "  $name ... "
    if "$@" > /tmp/step.log 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}FAIL${NC}"
        tail -5 /tmp/step.log | sed 's/^/    /'
        FAIL=$((FAIL + 1))
    fi
}

# ── apt packages ──────────────────────────────────────────────────────────────
echo ""
echo "=== apt packages ==="
step "apt-get update" sudo apt-get update -qq

install_apt_packages() {
    local packages
    packages=$(grep -v '^#' "${SCRIPT_DIR}/apt_package_list.txt" | tr '\n' ' ')
    # shellcheck disable=SC2086
    sudo apt-get install -y -qq $packages
}
step "install apt_package_list.txt" install_apt_packages

# Spot-check a sample of apt-installed binaries
step "bat binary exists"      which batcat
step "btm binary exists"      which btm
step "thefuck binary exists"  which thefuck
step "swaync binary exists"   which swaync
step "wlogout binary exists"  which wlogout
step "rofi binary exists"     which rofi
step "waybar binary exists"   which waybar
step "zsh binary exists"      which zsh
step "tmux binary exists"     which tmux

# ── nodejs ───────────────────────────────────────────────────────────────────
echo ""
echo "=== nodejs ==="
install_nodejs() {
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - > /dev/null 2>&1
    sudo apt-get install -y -qq nodejs
}
step "install nodejs (NodeSource)" install_nodejs
step "node binary exists" which node
step "npm binary exists"  which npm

# ── neovim ───────────────────────────────────────────────────────────────────
echo ""
echo "=== neovim ==="
install_nvim() {
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
step "install neovim (prebuilt)" install_nvim
step "nvim binary exists" which nvim

# ── zellij ───────────────────────────────────────────────────────────────────
echo ""
echo "=== zellij ==="
install_zellij() {
    local version
    version=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
    local archive="zellij-x86_64-unknown-linux-musl.tar.gz"
    [ "$ARCH" = "aarch64" ] && archive="zellij-aarch64-unknown-linux-musl.tar.gz"
    curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${version}/${archive}" \
        | sudo tar -xz -C /usr/local/bin
}
step "install zellij (GitHub release)" install_zellij
step "zellij binary exists" which zellij

# ── glow ─────────────────────────────────────────────────────────────────────
echo ""
echo "=== glow ==="
install_glow() {
    curl -fsSL https://repo.charm.sh/apt/gpg.key \
        | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/charm.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/charm.gpg] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq glow
}
step "install glow (Charm apt repo)" install_glow
step "glow binary exists" which glow

# ── ghostty ──────────────────────────────────────────────────────────────────
echo ""
echo "=== ghostty ==="
install_ghostty() {
    local ubuntu_ver
    ubuntu_ver=$(. /etc/os-release && echo "$VERSION_ID")
    if [[ ! "$ubuntu_ver" =~ ^(24\.04|25\.10|26\.04)$ ]]; then
        echo "Ubuntu ${ubuntu_ver} not supported — requires 24.04+; use Kitty (~/.config/kitty)"
        return 0
    fi
    local tag
    tag=$(curl -s https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
    local deb_ver="${tag%-*}.${tag##*-}"
    local arch="amd64"
    [ "$ARCH" = "aarch64" ] && arch="arm64"
    curl -fsSL \
        "https://github.com/mkasberg/ghostty-ubuntu/releases/download/${tag}/ghostty_${deb_ver}_${arch}_${ubuntu_ver}.deb" \
        -o /tmp/ghostty.deb
    sudo apt-get install -y /tmp/ghostty.deb > /dev/null
    rm /tmp/ghostty.deb
}
UBUNTU_VER=$(. /etc/os-release && echo "$VERSION_ID")
if [[ "$UBUNTU_VER" =~ ^(24\.04|25\.10|26\.04)$ ]]; then
    step "install ghostty (mkasberg/ghostty-ubuntu .deb)" install_ghostty
    step "ghostty binary exists" which ghostty
else
    step "ghostty graceful skip on Ubuntu ${UBUNTU_VER}" install_ghostty
fi

# ── bluetui ──────────────────────────────────────────────────────────────────
echo ""
echo "=== bluetui ==="
install_bluetui() {
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
step "install bluetui (GitHub release)" install_bluetui
step "bluetui binary exists" which bluetui

# ── fonts ────────────────────────────────────────────────────────────────────
echo ""
echo "=== fonts ==="
install_nerd_fonts() {
    local version
    version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4)
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/Iosevka.zip" \
        -o /tmp/iosevka-nerd.zip
    sudo mkdir -p /usr/local/share/fonts/nerd-fonts/Iosevka
    sudo unzip -o /tmp/iosevka-nerd.zip -d /usr/local/share/fonts/nerd-fonts/Iosevka '*.ttf' > /dev/null
    rm /tmp/iosevka-nerd.zip
    sudo fc-cache -fv > /dev/null 2>&1
}
step "install Iosevka Nerd Font" install_nerd_fonts
step "Iosevka Nerd Font registered" bash -c 'fc-list | grep -qi "Iosevka Nerd"'

install_phosphor_icons() {
    local version
    version=$(curl -s https://api.github.com/repos/phosphor-icons/homepage/releases \
        | grep '"tag_name"' | head -1 | cut -d'"' -f4)
    curl -fsSL \
        "https://github.com/phosphor-icons/homepage/releases/download/${version}/phosphor-icons.zip" \
        -o /tmp/phosphor-icons.zip
    sudo mkdir -p /usr/local/share/fonts/phosphor
    sudo unzip -o /tmp/phosphor-icons.zip 'Fonts/**/*.ttf' -d /usr/local/share/fonts/phosphor > /dev/null
    rm /tmp/phosphor-icons.zip
    sudo fc-cache -fv > /dev/null 2>&1
}
step "install Phosphor Icons font" install_phosphor_icons

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
echo ""
echo "=== oh-my-zsh ==="
install_oh_my_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
}
step "install oh-my-zsh" install_oh_my_zsh
step "~/.oh-my-zsh exists" test -d "$HOME/.oh-my-zsh"

# ── configs ───────────────────────────────────────────────────────────────────
echo ""
echo "=== configs ==="
link_configs() {
    mkdir -p "$HOME/.config"
    for dir in ${SCRIPT_DIR}/.config/*/; do
        name=$(basename "$dir")
        rm -f "$HOME/.config/${name}"
        ln -sf "${dir%/}" "$HOME/.config/${name}"
    done
}
step "link .config dirs" link_configs
step "~/.config/nvim symlink"   test -L "$HOME/.config/nvim"
step "~/.config/sway symlink"   test -L "$HOME/.config/sway"
step "~/.config/zellij symlink" test -L "$HOME/.config/zellij"

setup_zsh_extras() {
    ln -sf "${SCRIPT_DIR}/.zshrc_extras" "$HOME/.zshrc_extras"
    if ! grep -qF "source ~/.zshrc_extras" "$HOME/.zshrc" 2>/dev/null; then
        echo $'\nsource ~/.zshrc_extras' >> "$HOME/.zshrc"
    fi
}
step "setup zsh extras"       setup_zsh_extras
step "~/.zshrc_extras symlink" test -L "$HOME/.zshrc_extras"
step "zshrc sources extras"   grep -q "source ~/.zshrc_extras" "$HOME/.zshrc"

# ── summary ──────────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo -e "  ${GREEN}PASS${NC}: $PASS   ${RED}FAIL${NC}: $FAIL   ${YELLOW}SKIP${NC}: $SKIP"
echo "================================================"

[ "$FAIL" -eq 0 ]
