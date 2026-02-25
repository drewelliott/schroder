#!/bin/bash
# Install mise runtime manager if not present

set -euo pipefail

if command -v mise &> /dev/null; then
    echo "mise already installed, skipping"
    exit 0
fi

echo "Installing mise..."
curl https://mise.run | sh

# Add to shell profile if not already there
MISE_ACTIVATE='eval "$(~/.local/bin/mise activate bash)"'
if ! grep -qF "mise activate" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Mise runtime manager" >> ~/.bashrc
    echo "$MISE_ACTIVATE" >> ~/.bashrc
fi

echo "mise installed successfully"
