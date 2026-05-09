# Project: Universal Dotfiles & Configuration

## Overview

A repository dedicated to managing user-space configurations (dotfiles) and system packages. It aims for a "single source of truth" that adapts based on the host environment. The configuration will contain the usual dotfile application configurations but also some custom scripts. Most of the files will be used on the Desktop and subset of the dotfile configurations will live in the Servers.

## Primary Targets

1. **Desktop (Arch Linux):** Integration with the HyDE Project framework.
2. **Servers (Debian/Generic):** Headless environments using standard terminal tools.

## Core Technologies

- **Task Runner:** `Justfile` (primary entry point for automation).
- **Desktop Framework:** HyDE (Hyprland Desktop Environment).
- **Shells:** Bash with agnostic configurations.
- **Editor:** Neovim (primary IDE).
- **Multiplexer:** Tmux.
