#!/bin/bash
# Install Homebrew and CLI tools

set -uo pipefail

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

# Install all packages in one call — brew skips already-installed ones
brew install \
    ripgrep fd fzf bat eza zoxide tree \
    lazygit gh git-delta pre-commit \
    btop dust duf procs \
    jq yq sd xh \
    tmux direnv starship \
    neovim \
    lazydocker \
    ollama \
    fastfetch

echo "Homebrew packages installed successfully"
