# Day Zero: Fedora COSMIC Atomic Installation Guide

> Fedora COSMIC Atomic (Immutable Fedora / COSMIC Desktop) + Terminal Dev Toolkit
>
> **Hardware**: AMD Ryzen 9 9950X | NVIDIA RTX 5080 | 64GB DDR5-6000 | ASUS ROG Strix X870E-E

---

## Phase 0: BIOS/UEFI Configuration

Enter BIOS on the ASUS ROG Strix X870E-E by pressing **Delete** during POST.

### Key Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| IOMMU | **Enabled** | Required for VFIO/GPU passthrough |
| ACS Enable | **Enabled** | IOMMU group isolation |
| SVM | **Enabled** | AMD-V hardware virtualization |
| NX Mode | **Enabled** | No-Execute bit, required by KVM |
| EXPO Profile | **EXPO I** | Enable rated DDR5-6000 speed |
| Above 4G Decoding | **Enabled** | Required for Resizable BAR |
| Resizable BAR | **Enabled** | Full CPU access to GPU VRAM |
| Secure Boot | **Enabled** | Required for NVIDIA signed modules |
| TPM | **Enabled (fTPM)** | AMD firmware TPM for disk encryption |
| CSM | **Disabled** | Pure UEFI mode |
| PBO | **Enabled** | Better boost on 9950X |

> DDR5-6000 is the sweet spot for Ryzen 9000. Going above 6000 forces a 1:2 ratio (FCLK:UCLK), *increasing* latency.

---

## Phase 1: Install Fedora COSMIC Atomic

### Download & Flash

