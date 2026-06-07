# dotfiles

Personal dotfiles for a Sway-based Wayland desktop on **Ubuntu 24.04 LTS**. Includes configs for all core tools and a bootstrap script to get a fresh machine up and running quickly.

## Quick Start

```bash
git clone https://github.com/evanstoddard/dotfiles/
cd dotfiles
./bootstrap.sh
```

---

## What's Included

### Window Manager & Desktop
| Tool | Purpose |
|------|---------|
| [Sway](https://swaywm.org/) | Tiling Wayland compositor (i3-compatible) |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | Notification center |
| [wlogout](https://github.com/ArtsyMacaw/wlogout) | Logout / power menu |
| [Hyprlock](https://github.com/hyprwm/hyprlock) | Screen locker |
| [swaybg](https://github.com/swaywm/swaybg) | Wallpaper |
| [kanshi](https://git.sr.ht/~emersion/kanshi) | Dynamic display configuration |

### Editor
| Tool | Purpose |
|------|---------|
| [Neovim](https://neovim.io/) + [AstroNvim](https://astronvim.com/) | Primary editor |

AstroNvim is used as the Neovim framework. Plugins are managed via `lazy.nvim` and configured under `.config/nvim/lua/plugins/`:

- **LSP** — `astrolsp.lua`, Mason for automatic LSP/formatter installation
- **DAP** — Debug Adapter Protocol support via `dap.lua`
- **Treesitter** — syntax highlighting and parsing
- **none-ls** — additional linting and formatting sources
- **neogen** — docstring/annotation generation
- **luasnip** — snippet engine with custom C snippets

### Terminal & Shell
| Tool | Purpose |
|------|---------|
| [Ghostty](https://ghostty.org/) | Primary terminal emulator |
| [Kitty](https://sw.kovidgoyal.net/kitty/) | Alternate terminal emulator |
| [Zellij](https://zellij.dev/) | Terminal multiplexer |
| [Zsh](https://www.zsh.sh/) + [Oh My Zsh](https://ohmyz.sh/) | Shell |

### Launchers
| Tool | Purpose |
|------|---------|
| [Rofi](https://github.com/davatorium/rofi) | Application launcher |

### Utilities
| Tool | Purpose |
|------|---------|
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting |
| [bottom](https://github.com/ClementTsang/bottom) | System monitor (`btm`) |
| [glow](https://github.com/charmbracelet/glow) | Terminal Markdown renderer |
| [grim](https://sr.ht/~emersion/grim/) | Screenshot tool |
| [flameshot](https://flameshot.org/) | Annotated screenshots |
| [thefuck](https://github.com/nvbn/thefuck) | Command correction |
| [brightnessctl](https://github.com/Hummer12007/brightnessctl) | Brightness control |
| [bluetui](https://github.com/pythops/bluetui) | Bluetooth TUI |

### Fonts
- `ttf-iosevka-nerd` — primary coding font (installed from nerd-fonts releases)
- `fonts-firacode` — alternate coding font
- `fonts-font-awesome` — icon font
- Phosphor Icons — icon font (installed from GitHub releases)

---

## Repository Structure

```
dotfiles/
├── .config/
│   ├── nvim/               # Neovim / AstroNvim config
│   │   └── lua/
│   │       └── plugins/    # Plugin configurations
│   ├── sway/               # Sway WM config
│   ├── waybar/             # Status bar config + CSS
│   ├── swaync/             # Notification center config
│   ├── hypr/               # Hyprlock screen locker
│   ├── wlogout/            # Logout menu layout + styles
│   ├── rofi/               # Launcher config
│   ├── ghostty/            # Ghostty terminal config
│   ├── kitty/              # Kitty terminal config
│   ├── zellij/             # Zellij multiplexer config
│   ├── clangd/             # clangd LSP config
│   ├── gtk-3.0/            # GTK theme settings
│   └── flameshot/          # Screenshot tool config
├── .local/
│   └── wallpapers/         # Wallpaper images
├── snippets/               # Shared VS Code-style snippets (C)
├── .zshrc_extras           # Zsh aliases, env vars, and path setup
├── .bash_aliases           # Bash aliases (sourced by some tools)
├── apt_package_list.txt    # Ubuntu apt packages
├── test_bootstrap.sh       # Bootstrap validation script (Docker)
├── Dockerfile.test         # Ubuntu 24.04 test image
└── bootstrap.sh            # Setup script
```

---

## Bootstrap Script

`bootstrap.sh` automates a full environment setup on a fresh Ubuntu 24.04 install. It runs the following steps in order:

### 1. Install apt packages
Reads `apt_package_list.txt` and installs all packages via `apt-get`.

### 2. Install Node.js
Adds the NodeSource LTS repository and installs `nodejs`.

### 3. Install Zellij
Downloads the latest release binary from GitHub.

### 4. Install Glow
Adds the Charm apt repository and installs `glow`.

### 5. Install Ghostty
Downloads the appropriate `.deb` from [mkasberg/ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) for the running Ubuntu version (24.04+). Falls back with a message suggesting Kitty on older releases.

### 6. Install bluetui
Downloads the latest release binary from GitHub.

### 7. Install Nerd Fonts
Downloads and installs the Iosevka Nerd Font from the nerd-fonts GitHub releases.

### 8. Install Phosphor Icons
Downloads and installs the Phosphor Icons font from GitHub releases.

### 9. Install Neovim
Downloads and installs the latest prebuilt release binary from GitHub.

### 10. Install Oh My Zsh
Runs the official Oh My Zsh install script in unattended mode.

### 11. Link configs
Symlinks each directory under `.config/` into `~/.config/`, replacing any existing symlink at that path.

### 12. Link wallpapers
Symlinks `.local/wallpapers/` to `~/.local/wallpapers/`.

### 13. Set up Zsh extras
Symlinks `.zshrc_extras` to `~/.zshrc_extras` and appends a `source ~/.zshrc_extras` line to `~/.zshrc` if not already present.

### Manual installs
These are not automated — download separately as needed:

| Tool | Source |
|------|--------|
| [Zen Browser](https://zen-browser.app) | Download `.deb` from zen-browser.app |
| [JLink](https://www.segger.com/downloads/jlink) | Download installer from SEGGER |
| [Hyprlock](https://hyprland.org) | Requires full Hypr ecosystem |
| [wdisplays](https://github.com/cyclopsian/wdisplays) | Build from source |

---

## Shell Aliases & Config (`.zshrc_extras`)

Key aliases and environment setup sourced into Zsh:

- `cat` → `bat` / `batcat` (syntax-highlighted output, handles Ubuntu's binary name)
- `vim` / `vi` → `nvim`
- `ll` → `ls -ltra --color=always`
- `gs`, `ga`, `gc`, `gp`, `gl` — common git shortcuts
- `update` → `sudo apt update && sudo apt upgrade -y`
- `reload` → re-sources `~/.zshrc`
- `sys_clean_all` — runs all cleanup aliases at once (package caches, journal logs, thumbnail cache, nvim swap files)
- `EDITOR` / `VISUAL` set to `nvim`
