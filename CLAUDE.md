# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Chezmoi dotfiles for a terminal-first developer workstation on Fedora COSMIC Atomic (immutable Fedora + COSMIC desktop). Manages shell, dev tools, Neovim, tmux, Alacritty, COSMIC desktop config, and bootstrap scripts — unified under the Dusklight theme (deep navy background, orange accent, cyan text).

## Chezmoi Conventions

Files map to `~` by replacing the `dot_` prefix with `.`. Chezmoi scripts run in order by filename:

- `run_once_*.sh` — runs once per machine (idempotent installs)
- `run_onchange_*.sh.tmpl` — reruns when content hash changes (e.g. mise config)

Template variables come from `.chezmoi.toml.tmpl` (interactive prompts on first `chezmoi init`):

- `.hostname` — machine hostname
- `.gpu` — `nvidia`, `amd`, or `intel`
- `.is_workstation` — boolean for AI/ML workstation extras

These variables gate GPU-specific config (e.g. `--gpus all` in distrobox, workstation-only mise tools).

## Bootstrap Order

Scripts run in numbered order on `chezmoi apply`:

1. `run_once_01-install-mise.sh` — installs mise runtime manager
2. `run_once_02-install-brew-packages.sh` — installs Homebrew + CLI tools
3. `run_onchange_03-install-mise-tools.sh.tmpl` — installs mise runtimes (reruns on config change)
4. `run_once_04-setup-distrobox.sh` — creates Distrobox containers (fedora-dev, arch-dev, ai-dev)
5. `run_once_05-setup-shell.sh` — configures shell integrations
6. `run_once_06-install-flatpaks.sh` — installs Flatpak apps with permission overrides
7. `run_once_07-install-nerd-fonts.sh` — installs Cousine Nerd Font

## Key Config Locations

| File | Purpose |
|---|---|
| `dot_config/bash/aliases` | Shell aliases, vi mode, editor vars, zoxide cd wrapper |
| `dot_config/mise/config.toml.tmpl` | Mise runtimes (Node 22, Python 3.12, Go 1.23, Rust stable) |
| `dot_config/distrobox/distrobox.ini.tmpl` | Container definitions (ai-dev gets `--gpus all` on nvidia) |
| `dot_config/nvim/` | LazyVim config with Dusklight color overrides |
| `dot_config/tmux/tmux.conf` | `C-Space` prefix, `\|`/`-` splits, vi copy mode |
| `dot_config/cosmic/` | COSMIC keybindings, tiling, panel, theme |
| `dot_config/alacritty/alacritty.toml` | Terminal colors (Dusklight), no window decorations |
| `.chezmoiignore` | Excludes README.md, LICENSE, DAY-ZERO.md, .github/ from dotfile deployment |

## Working on This Repo

To test changes locally:

```bash
chezmoi apply          # Apply all dotfiles + run eligible scripts
chezmoi diff           # Preview what would change
chezmoi apply --dry-run  # Dry run without making changes
```

To apply a specific file without running scripts:

```bash
chezmoi apply ~/.config/alacritty/alacritty.toml
```

To re-run a `run_once` script manually (chezmoi won't re-run it automatically):

```bash
bash run_once_02-install-brew-packages.sh
```

## Fedora COSMIC Atomic Notes

The OS is immutable — system packages are layered via `rpm-ostree install` and require a reboot. Homebrew and Flatpak are the primary package managers for user-space tools.

The `docker group` workaround in DAY-ZERO.md is intentional: `usermod -aG docker $USER` silently fails on atomic Fedora because `/usr/lib/group` is read-only; the group entry must be appended to `/etc/group` manually.

`DBX_CONTAINER_MANAGER=docker` is set in `dot_config/bash/aliases` because containerlab requires Docker (not Podman, which ships by default).