Download from [fedoraproject.org/atomic-desktops/cosmic](https://fedoraproject.org/atomic-desktops/cosmic/download/).

```bash
sudo dd if=Fedora-COSMIC-Atomic-ostree-x86_64-43-1.6.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Install

1. Boot from USB (F8 on ROG Strix for boot menu)
2. Follow the Anaconda installer — btrfs recommended for root (snapshot support)
3. **Leave Root Account disabled**

---

## Phase 2: First Boot & System Packages

### Layer Required Packages

```bash
# Alacritty terminal, Distrobox containers, build tools for nvim treesitter
sudo rpm-ostree install alacritty distrobox gcc gcc-c++ tree-sitter-cli

# Remove Firefox from base image (Chrome installed via Flatpak)
sudo rpm-ostree override remove firefox firefox-langpacks

systemctl reboot
```

### Install Docker CE

Containerlab (and other networking tools) require Docker. Podman ships with Fedora but is not compatible.

```bash
# Add Docker CE repo
sudo tee /etc/yum.repos.d/docker-ce.repo << 'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/fedora/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF

# Layer Docker CE packages
sudo rpm-ostree install docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl reboot

# Enable Docker and add your user to the docker group
# NOTE: usermod silently fails on atomic Fedora because the docker group
# lives in /usr/lib/group (image layer), not /etc/group. Add it manually.
sudo systemctl enable --now docker
sudo sh -c "echo docker:x:$(getent group docker | cut -d: -f3):$USER >> /etc/group"
newgrp docker

# Verify
docker run --rm hello-world
```

### Install Containerlab

Network emulation tool for building virtual network topologies with real NOS containers. Installed as a layered RPM for self-update support (`sudo containerlab version upgrade`).

```bash
# Get latest version from GitHub releases
CLAB_VERSION=$(curl -sL https://github.com/srl-labs/containerlab/releases/latest -o /dev/null -w '%{url_effective}' | grep -oP 'v\K[^/]+')

# Layer the RPM
sudo rpm-ostree install https://github.com/srl-labs/containerlab/releases/download/v${CLAB_VERSION}/containerlab_${CLAB_VERSION}_linux_amd64.rpm
systemctl reboot

# Verify
containerlab version
```

### NVIDIA Drivers (GPU machines only)

Skip this on AMD-only machines (e.g. NucBox K8 Plus). For NVIDIA with Secure Boot:

```bash
# Enable RPM Fusion repos (replace 43 with your Fedora version)
sudo rpm-ostree install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-43.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-43.noarch.rpm
systemctl reboot

# Install NVIDIA driver packages and build tools
sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda
systemctl reboot

# Sign kernel modules for Secure Boot (MOK enrollment)
# Generate signing key (skip if already exists)
sudo kmodgenca

# Import key into MOK — set a one-time password you'll enter at next boot
sudo mokutil --import /etc/pki/akmods/certs/public_key.der

# Reboot — MOK Manager (blue screen) will appear:
# Select: Enroll MOK > Continue > Yes > enter password > Reboot
systemctl reboot

# Build signed kmod and install it
sudo akmods --force
# NOTE: akmods install step fails on atomic (no dnf/yum), install the RPM manually:
sudo rpm-ostree install /var/cache/akmods/nvidia/*-$(uname -r)-*.rpm
# Remove akmod-nvidia (its unsigned modules conflict with the signed kmod)
sudo rpm-ostree uninstall akmod-nvidia

# Blacklist nouveau so nvidia can claim the GPU
sudo tee /etc/modprobe.d/blacklist-nouveau.conf << 'EOF'
blacklist nouveau
options nouveau modeset=0
EOF
sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau
systemctl reboot

# Verify
nvidia-smi
```

### GlobalProtect VPN (if needed)

```bash
curl -O https://d2hvyxt0t758wb.cloudfront.net/gp_install_files/GlobalProtect_rpm-6.3.3.1-616.rpm
sudo rpm-ostree install ./GlobalProtect_rpm-6.3.3.1-616.rpm
systemctl reboot
```

---

## Phase 3: Apply Dotfiles

### Pre-seed Config (optional, skips interactive prompts)

```bash
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[data]
    hostname = "schroder"
    gpu = "amd"
    is_workstation = false
EOF
```

### Run Chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply drewelliott/schroder
```

This will:
1. Install Homebrew and CLI tools (ripgrep, fzf, neovim, starship, lazygit, ollama, etc.)
2. Install Mise and configure runtimes (Node, Python, Go, Rust)
3. Deploy Alacritty, tmux, bash, git, nvim (LazyVim) configs
4. Configure shell integrations (starship, zoxide, direnv, fzf, vi mode)
5. Deploy COSMIC desktop config (keybindings, global auto-tiling, panel, Dusklight theme)
6. Create Distrobox containers via Docker (fedora-dev, arch-dev, ai-dev)
7. Install Flatpak apps with permission overrides (OBS, Chrome, Spotify, Discord, Slack, Dropbox, KeePassXC)
8. Install Cousine Nerd Font

### Post-Apply

```bash
# Trust mise config
mise trust

# Import Dusklight theme: COSMIC Settings > Appearance > Import Theme
# Select ~/.config/cosmic/themes/Dusklight.ron

# Log out and back in for COSMIC config to take effect (keybindings, tiling, panel)
```

---

## Keybindings (Omarchy-style)

| Shortcut | Action |
|---|---|
| Super + Enter | Alacritty terminal |
| Super + T | Alacritty (system terminal) |
| Super + Shift + B | Web browser |
| Super + Shift + N | Neovim |
| Super + Shift + D | Lazydocker |
| Super + Shift + M | Spotify |
| Super + W | Close window |
| Super + / | Launcher |
| Super + A | App library |
| Super + hjkl | Focus navigation (vim-style) |
| Super + Shift + hjkl | Move windows |
| Super + 1-9 | Switch workspace |
| Super + Shift + 1-9 | Move window to workspace |
| Super + G | Toggle floating/tiling |
| Super + Y | Toggle tiling for workspace |
| Super + M | Maximize |
| Super + F11 | Fullscreen |
| Super + drag | Move floating window |
| Super + right-drag | Resize floating window |

---

## Shell Aliases

| Alias | Command |
|---|---|
| `t` | Attach or start tmux session |
| `n` / `n <file>` | Open nvim (defaults to current dir) |
| `cx` | Launch Claude Code |
| `c` | Launch OpenCode |
| `ff` | fzf with bat preview |
| `eff` | Open fzf result in $EDITOR |
| `ls` / `lsa` | eza with icons |
| `lt` / `lta` | eza tree view |
| `g` | git |
| `d` | docker |
| `k` | kubectl |

---

## Day Zero Checklist

```
[ ] Configure BIOS (IOMMU, SVM, EXPO, ReBAR, Secure Boot)
[ ] Install Fedora COSMIC Atomic from ISO
[ ] Layer packages: alacritty, distrobox, gcc, gcc-c++, tree-sitter-cli
[ ] Override remove firefox and firefox-langpacks
[ ] Install Docker CE (add repo, rpm-ostree install, enable service, add to docker group)
[ ] Install Containerlab (RPM from GitHub releases)
[ ] NVIDIA drivers if applicable (RPM Fusion akmod-nvidia + MOK signing for Secure Boot)
[ ] GlobalProtect VPN if needed
[ ] Pre-seed chezmoi config (optional)
[ ] Run chezmoi init --apply drewelliott/schroder
[ ] Run mise trust
[ ] Import Dusklight theme in COSMIC Settings
[ ] Log out / log in for COSMIC config
[ ] Verify: alacritty, nvim, tmux themed correctly
[ ] Verify: tiling works, keybindings work
[ ] Verify: Flatpak apps (OBS, Chrome, Spotify, Discord, Slack, Dropbox)
[ ] Verify: mise install, ollama serve, distrobox list
```

---

## Sources

- [Fedora COSMIC Atomic](https://fedoraproject.org/atomic-desktops/cosmic/) | [COSMIC Desktop](https://system76.com/cosmic)
- [Omarchy](https://omarchy.org/) | [GitHub](https://github.com/basecamp/omarchy)
- [RPM Fusion NVIDIA Howto](https://rpmfusion.org/Howto/NVIDIA)
- [Mise Runtime Manager](https://mise.jdx.dev/)
- [Chezmoi Dotfile Manager](https://www.chezmoi.io/)
