#!/bin/bash
# Install Homebrew CLI tools
# Aurora-DX ships with Homebrew pre-installed

set -euo pipefail

# Ensure brew is on PATH (Aurora installs it but profile.d may not be sourced)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif ! command -v brew &> /dev/null; then
    echo "Homebrew not found, skipping"
    exit 0
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
brew install tmux direnv

# Editors
brew install neovim

# Container Tools
brew install lazydocker

# AI/Dev
brew install ollama

echo "Homebrew packages installed successfully"
