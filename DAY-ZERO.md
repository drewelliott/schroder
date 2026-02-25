# Day Zero: Fedora COSMIC Atomic Installation Guide

> Fedora COSMIC Atomic (Immutable Fedora / COSMIC Desktop) + NVIDIA + Terminal Dev Toolkit
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

## Phase 2: First Boot & NVIDIA Setup

### Install NVIDIA Drivers

Fedora COSMIC Atomic ships with nouveau by default. Install the RPM Fusion NVIDIA drivers:

```bash
# Enable RPM Fusion repos
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
systemctl reboot

# Install NVIDIA drivers (open kernel modules for RTX 5080)
sudo rpm-ostree install akmod-nvidia-open xorg-x11-drv-nvidia-cuda
systemctl reboot

# Verify
nvidia-smi
```

### Install Distrobox

```bash
sudo rpm-ostree install distrobox
systemctl reboot
```

---

## Phase 3: Apply Dotfiles

```bash
# One-liner to bootstrap everything
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply drewelliott/schroder
```

This will:
1. Install Chezmoi and clone the dotfiles repo
2. Prompt for machine-specific values (hostname, GPU vendor, workstation flag)
3. Install Homebrew and CLI tools (ripgrep, fzf, neovim, starship, lazygit, etc.)
4. Install Mise and configure runtimes (Node, Python, Go, Rust)
5. Deploy Ghostty, tmux, bash, git configs
6. Configure shell integrations (starship, zoxide, direnv, fzf)
7. Create Distrobox containers (fedora-dev, arch-dev, ai-dev)
8. Install Flatpak apps (OBS, Chrome, Spotify, Discord, Slack, Dropbox, KeePassXC)

---

## Day Zero Checklist

```
[ ] Configure BIOS (IOMMU, SVM, EXPO, ReBAR, Secure Boot)
[ ] Install Fedora COSMIC Atomic from ISO
[ ] Install NVIDIA drivers (RPM Fusion akmod-nvidia-open)
[ ] Verify NVIDIA driver (nvidia-smi)
[ ] Install Distrobox (rpm-ostree install distrobox)
[ ] Run chezmoi init --apply drewelliott/schroder
[ ] Verify Flatpak apps installed (OBS, Chrome, Spotify, Discord, Slack)
[ ] Verify: mise install, ollama serve, distrobox list
```

---

## Sources

- [Fedora COSMIC Atomic](https://fedoraproject.org/atomic-desktops/cosmic/) | [COSMIC Desktop](https://system76.com/cosmic)
- [Omarchy](https://omarchy.org/) | [GitHub](https://github.com/basecamp/omarchy)
- [RPM Fusion NVIDIA Howto](https://rpmfusion.org/Howto/NVIDIA)
- [Mise Runtime Manager](https://mise.jdx.dev/)
- [Chezmoi Dotfile Manager](https://www.chezmoi.io/)
