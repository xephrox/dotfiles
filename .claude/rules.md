# Development Rules

## Automation

- Favor `Justfile` recipes over raw shell scripts for common tasks (installing, symlinking, cleaning).
- Always use the `--needed` flag for `pacman` and `--noconfirm` for automated AUR installs.

## Portability

- Maintain a clear separation between "CLI Core" (portable) and "Desktop UI" (Arch/HyDE specific).
- Ensure `.bashrc` or `.zshrc` does not break on headless servers when Wayland-specific aliases are missing.

## File Handling

- Use symbolic links (`ln -sf`) rather than copying files to ensure the Git repo remains the active source of truth.
- Use Pipe-Separated Values (.psv) only when specifically targeting HyDE restoration scripts.

## Suggestions

- Suggest better ways to manage dotfile configurations but always ensure to double check before applying any changes.
