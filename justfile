# Global variables
PROJECT_DIR := justfile_directory()
PACMAN_HOOKS_DIR := "/etc/pacman.d/hooks"
CONFIG_DIR := env_var('HOME') / ".config"
OS := `command -v pacman > /dev/null 2>&1 && echo "arch" || (command -v apt-get > /dev/null 2>&1 && echo "debian" || echo "unknown")`

# ── Wrappers ─────────────────────────────────────────────────────────────────

# Post-HyDE install order: 1) HyDE installer (packages + desktop)  2) just setup-arch (symlinks)
# Symlinking keeps config management independent of HyDE — works with or without it.
# Setup all configurations for Arch Linux desktop
setup-arch:
    just setup-pacman
    just install-paru
    just setup-shell
    just setup-starship
    just setup-neovim
    just setup-tmux
    just setup-alacritty
    just setup-environment-variables
    just setup-hyprland
    just setup-waybar
    just setup-pipewire
    just setup-bat
    just setup-ripgrep
    just setup-gitconfig
    just setup-custom-scripts

# Setup configurations for servers/VMs (CLI core only)
setup-server:
    just setup-shell
    just setup-starship
    just setup-neovim
    just setup-tmux
    just setup-bat
    just setup-ripgrep
    just setup-gitconfig
    just setup-inputrc

# ── Applications ──────────────────────────────────────────────────────────────

# Install Paru AUR package manager (Arch only)
install-paru:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "Paru is only available on Arch Linux"
        exit 1
    fi
    if command -v paru > /dev/null 2>&1; then
        echo "Paru already installed, skipping"
    else
        echo "Installing Paru AUR package manager"
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si --noconfirm
        rm -rf /tmp/paru
    fi
    sudo ln -sf "{{PROJECT_DIR}}/paru/paru.conf" /etc/paru.conf

# Install and configure shell (fish on Arch, bash on servers)
setup-shell:
    #!/usr/bin/env bash
    set -e
    echo "Installing shell and utilities"
    if [ "{{OS}}" = "arch" ]; then
        sudo pacman -S --needed fish fastfetch trash-cli bat tar bzip2 ncompress
        if ! command -v paru > /dev/null; then
            just install-paru
        fi
        sudo paru -S --needed rar
        echo "Symlinking fish config"
        mkdir -p "{{CONFIG_DIR}}"
        ln -sf "{{PROJECT_DIR}}/fish" "{{CONFIG_DIR}}/fish"
    elif [ "{{OS}}" = "debian" ]; then
        sudo apt-get install -y bash-completion trash-cli bat tar bzip2 ncompress
        echo "Symlinking bashrc"
        ln -sf "{{PROJECT_DIR}}/bashrc" "{{env_var('HOME')}}/.bashrc"
    else
        echo "Unsupported OS: {{OS}}"
        exit 1
    fi

# Install and setup Starship prompt
setup-starship:
    #!/usr/bin/env bash
    set -e
    echo "Installing Starship"
    if [ "{{OS}}" = "arch" ]; then
        sudo pacman -S --needed starship
    elif [ "{{OS}}" = "debian" ]; then
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    else
        echo "Unsupported OS: {{OS}}"
        exit 1
    fi
    echo "Symlinking Starship config"
    mkdir -p "{{CONFIG_DIR}}/starship"
    if [ "{{OS}}" = "arch" ]; then
        ln -sf "{{PROJECT_DIR}}/starship/starship.toml" "{{CONFIG_DIR}}/starship/starship.toml"
    else
        ln -sf "{{PROJECT_DIR}}/starship/starship-server.toml" "{{CONFIG_DIR}}/starship/starship.toml"
    fi

# Install and configure Neovim
setup-neovim:
    #!/usr/bin/env bash
    set -e
    echo "Installing Neovim and dependencies"
    if [ "{{OS}}" = "arch" ]; then
        sudo pacman -S --needed neovim git curl lazygit fzf ripgrep ripgrep-all fd
    elif [ "{{OS}}" = "debian" ]; then
        sudo apt-get install -y neovim git curl fzf ripgrep fd-find
        # fd is installed as fdfind on Debian — normalise to fd
        sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
        # lazygit is not in apt — install from GitHub releases
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit /usr/local/bin/lazygit
        rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    else
        echo "Unsupported OS: {{OS}}"
        exit 1
    fi
    echo "Symlinking Neovim config"
    mkdir -p "{{CONFIG_DIR}}"
    ln -sf "{{PROJECT_DIR}}/nvim" "{{CONFIG_DIR}}/nvim"

