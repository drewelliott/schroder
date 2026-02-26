#!/bin/bash
# Configure shell integrations
# Adds tool activations and custom aliases/functions to bashrc

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

# Homebrew shellenv (must come first so tools are on PATH)
add_to_bashrc "linuxbrew" '# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

# Starship prompt
add_to_bashrc "starship init" '# Starship prompt
eval "$(starship init bash)"'

# Zoxide (smart cd)
add_to_bashrc "zoxide init" '# Zoxide
eval "$(zoxide init bash)"'

# Direnv (per-directory env)
add_to_bashrc "direnv hook" '# Direnv
eval "$(direnv hook bash)"'

# fzf key bindings and completion
add_to_bashrc "fzf --bash" '# fzf
eval "$(fzf --bash)"'

# Source aliases
add_to_bashrc "bash/aliases" '# Aliases
[ -f ~/.config/bash/aliases ] && source ~/.config/bash/aliases'

echo "Shell integrations configured"
