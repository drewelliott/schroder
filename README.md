# Schroder

Chezmoi dotfiles for a "Stable-Omarchy" workstation: the [Omarchy](https://omarchy.org/) (Arch/Hyprland) experience on an [Aurora-DX](https://getaurora.dev/) (Immutable Fedora) base, optimized for local LLM development and OBS content creation.

## Hardware Target

- **CPU**: AMD Ryzen 9 9950X (16C/32T, AVX-512)
- **GPU**: NVIDIA RTX 5080 (Blackwell, dual NVENC AV1 encoders)
- **RAM**: 64GB DDR5-6000
- **Mobo**: ASUS ROG Strix X870E-E (PCIe 5.0)
- **Cooling**: Arctic Liquid Freezer III 360

## Quick Start

On a fresh Aurora-DX NVIDIA machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply drewelliott/schroder
```

This will:
1. Deploy all Hyprland, Waybar, Ghostty, and tmux configs
2. Install Mise and configure runtimes (Node, Python, Go, Rust)
3. Install CLI tools via Homebrew (ripgrep, fzf, neovim, lazygit, ollama, etc.)
4. Create Distrobox containers (fedora-dev, arch-dev, ai-dev)
5. Configure shell with Omarchy aliases and tmux functions

## What's Inside

### Desktop Environment
Hyprland tiling compositor with Omarchy-style keybindings (tiling-v2), Waybar status bar, Wofi launcher, Dunst notifications, Hyprlock/Hypridle lock screen, and Catppuccin Mocha theming throughout.

### Terminal Workflow
Ghostty terminal with DHH's tmux config (`C-Space` prefix, vi copy mode, `Alt+N` window switching). Includes the `tml` dev layout that splits into editor (70%) + AI assistant (30%) + terminal (15%):

```bash
t          # attach or start tmux
nic        # editor + opencode + terminal
nicx       # editor + claude + terminal
nicm/nicxm # tml per subdirectory (monorepo workflow)
```

### Developer Tooling

| Layer | Tool | Purpose |
|---|---|---|
| Runtimes | Mise | Node, Python, Go, Rust version management |
| CLI tools | Homebrew | ripgrep, fd, bat, fzf, neovim, lazygit, etc. |
| Dotfiles | Chezmoi | Templated configs, bootstrap scripts |
| Containers | Distrobox | fedora-dev, arch-dev (AUR), ai-dev (GPU) |
| GUI apps | Flatpak | OBS, Chromium, Spotify, LibreOffice |
| System | rpm-ostree | keyd (macOS keybindings), Hyprland deps |

### AI/ML
Ollama for local LLM inference on the RTX 5080 (16GB VRAM). GPU-enabled Distrobox container for vLLM, CrewAI, LangGraph, and other agent frameworks.

### Content Creation
OBS Studio via Flatpak with dual 9th-gen NVENC AV1 encoding (stream 1080p60 + record 4K60 simultaneously) and PipeWire screen capture on Hyprland.

## File Structure

```
.chezmoi.toml.tmpl          # Interactive setup (GPU, monitor, hostname)
dot_config/
  hypr/                     # Hyprland + Hyprlock + Hypridle + Hyprpaper
  tmux/tmux.conf            # DHH's tmux config
  bash/aliases              # Omarchy shell aliases
  bash/fns/tmux             # tml/nic/nicx dev layout functions
  waybar/                   # Status bar config + Catppuccin theme
  wofi/                     # App launcher
  dunst/dunstrc             # Notifications
  ghostty/config            # Terminal
  starship.toml             # Prompt
  mise/config.toml.tmpl     # Runtime versions (templated)
  git/config                # Git aliases + ergonomics
  distrobox/distrobox.ini   # Container definitions
  xdg-desktop-portal/       # Screen sharing portal
private_dot_config/
  keyd/default.conf         # macOS-style key remapping
run_once_01-install-mise.sh
run_once_02-install-brew-packages.sh
run_onchange_03-install-mise-tools.sh.tmpl
run_once_04-setup-distrobox.sh
run_once_05-setup-shell.sh
STABLE-OMARCHY-GUIDE.md     # Full Day Zero installation guide
```

## Day Zero Guide

See [STABLE-OMARCHY-GUIDE.md](STABLE-OMARCHY-GUIDE.md) for the complete step-by-step installation guide covering BIOS configuration, Aurora-DX installation, NVIDIA driver verification, Hyprland setup, and everything through to `chezmoi apply`.

## Key Differences from Omarchy

| | Omarchy | Schroder |
|---|---|---|
| **Base OS** | Arch Linux (rolling) | Aurora-DX / Fedora Atomic (immutable) |
| **Packages** | pacman + AUR | Homebrew + Flatpak + Distrobox |
| **Updates** | `pacman -Syu` | `rpm-ostree upgrade` (atomic) |
| **Dotfiles** | Omarchy installer | Chezmoi (templated, multi-machine) |
| **Runtimes** | Mise | Mise |
| **Stability** | Rolling release | Image-based, rollback-capable |

## Credits

Desktop workflow and configs adapted from [Omarchy](https://github.com/basecamp/omarchy) by DHH / Basecamp. Built on [Aurora-DX](https://getaurora.dev/) by the [Universal Blue](https://universal-blue.org/) project.
