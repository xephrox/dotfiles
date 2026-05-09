#!/usr/bin/env bash
set -e

# ── Configuration ─────────────────────────────────────────────────────────────
# Update DOTFILES_REPO before running this script.
# Can be run on a fresh Arch install via:
#   curl -sS https://raw.githubusercontent.com/xephrox/dotfiles/main/install-arch.sh | bash

DOTFILES_REPO="https://github.com/xephrox/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
HYDE_DIR="$HOME/HyDE"

# ── Helpers ───────────────────────────────────────────────────────────────────
info() { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
prompt() {
	echo
	echo "────────────────────────────────────────────────────"
	echo "  $*"
	echo "────────────────────────────────────────────────────"
	echo
}

# ── Step 1: Git ───────────────────────────────────────────────────────────────
prompt "Step 1/5 — Installing git"
sudo pacman -S --needed git
success "git ready"

# ── Step 2: Clone dotfiles ────────────────────────────────────────────────────
prompt "Step 2/5 — Cloning dotfiles"
if [ -d "$DOTFILES_DIR/.git" ]; then
	info "Dotfiles already present at $DOTFILES_DIR — pulling latest"
	git -C "$DOTFILES_DIR" pull
else
	git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
	success "Dotfiles cloned to $DOTFILES_DIR"
fi

# ── Step 3: HyDE ─────────────────────────────────────────────────────────────
prompt "Step 3/5 — HyDE install (interactive — follow the prompts)"
if [ -d "$HYDE_DIR/.git" ]; then
	info "HyDE already present at $HYDE_DIR — pulling latest"
	git -C "$HYDE_DIR" pull
else
	git clone --depth 1 https://github.com/HyDE-Project/HyDE "$HYDE_DIR"
	success "HyDE cloned to $HYDE_DIR"
fi

info "Copying pkg_user.lst and pkg_black.lst to HyDE Scripts"
cp "$DOTFILES_DIR/hyde/pkg_user.lst" "$HYDE_DIR/Scripts/pkg_user.lst"
cp "$DOTFILES_DIR/hyde/pkg_black.lst" "$HYDE_DIR/Scripts/pkg_black.lst"

info "Starting HyDE installer"
bash "$HYDE_DIR/Scripts/install.sh"

info "Setting fish as default login shell"
chsh -s /usr/bin/fish "$USER"

# ── Step 4: just ─────────────────────────────────────────────────────────────
prompt "Step 4/5 — Installing just"
sudo pacman -S --needed just
success "just ready"

# ── Step 5: Symlink configs ───────────────────────────────────────────────────
prompt "Step 5/5 — Symlinking dotfile configurations"
just --justfile "$DOTFILES_DIR/justfile" setup-arch
success "All configs symlinked"

# ── Done ──────────────────────────────────────────────────────────────────────
echo
echo "════════════════════════════════════════════════════"
echo "  Install complete. Reboot to start your session."
echo "  Dotfiles: $DOTFILES_DIR"
echo "  Run 'just status' any time to check symlink state."
echo "════════════════════════════════════════════════════"
echo