# Install and configure tmux
setup-tmux:
    #!/usr/bin/env bash
    set -e
    echo "Installing tmux"
    if [ "{{OS}}" = "arch" ]; then
        sudo pacman -S --needed tmux
    elif [ "{{OS}}" = "debian" ]; then
        sudo apt-get install -y tmux
    else
        echo "Unsupported OS: {{OS}}"
        exit 1
    fi
    echo "Symlinking tmux config"
    mkdir -p "{{env_var('HOME')}}/.config/tmux"
    if [ "{{OS}}" = "arch" ]; then
        ln -sf "{{PROJECT_DIR}}/tmux/tmux.conf" "{{env_var('HOME')}}/.config/tmux/tmux.conf"
    else
        ln -sf "{{PROJECT_DIR}}/tmux/tmux-server.conf" "{{env_var('HOME')}}/.config/tmux/tmux.conf"
    fi
    if [ ! -d "{{env_var('HOME')}}/.config/tmux/plugins/tpm" ]; then
        echo "Cloning tpm"
        git clone https://github.com/tmux-plugins/tpm "{{env_var('HOME')}}/.config/tmux/plugins/tpm"
    else
        echo "tpm already installed, skipping clone"
    fi
    echo "Run prefix + I inside tmux to install plugins"

# Symlink git configuration
setup-gitconfig:
    @echo "Symlinking git config"
    ln -sf "{{PROJECT_DIR}}/git/gitconfig" "{{env_var('HOME')}}/.gitconfig"

# Configure bat (syntax highlighting pager)
setup-bat:
    #!/usr/bin/env bash
    set -e
    echo "Installing bat"
    if [ "{{OS}}" = "arch" ]; then
        sudo pacman -S --needed bat
    elif [ "{{OS}}" = "debian" ]; then
        sudo apt-get install -y bat
    fi
    echo "Symlinking bat config"
    mkdir -p "{{CONFIG_DIR}}/bat"
    ln -sf "{{PROJECT_DIR}}/bat/config" "{{CONFIG_DIR}}/bat/config"

# Configure ripgrep
setup-ripgrep:
    #!/usr/bin/env bash
    set -e
    echo "Installing ripgrep"
    if [ "{{OS}}" = "arch" ]; then
        sudo pacman -S --needed ripgrep
    elif [ "{{OS}}" = "debian" ]; then
        sudo apt-get install -y ripgrep
    fi
    echo "Symlinking ripgrep config"
    mkdir -p "{{CONFIG_DIR}}/ripgrep"
    ln -sf "{{PROJECT_DIR}}/ripgrep/ripgreprc" "{{CONFIG_DIR}}/ripgrep/ripgreprc"

# Symlink readline config (server/bash only)
setup-inputrc:
    @echo "Symlinking inputrc"
    ln -sf "{{PROJECT_DIR}}/inputrc" "{{env_var('HOME')}}/.inputrc"

# Setup pacman configuration and custom post-transaction hooks (Arch only)
setup-pacman:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "Pacman setup is only supported on Arch Linux"
        exit 1
    fi
    echo "Symlinking pacman configuration"
    sudo rm -f /etc/pacman.conf
    sudo ln -sf "{{PROJECT_DIR}}/pacman/pacman.conf" /etc/pacman.conf

    echo "Symlinking plex-desktop fix script"
    sudo rm -f /usr/local/bin/plex-desktop-fix
    sudo ln -sf "{{PROJECT_DIR}}/custom_scripts/fix-plex-desktop" /usr/local/bin/plex-desktop-fix

    echo "Cleaning up old hook symlinks in {{PACMAN_HOOKS_DIR}}"
    if [ -d "{{PACMAN_HOOKS_DIR}}" ]; then
        sudo find "{{PACMAN_HOOKS_DIR}}" -maxdepth 1 -type l -lname "{{PROJECT_DIR}}/pacman/hooks/*" -delete
    fi

    echo "Symlinking pacman hooks"
    sudo mkdir -p "{{PACMAN_HOOKS_DIR}}"
    for hook in "{{PROJECT_DIR}}/pacman/hooks/"*.hook; do
        filename=$(basename "$hook")
        sudo ln -sf "$hook" "{{PACMAN_HOOKS_DIR}}/$filename"
        echo "  Linked: $filename"
    done

# Install and configure Alacritty (Arch only)
setup-alacritty:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "Alacritty setup is only supported on Arch Linux"
        exit 1
    fi
    echo "Installing Alacritty"
    sudo pacman -S --needed alacritty
    echo "Symlinking Alacritty config"
    mkdir -p "{{CONFIG_DIR}}"
    ln -sf "{{PROJECT_DIR}}/alacritty" "{{CONFIG_DIR}}/alacritty"

# Setup systemd environment variables (Arch/Desktop only)
setup-environment-variables:
    @echo "Symlinking systemd environment variables"
    mkdir -p "{{CONFIG_DIR}}"
    ln -sf "{{PROJECT_DIR}}/environment.d" "{{CONFIG_DIR}}/environment.d"

