# Schroder

Chezmoi dotfiles for a terminal-first developer workstation on [Aurora-DX](https://getaurora.dev/) (Immutable Fedora / KDE Plasma). Manages terminal, shell, and dev tool configs — Plasma handles the desktop.

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
1. Deploy Ghostty, tmux, bash, and git configs
2. Install Mise and configure runtimes (Node, Python, Go, Rust)
3. Install CLI tools via Homebrew (ripgrep, fzf, neovim, lazygit, ollama, etc.)
4. Create Distrobox containers (fedora-dev, arch-dev, ai-dev)
5. Configure shell with Omarchy aliases and tmux functions

## What's Inside

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

### AI/ML
Ollama for local LLM inference on the RTX 5080 (16GB VRAM). GPU-enabled Distrobox container for vLLM, CrewAI, LangGraph, and other agent frameworks.

### Content Creation
OBS Studio via Flatpak with dual 9th-gen NVENC AV1 encoding (stream 1080p60 + record 4K60 simultaneously) and PipeWire screen capture.

## File Structure

```
.chezmoi.toml.tmpl          # Interactive setup (GPU, hostname)
dot_config/
  tmux/tmux.conf            # DHH's tmux config
  bash/aliases              # Omarchy shell aliases
  bash/fns/tmux             # tml/nic/nicx dev layout functions
  ghostty/config            # Terminal
  mise/config.toml.tmpl     # Runtime versions (templated)
  git/config                # Git aliases + ergonomics
  distrobox/distrobox.ini   # Container definitions
run_once_01-install-mise.sh
run_once_02-install-brew-packages.sh
run_onchange_03-install-mise-tools.sh.tmpl
run_once_04-setup-distrobox.sh
run_once_05-setup-shell.sh
AURORA-DAY-ZERO.md          # Day Zero installation guide
```

## Day Zero Guide

See [AURORA-DAY-ZERO.md](AURORA-DAY-ZERO.md) for the step-by-step installation guide covering BIOS configuration, Aurora-DX installation, NVIDIA driver verification, and everything through to `chezmoi apply`.

## Key Differences from Omarchy

| | Omarchy | Schroder |
|---|---|---|
| **Base OS** | Arch Linux (rolling) | Aurora-DX / Fedora Atomic (immutable) |
| **Desktop** | Hyprland (tiling WM) | KDE Plasma (Aurora default) |
| **Packages** | pacman + AUR | Homebrew + Flatpak + Distrobox |
| **Updates** | `pacman -Syu` | `rpm-ostree upgrade` (atomic) |
| **Dotfiles** | Omarchy installer | Chezmoi (templated, multi-machine) |
| **Runtimes** | Mise | Mise |
| **Stability** | Rolling release | Image-based, rollback-capable |

## Credits

Terminal workflow and configs adapted from [Omarchy](https://github.com/basecamp/omarchy) by DHH / Basecamp. Built on [Aurora-DX](https://getaurora.dev/) by the [Universal Blue](https://universal-blue.org/) project.
