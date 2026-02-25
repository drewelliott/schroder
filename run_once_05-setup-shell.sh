#!/bin/bash
# Configure shell integrations

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

# Starship prompt
add_to_bashrc "starship init" '# Starship prompt
eval "$(starship init bash)"'

# Zoxide (smart cd)
add_to_bashrc "zoxide init" '# Zoxide smart cd
eval "$(zoxide init bash)"'

# Direnv
add_to_bashrc "direnv hook" '# Direnv per-directory env
eval "$(direnv hook bash)"'

# fzf
add_to_bashrc "fzf --bash" '# fzf keybindings and completion
eval "$(fzf --bash)"'

# Common aliases
add_to_bashrc "# Stable-Omarchy aliases" '# Stable-Omarchy aliases
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza --tree --icons --level=2"
alias cat="bat --paging=never"
alias grep="rg"
alias find="fd"
alias top="btop"
alias lg="lazygit"
alias ld="lazydocker"
alias db="distrobox"'

echo "Shell integrations configured"
