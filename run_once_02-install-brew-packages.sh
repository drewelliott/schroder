#!/bin/bash
# Install Homebrew and CLI tools

set -euo pipefail

# Ensure brew is on PATH or install it
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif command -v brew &> /dev/null; then
    : # brew already on PATH
else
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Installing Homebrew CLI tools..."

# File & Search
brew install ripgrep fd fzf bat eza zoxide tree

# Git & Dev
brew install lazygit gh git-delta pre-commit

# System & Monitoring
brew install btop dust duf procs

# Data & Text
brew install jq yq sd xh

# Shell & Terminal
brew install tmux direnv starship

# Editors
brew install neovim

# Container Tools
brew install lazydocker

# AI/Dev
brew install ollama

echo "Homebrew packages installed successfully"
