#!/bin/bash
# Install Flatpak apps

set -euo pipefail

if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found, skipping"
    exit 0
fi

echo "Installing Flatpak apps..."

# Ensure flathub remote is available for user installs
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install --user -y --noninteractive flathub \
    com.spotify.Client \
    com.dropbox.Client \
    org.keepassxc.KeePassXC \
    com.discordapp.Discord \
    com.slack.Slack \
    com.google.Chrome \
    md.obsidian.Obsidian \
    com.obsproject.Studio \
    com.obsproject.Studio.Plugin.DroidCam \
    com.obsproject.Studio.Plugin.MoveTransition

# Flatpak permission overrides
flatpak override --user --filesystem=home --talk-name=org.kde.StatusNotifierWatcher --talk-name=org.kde.StatusNotifierItem --talk-name=com.canonical.AppIndicator3 com.dropbox.Client
flatpak override --user --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.google.Chrome

# Set Chrome as default browser
xdg-settings set default-web-browser com.google.Chrome.desktop 2>/dev/null || true

echo "Flatpak apps installed successfully"