# Symlink Hyprland user preferences (HyDE managed install, Arch only)
setup-hyprland:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "Hyprland setup is only supported on Arch Linux"
        exit 1
    fi
    echo "Symlinking Hyprland user config"
    mkdir -p "{{CONFIG_DIR}}/hypr"
    ln -sf "{{PROJECT_DIR}}/hypr/userprefs.conf" "{{CONFIG_DIR}}/hypr/userprefs.conf"

# Symlink Waybar user config (HyDE managed install, Arch only)
setup-waybar:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "Waybar setup is only supported on Arch Linux"
        exit 1
    fi
    echo "Symlinking Waybar config"
    mkdir -p "{{CONFIG_DIR}}"
    ln -sf "{{PROJECT_DIR}}/waybar" "{{CONFIG_DIR}}/waybar"

# Symlink PipeWire configuration (Arch only)
setup-pipewire:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "PipeWire setup is only supported on Arch Linux"
        exit 1
    fi
    echo "Symlinking PipeWire config"
    mkdir -p "{{CONFIG_DIR}}"
    ln -sf "{{PROJECT_DIR}}/pipewire" "{{CONFIG_DIR}}/pipewire"

# Symlink custom scripts to /usr/local/bin (Arch only)
setup-custom-scripts:
    #!/usr/bin/env bash
    set -e
    if [ "{{OS}}" != "arch" ]; then
        echo "Custom scripts setup is only supported on Arch Linux"
        exit 1
    fi
    echo "Symlinking custom scripts"
    sudo ln -sf "{{PROJECT_DIR}}/custom_scripts/audio-mode-switcher" /usr/local/bin/audio-mode-switcher
    sudo ln -sf "{{PROJECT_DIR}}/custom_scripts/mic-toggle" /usr/local/bin/mic-toggle
    sudo ln -sf "{{PROJECT_DIR}}/custom_scripts/restart-hyprlock" /usr/local/bin/restart-hyprlock

# ── Utilities ─────────────────────────────────────────────────────────────────

# Check the status of all managed symlinks
status:
    #!/usr/bin/env bash

    check() {
        local label="$1"
        local path="$2"
        if [ -L "$path" ]; then
            if [ -e "$path" ]; then
                printf "  \033[32m[OK]    \033[0m %s → %s\n" "$label" "$(readlink "$path")"
            else
                printf "  \033[31m[BROKEN]\033[0m %s → %s\n" "$label" "$(readlink "$path")"
            fi
        elif [ -e "$path" ]; then
            printf "  \033[33m[FILE]  \033[0m %s (exists but is not a symlink)\n" "$label"
        else
            printf "  \033[90m[MISS]  \033[0m %s\n" "$label"
        fi
    }

    echo ""
    echo "── CLI Core ──────────────────────────────────────────────────────────────────"
    if [ "{{OS}}" = "arch" ]; then
        check "fish config" "{{CONFIG_DIR}}/fish"
    else
        check "bashrc"      "{{env_var('HOME')}}/.bashrc"
    fi
    check "starship"  "{{CONFIG_DIR}}/starship/starship.toml"
    check "nvim"      "{{CONFIG_DIR}}/nvim"
    check "tmux.conf" "{{env_var('HOME')}}/.config/tmux/tmux.conf"
    check "gitconfig"  "{{env_var('HOME')}}/.gitconfig"
    check "bat"        "{{CONFIG_DIR}}/bat/config"
    check "ripgrep"    "{{CONFIG_DIR}}/ripgrep/ripgreprc"

    if [ "{{OS}}" = "arch" ]; then
        echo ""
        echo "── Arch / Desktop ────────────────────────────────────────────────────────────"
        check "alacritty"           "{{CONFIG_DIR}}/alacritty"
        check "environment.d"       "{{CONFIG_DIR}}/environment.d"
        check "hypr/userprefs.conf" "{{CONFIG_DIR}}/hypr/userprefs.conf"
        check "waybar"              "{{CONFIG_DIR}}/waybar"
        check "pipewire"            "{{CONFIG_DIR}}/pipewire"
        check "pacman.conf"         "/etc/pacman.conf"
        check "paru.conf"           "/etc/paru.conf"

        echo ""
        echo "── Pacman Hooks ──────────────────────────────────────────────────────────────"
        for hook in "{{PROJECT_DIR}}/pacman/hooks/"*.hook; do
            filename=$(basename "$hook")
            check "$filename" "{{PACMAN_HOOKS_DIR}}/$filename"
        done

        echo ""
        echo "── Custom Scripts ────────────────────────────────────────────────────────────"
        check "audio-mode-switcher" "/usr/local/bin/audio-mode-switcher"
        check "mic-toggle"          "/usr/local/bin/mic-toggle"
        check "restart-hyprlock"    "/usr/local/bin/restart-hyprlock"
        check "plex-desktop-fix"    "/usr/local/bin/plex-desktop-fix"
    fi
    echo ""
