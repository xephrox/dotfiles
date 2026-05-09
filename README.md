# Dotfiles

Personal system configuration for Arch Linux (primary) and Debian servers (secondary), managed with symlinks via [just](https://just.systems).

> Forever work in progress

## Structure

```
dotfiles/
├── justfile               # Task runner — all install and symlink recipes
├── install-arch.sh        # Bootstrap script for fresh Arch installs
├── fish/                  # Fish shell config + functions
├── starship/              # Starship prompt (separate configs for Arch/server)
├── nvim/                  # Neovim (LazyVim base)
├── tmux/                  # tmux (separate configs for Arch/server)
├── alacritty/             # Alacritty terminal
├── bat/                   # bat config (Catppuccin Mocha)
├── ripgrep/               # ripgrep config
├── git/                   # gitconfig
├── hypr/                  # Hyprland user preferences
├── waybar/                # Waybar layouts and modules
├── pipewire/              # PipeWire virtual audio (Scarlett 2i2 + Audeze Maxwell)
├── environment.d/         # systemd user environment variables (Wayland)
├── pacman/                # pacman.conf + post-transaction hooks
├── paru/                  # paru.conf (AUR helper)
├── hyde/                  # HyDE package lists (pkg_user.lst, pkg_black.lst)
├── custom_scripts/        # audio-mode-switcher, mic-toggle, restart-hyprlock
└── inputrc                # readline config (server/bash only)
```

## Quick Start

### Fresh Arch Install (with HyDE)

```bash
curl -sS https://raw.githubusercontent.com/xephrox/dotfiles/main/install-arch.sh | bash
```

This will:
1. Install git and clone this repo
2. Clone [HyDE](https://github.com/HyDE-Project/HyDE) and run its installer (using `hyde/pkg_user.lst` and `hyde/pkg_black.lst`)
3. Set fish as the default shell
4. Install `just` and run `just setup-arch` to symlink all configs

### Existing Arch Install

```bash
git clone https://github.com/xephrox/dotfiles.git ~/dotfiles
cd ~/dotfiles
just setup-arch
```

### Server / VM (CLI only)

```bash
git clone https://github.com/xephrox/dotfiles.git ~/dotfiles
cd ~/dotfiles
just setup-server
```

## Recipes

```
just setup-arch       # Full Arch desktop setup
just setup-server     # CLI-only setup for servers/VMs
just status           # Check the state of all managed symlinks
```

Individual recipes can also be run directly (e.g. `just setup-neovim`, `just setup-tmux`).

## What's Included

| App | Arch | Server | Notes |
|---|---|---|---|
| Fish shell | ✓ | — | Bash used on servers |
| Starship | ✓ | ✓ | Warm Mocha on Arch, cool Frappe on server |
| Neovim | ✓ | ✓ | LazyVim base |
| tmux | ✓ | ✓ | `C-a` prefix on Arch, `C-b` on server; Catppuccin themed |
| Alacritty | ✓ | — | |
| bat | ✓ | ✓ | Catppuccin Mocha theme |
| ripgrep | ✓ | ✓ | Smart case, hidden files, follows symlinks |
| git | ✓ | ✓ | Standard config, no credentials stored |
| Hyprland | ✓ | — | HyDE managed, userprefs.conf symlinked |
| Waybar | ✓ | — | Custom layout + audio mode module |
| PipeWire | ✓ | — | Virtual audio for Scarlett 2i2 / Audeze Maxwell switching |
| pacman | ✓ | — | Custom config + post-transaction hooks |
| paru | ✓ | — | AUR helper |
| readline | — | ✓ | Case-insensitive completion, colored stats |

## Desktop Setup (Arch)

Built on [HyDE](https://github.com/HyDE-Project/HyDE) (Hyprland Desktop Environment):

- **WM**: Hyprland
- **Terminal**: Alacritty
- **Editor**: Neovim (`alacritty -e nvim`)
- **File manager**: Thunar
- **Shell**: Fish + Starship (Catppuccin Mocha)
- **Theme**: Catppuccin Mocha throughout (tmux, bat, starship)

### Audio

PipeWire virtual audio routes through a single virtual device, switchable between:
- **Desk mode** — Focusrite Scarlett 2i2 (SM7B mic + DT990 headphones)
- **Wireless mode** — Audeze Maxwell

Keybinds:
- `Super + M` — toggle mic mute
- `Super + Shift + M` — switch audio mode

## HyDE Integration

`hyde/pkg_user.lst` adds packages on top of the HyDE base install. `hyde/pkg_black.lst` excludes packages that conflict with this setup (kitty → alacritty, dolphin → thunar, etc.).

Symlinks always run after HyDE so they overwrite HyDE defaults with these configs.
