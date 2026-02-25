#!/bin/bash
# Configure shell integrations (Omarchy-style)

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

# Mise runtime manager
add_to_bashrc "mise activate" '# Mise runtime manager
eval "$(mise activate bash)"'

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

# Source Omarchy-style aliases and functions
add_to_bashrc "bash/aliases" '# Omarchy aliases and tmux functions
[ -f ~/.config/bash/aliases ] && source ~/.config/bash/aliases
[ -f ~/.config/bash/fns/tmux ] && source ~/.config/bash/fns/tmux'

echo "Shell integrations configured"
