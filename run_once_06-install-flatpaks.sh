#!/bin/bash
# Install Flatpak apps

set -euo pipefail

if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found, skipping"
    exit 0
fi

echo "Installing Flatpak apps..."

# Use --user to avoid polkit/system-helper permission issues during automated install
flatpak install --user -y --noninteractive flathub \
    com.obsproject.Studio \
    com.spotify.Client \
    com.dropbox.Client \
    org.keepassxc.KeePassXC \
    com.discordapp.Discord \
    com.slack.Slack \
    com.google.Chrome

# Remove Firefox if installed (check both system and user)
if flatpak list --app --columns=application | grep -q org.mozilla.firefox; then
    echo "Removing Firefox..."
    flatpak uninstall --user -y --noninteractive org.mozilla.firefox 2>/dev/null || true
fi

echo "Flatpak apps installed successfully"
