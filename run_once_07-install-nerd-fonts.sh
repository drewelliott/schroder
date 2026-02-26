#!/bin/bash
# Install Nerd Fonts for terminal (Alacritty, Ghostty)

set -uo pipefail

FONT_DIR="${HOME}/.local/share/fonts"
mkdir -p "$FONT_DIR"

echo "Installing Cousine Nerd Font..."
curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Cousine.tar.xz \
    | tar -xJf - -C "$FONT_DIR"

fc-cache -f "$FONT_DIR"

echo "Nerd fonts installed successfully"
