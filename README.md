# dotfiles

Personal Arch Linux dotfiles for a Sway-based Wayland desktop. Includes configs for all core tools and a bootstrap script to get a fresh machine up and running quickly.

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
| [Zellij](https://zellij.dev/) | Terminal multiplexer |
| [Zsh](https://www.zsh.sh/) + [Oh My Zsh](https://ohmyz.sh/) | Shell |

### Launchers
| Tool | Purpose |
|------|---------|
| [Rofi](https://github.com/davatorium/rofi) | Application launcher, powermenu, applets |
Rofi includes multiple launcher types (type-1 through type-7), powermenu styles, and applets for battery, brightness, volume, screenshots, and more.

### Utilities
| Tool | Purpose |
|------|---------|
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting |
| [bottom](https://github.com/ClementTsang/bottom) | System monitor |
| [glow](https://github.com/charmbracelet/glow) | Terminal Markdown renderer |
| [grim](https://sr.ht/~emersion/grim/) | Screenshot tool |
| [flameshot](https://flameshot.org/) | Annotated screenshots |
| [thefuck](https://github.com/nvbn/thefuck) | Command correction |
| [brightnessctl](https://github.com/Hummer12007/brightnessctl) | Brightness control |

### Fonts
- `ttf-iosevka-nerd` — primary coding font
- `ttf-fira-code` — alternate coding font
- `ttf-font-awesome` — icon font
- `ttf-phosphor-icons` — icon font (AUR)

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
│   ├── rofi/               # Launcher themes and applets

│   ├── ghostty/            # Ghostty terminal config
│   ├── zellij/             # Zellij multiplexer config
│   ├── clangd/             # clangd LSP config
│   ├── gtk-3.0/            # GTK theme settings
│   └── flameshot/          # Screenshot tool config
├── .local/
│   └── wallpapers/         # Wallpaper images
├── snippets/               # Shared VS Code-style snippets (C)
├── .zshrc_extras           # Zsh aliases, env vars, and path setup
├── .bash_aliases           # Bash aliases (sourced by some tools)
├── pacman_package_list.txt # Official repo packages
├── yay_package_list.txt    # AUR packages
└── bootstrap.sh            # Setup script
```

---

## Bootstrap Script

`bootstrap.sh` automates a full environment setup on a fresh Arch install. It runs the following steps in order:

### 1. Install pacman packages
Reads `pacman_package_list.txt` and installs any packages not already present — uses `comm` to diff against the currently installed set, so it's safe to re-run.

### 2. Install yay (AUR helper)
Checks if `yay` is already installed. If not, clones the AUR repo for yay into `/tmp` and builds it with `makepkg`.

### 3. Install yay (AUR) packages
Reads `yay_package_list.txt` and installs any missing AUR packages using the same diff approach as the pacman step.

### 4. Install Neovim
Checks if `nvim` is on the PATH. If not, clones the Neovim source repo into `/tmp` and builds it from source with `make -j$(nproc)`.

### 5. Install Oh My Zsh
Runs the official Oh My Zsh install script via `curl`.

### 6. Link configs
Symlinks each directory under `.config/` into `~/.config/`, replacing any existing symlink at that path. This keeps configs in the repo and live-updates when the repo changes.

### 7. Link wallpapers
Symlinks `.local/wallpapers/` to `~/.local/wallpapers/`.

### 8. Set up Zsh extras
Symlinks `.zshrc_extras` to `~/.zshrc_extras` and appends a `source ~/.zshrc_extras` line to `~/.zshrc` if it isn't already there.

---

## Shell Aliases & Config (`.zshrc_extras`)

Key aliases and environment setup sourced into Zsh:

- `cat` → `bat` (syntax-highlighted output)
- `vim` / `vi` → `nvim`
- `ll` → `ls -ltra --color=always`
- `gs`, `ga`, `gc`, `gp`, `gl` — common git shortcuts
- `update` → `yay -Syu`
- `reload` → re-sources `~/.zshrc`
- `sys_clean_all` — runs all cleanup aliases at once (package caches, AUR caches, journal logs, thumbnail cache, nvim swap files)
- `EDITOR` / `VISUAL` set to `nvim`
