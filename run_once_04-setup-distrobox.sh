#!/bin/bash
# Create Distrobox development containers from distrobox.ini

set -euo pipefail

if ! command -v distrobox &> /dev/null; then
    echo "Distrobox not found, skipping"
    exit 0
fi

echo "Creating Distrobox containers..."
distrobox assemble create --file ~/.config/distrobox/distrobox.ini

echo "Distrobox containers created successfully"
echo ""
echo "To set up AUR access in the arch-dev container, run:"
echo "  distrobox enter arch-dev"
echo "  sudo pacman -Syu --noconfirm base-devel git"
echo "  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin"
echo "  cd /tmp/yay-bin && makepkg -si --noconfirm"
