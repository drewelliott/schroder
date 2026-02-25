# Aurora Day Zero: Installation Guide

> Aurora-DX (Immutable Fedora / KDE Plasma) + NVIDIA + Terminal Dev Toolkit
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
| Secure Boot | **Enabled** | Aurora handles NVIDIA signing via MOK |
| TPM | **Enabled (fTPM)** | AMD firmware TPM for disk encryption |
| CSM | **Disabled** | Pure UEFI mode |
| PBO | **Enabled** | Better boost on 9950X |

> DDR5-6000 is the sweet spot for Ryzen 9000. Going above 6000 forces a 1:2 ratio (FCLK:UCLK), *increasing* latency.

---

## Phase 1: Install Aurora

### Download & Flash

Download from [getaurora.dev](https://getaurora.dev). Select the **NVIDIA** variant (`aurora-nvidia-open-stable-webui-x86_64.iso`). There is no separate "DX" ISO — developer mode is enabled post-install.

```bash
sudo dd if=aurora-nvidia-open-stable-webui-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

> **Warning**: Ventoy is **not supported** by Aurora.

### Install

1. Boot from USB (F8 on ROG Strix for boot menu)
2. Follow the installer — btrfs recommended for root (snapshot support)
3. **Leave Root Account disabled** (Aurora requirement)

### Pin Image Version

After first boot, pin to a stable stream (never use `:latest`):

```bash
rpm-ostree status
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/aurora-nvidia-open:stable
```

---

## Phase 2: First Boot & NVIDIA Verification

### Enroll Secure Boot Key

Universal Blue pre-signs NVIDIA kernel modules with their own MOK. If you missed the installer prompt:

```bash
ujust enroll-secure-boot-key
# MOK password: universalblue
```

### Verify NVIDIA Drivers

```bash
# Check driver version (needs 570.86.16+ for RTX 5080 Blackwell)
nvidia-smi

# Verify open kernel modules (required for Blackwell)
cat /proc/driver/nvidia/version
# Should reference "Open" kernel module
```

### Enable Developer Mode

```bash
ujust devmode
systemctl reboot

# Add yourself to developer groups
ujust dx-group
# Log out and back in for group changes
```

Developer mode adds: Docker, Podman, Distrobox, Homebrew, Mise, virt-manager, VS Code with Dev Containers, and more.

---

## Phase 3: Apply Dotfiles

```bash
# One-liner to bootstrap everything
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply drewelliott/schroder
```

This will:
1. Install Chezmoi and clone the dotfiles repo
2. Prompt for machine-specific values (hostname, GPU vendor, workstation flag)
3. Deploy Ghostty, tmux, bash, git, and mise configs
4. Run bootstrap scripts: install Mise, Homebrew CLI tools, Distrobox containers, shell setup

### Flatpak Apps (Manual)

```bash
flatpak install flathub com.obsproject.Studio
flatpak install flathub org.chromium.Chromium
flatpak install flathub com.spotify.Client
flatpak install flathub org.libreoffice.LibreOffice
```

---

## Day Zero Checklist

```
[ ] Configure BIOS (IOMMU, SVM, EXPO, ReBAR, Secure Boot)
[ ] Install Aurora NVIDIA from ISO
[ ] Pin image to :stable (not :latest)
[ ] Enroll Secure Boot MOK key (password: universalblue)
[ ] Verify NVIDIA driver (570.86.16+, open kernel modules)
[ ] Enable developer mode (ujust devmode + ujust dx-group)
[ ] Run chezmoi init --apply drewelliott/schroder
[ ] Install Flatpak apps (OBS, Chromium, Spotify)
[ ] Verify: mise install, ollama serve, distrobox list
```

---

## Sources

- [Aurora-DX](https://getaurora.dev/) | [Universal Blue](https://universal-blue.org/)
- [Omarchy](https://omarchy.org/) | [GitHub](https://github.com/basecamp/omarchy)
- [NVIDIA 570.86.16 Linux Driver (RTX 5080)](https://www.phoronix.com/news/NVIDIA-570.86.16-Linux-Driver)
- [Mise Runtime Manager](https://mise.jdx.dev/)
- [Chezmoi Dotfile Manager](https://www.chezmoi.io/)
