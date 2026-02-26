# Schroder

Chezmoi dotfiles for a terminal-first developer workstation on [Fedora COSMIC Atomic](https://fedoraproject.org/atomic-desktops/cosmic/) (Immutable Fedora / COSMIC Desktop). Manages terminal, shell, dev tools, and COSMIC desktop config — themed with Dusklight across the entire stack.

## Hardware Target

- **CPU**: AMD Ryzen 9 9950X (16C/32T, AVX-512)
- **GPU**: NVIDIA RTX 5080 (Blackwell, dual NVENC AV1 encoders)
- **RAM**: 64GB DDR5-6000
- **Mobo**: ASUS ROG Strix X870E-E (PCIe 5.0)
- **Cooling**: Arctic Liquid Freezer III 360

## Quick Start

On a fresh Fedora COSMIC Atomic machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply drewelliott/schroder
```

This will:
1. Install Homebrew and CLI tools (ripgrep, fzf, neovim, starship, lazygit, ollama, etc.)
2. Install Mise and configure runtimes (Node, Python, Go, Rust)
3. Deploy Alacritty, tmux, bash, git, nvim (LazyVim) configs
4. Configure shell integrations (starship, zoxide, direnv, fzf, vi mode)
5. Deploy COSMIC desktop config (keybindings, global auto-tiling, panel, Dusklight theme)
6. Create Distrobox containers (fedora-dev, arch-dev, ai-dev)
7. Install Flatpak apps (OBS, Chrome, Spotify, Discord, Slack, Dropbox, KeePassXC)
8. Install Cousine Nerd Font

## What's Inside

### Dusklight Theme

A unified dark theme across all apps — deep navy background, orange accent, cyan text.

| App | Method |
|---|---|
| COSMIC | Dusklight.ron theme import |
| Alacritty | TOML color scheme |
| Neovim | Tokyonight with Dusklight color overrides |
| tmux | Status bar + pane border colors |

### Terminal Workflow

Alacritty terminal (no window decorations) with tmux (`C-Space` prefix, vi copy mode, `|`/`-` splits, auto-rename to cwd). Shift+Enter for Claude Code multi-line input.

```bash
t          # attach or start tmux
n          # open nvim in current directory
cx         # launch claude code
c          # launch opencode
```

### COSMIC Desktop

- Global auto-tiling (Super+G to float, Super+Y to toggle per-workspace)
- Omarchy-style keybindings (Super+Enter terminal, Super+Shift+B browser, Super+hjkl nav)
- Top panel only — no dock
- Dusklight theme colors

### Developer Tooling

| Layer | Tool | Purpose |
|---|---|---|
| Runtimes | Mise | Node, Python, Go, Rust version management |
| CLI tools | Homebrew | ripgrep, fd, bat, fzf, neovim, lazygit, etc. |
| Dotfiles | Chezmoi | Templated configs, bootstrap scripts |
| Containers | Distrobox | fedora-dev, arch-dev (AUR), ai-dev (GPU) |
| GUI apps | Flatpak | OBS, Chrome, Spotify, Discord, Slack, etc. |

### AI/ML
Ollama for local LLM inference on the RTX 5080 (16GB VRAM). GPU-enabled Distrobox container for vLLM, CrewAI, LangGraph, and other agent frameworks.

### Content Creation
OBS Studio via Flatpak with dual 9th-gen NVENC AV1 encoding (stream 1080p60 + record 4K60 simultaneously) and PipeWire screen capture.

## File Structure

```
.chezmoi.toml.tmpl              # Interactive setup (GPU, hostname)
dot_config/
  alacritty/alacritty.toml      # Terminal (Dusklight colors, no decorations)
  tmux/tmux.conf                # tmux (C-Space, sane splits, Dusklight status)
  bash/aliases                  # Shell aliases, vi mode, editor config
  nvim/                         # LazyVim config (tokyonight + Dusklight)
  cosmic/                       # COSMIC desktop (keybinds, tiling, panel, theme)
  autostart/                    # Dropbox autostart
  mise/config.toml.tmpl         # Runtime versions (templated)
  git/config                    # Git aliases + ergonomics
  distrobox/distrobox.ini.tmpl  # Container definitions (templated)
  starship.toml                 # Prompt config
run_once_01-install-mise.sh
run_once_02-install-brew-packages.sh
run_onchange_03-install-mise-tools.sh.tmpl
run_once_04-setup-distrobox.sh
run_once_05-setup-shell.sh
run_once_06-install-flatpaks.sh     # Includes permission overrides
run_once_07-install-nerd-fonts.sh
DAY-ZERO.md                    # Day Zero installation guide
```

## Day Zero Guide

See [DAY-ZERO.md](DAY-ZERO.md) for the step-by-step installation guide covering BIOS configuration, Fedora COSMIC Atomic installation, NVIDIA driver setup, and everything through to `chezmoi apply`.

## Key Differences from Omarchy

| | Omarchy | Schroder |
|---|---|---|
| **Base OS** | Arch Linux (rolling) | Fedora COSMIC Atomic (immutable) |
| **Desktop** | Hyprland (tiling WM) | COSMIC (tiling DE) |
| **Terminal** | Ghostty | Alacritty |
| **Theme** | Omarchy theme | Dusklight |
| **Packages** | pacman + AUR | Homebrew + Flatpak + Distrobox |
| **Updates** | `pacman -Syu` | `rpm-ostree upgrade` (atomic) |
| **Dotfiles** | Omarchy installer | Chezmoi (templated, multi-machine) |
| **Runtimes** | Mise | Mise |
| **Stability** | Rolling release | Image-based, rollback-capable |

## Credits

Terminal workflow adapted from [Omarchy](https://github.com/basecamp/omarchy) by DHH / Basecamp. Built on [Fedora COSMIC Atomic](https://fedoraproject.org/atomic-desktops/cosmic/) by the [Fedora Project](https://fedoraproject.org/). Dusklight theme from the COSMIC community.
