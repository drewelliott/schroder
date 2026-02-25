#!/bin/bash
# Configure shell integrations
# NOTE: Aurora's bling.sh already handles mise, zoxide, direnv, starship, and eza.
# We only add our custom aliases and tmux functions here.

set -euo pipefail

BASHRC=~/.bashrc

add_to_bashrc() {
    local marker="$1"
    local content="$2"
    if ! grep -qF "$marker" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "$content" >> "$BASHRC"
    fi
}

# Source Omarchy-style aliases and functions
add_to_bashrc "bash/aliases" '# Omarchy aliases and tmux functions
[ -f ~/.config/bash/aliases ] && source ~/.config/bash/aliases
[ -f ~/.config/bash/fns/tmux ] && source ~/.config/bash/fns/tmux'

echo "Shell integrations configured"
