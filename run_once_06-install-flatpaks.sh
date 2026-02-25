#!/bin/bash
# Install Flatpak apps

set -euo pipefail

if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found, skipping"
    exit 0
fi

echo "Installing Flatpak apps..."

flatpak install -y --noninteractive flathub \
    com.obsproject.Studio \
    com.spotify.Client \
    com.dropbox.Client \
    org.keepassxc.KeePassXC \
    com.discordapp.Discord \
    com.slack.Slack \
    com.google.Chrome

# Remove Firefox if installed
if flatpak list --app --columns=application | grep -q org.mozilla.firefox; then
    echo "Removing Firefox..."
    flatpak uninstall -y --noninteractive org.mozilla.firefox
fi

echo "Flatpak apps installed successfully"
