# Global variables
PROJECT_DIR := "/storage/media/code/dotfiles"
PACMAN_HOOKS_DIR := "/etc/pacman.d/hooks"
CONFIG_DIR := "{{env.HOME}}/.config"

# Install Paru AUR package manager
install-paru:
	@echo "⚙️Installing Paru AUR package manager"
	sudo pacman -S --needed base-devel git
	git clone https://aur.archlinux.org/paru.git /tmp/paru
	cd /tmp/paru && makepkg -si --noconfirm
	rm -rf /tmp/paru
	
# Symlink bashrc and install required packages
setup-bashrc:
	# Update package database and install essential packages
	@echo "⚙️ Installing required packages"
	sudo pacman -Sy --needed fastfetch bash-completion trash-cli bat tar bzip2 ncompress starship
	# Check if paru is installed
	if ! command -v paru > /dev/null; then \
		just install-paru; \
	fi
	# Installing rar for extract()
	sudo paru -S --needed rar
	# Symlink bashrc
	@echo "🔗 Symlinking bashrc from {{PROJECT_DIR}}/bashrc to {{env.HOME}}/.bashrc ..."
	ln -sf {{PROJECT_DIR}}/bashrc {{env.HOME}}/.bashrc

# Install and configure alacritty
setup-alacritty:
	@echo "⚙️ Installing alacritty"
	sudo pacman -Sy --needed alacritty
	@echo "🔗 Symlinking bashrc from {{PROJECT_DIR}}/alacritty to {{CONFIG_DIR}}/alacritty ..."
	mkdir -p {{CONFIG_DIR}}
	ln -sf {{PROJECT_DIR}}/alacritty {{CONFIG_DIR}}/alacritty

# Setup systemd environment variables
setup-environment-variables:
	@echo "🔗 Symlinking systemd environment variables from {{PROJECT_DIR}}/environment.d to {{CONFIG_DIR}}/environment.d ..."
	mkdir -p {{CONFIG_DIR}}
	ln -sf {{PROJECT_DIR}}/environment.d {{CONFIG_DIR}}/environment.d

# Install and setup starship
setup-starship:
	@echo "⚙️ Installing starship"
	sudo pacman -Sy --needed starship
	@echo "🔗 Symlinking starship configuration from {{PROJECT_DIR}}/starship to {{CONFIG_DIR}}/starship ..."
	mkdir -p {{CONFIG_DIR}}
	ln -sf {{PROJECT_DIR}}/starship {{CONFIG_DIR}}/starship

# Install and configure Neovim
setup-neovim:
	@echo "⚙️ Installing Neovim"
	sudo pacman -Sy --needed neovim
	@echo "🪛Installing dependencies"
	sudo pacman -Sy --needed git curl lazygit fzf ripgrep ripgrep-all fd
	@echo "🔗 Symlinking Neovim configuration from {{PROJECT_DIR}}/nvim to {{CONFIG_DIR}}/nvim ..."
	mkdir -p {{CONFIG_DIR}}
	ln -sf {{PROJECT_DIR}}/nvim to {{CONFIG_DIR}}/nvim

# setup pacman configuration and custom post transaction hooks 
setup-pacman:
	@echo "📦 Copying pacman configuration"
	sudo rm -f /etc/pacman.conf
	sudo ln -sf {{PROJECT_DIR}}/pacman/pacman.conf /etc/pacman.conf

	@echo "🔗 Symlinking custom plex-desktop fix script - Refer pinned comment in https://aur.archlinux.org/packages/plex-desktop"
	sudo rm -f /usr/local/bin/plex-desktop-fix
	sudo ln -sf {{PROJECT_DIR}}/custom-scripts/plex-desktop-fix.sh /usr/local/bin/plex-desktop-fix

	@echo "🧹 Cleaning up old hook symlinks in {{PACMAN_HOOKS_DIR}}..."; \
	if [ -d {{PACMAN_HOOKS_DIR}} ]; then \
		sudo find {{PACMAN_HOOKS_DIR}} -maxdepth 1 -type l -lname "{{PROJECT_DIR}}/pacman/hooks/*" -delete; \
		fi

	@echo "🔗 Symlinking pacman hook files from {{PROJECT_DIR}}/pacman/hooks to {{PACMAN_HOOKS_DIR}}..."
	for hook in {{PROJECT_DIR}}/pacman/*.hook; do \
		filename=$(basename "$hook"); \
		sudo ln -sf "$hook" "{{PACMAN_HOOKS_DIR}}/$filename"; \
		echo "✔️  Linked: $hook → {{PACMAN_HOOKS_DIR}}/$filename"; \
		done
	@echo "✅ Done."

