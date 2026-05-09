# Configuration Logic

## The "Hybrid" Deployment Strategy

1. **Generic Layer (Server/CLI):**
   - Managed via `Justfile`.
   - Uses standard symlinking (`ln -sf`) to map configs like `.bashrc`, `nvim/`, and `tmux.conf`.
2. **Arch/Desktop Layer (HyDE):**
   - Managed by symlinking local repo files into HyDE's expected paths.
   - `pkg_user.lst`
   - `restore_cfg.psv`
   - Triggers HyDE's internal restoration scripts for desktop-specific setup.

## Environment Detection

- Scripts and `Justfiles` should detect the OS (Arch vs. Debian) or the session type (Wayland vs. TTY) to apply relevant tweaks.
