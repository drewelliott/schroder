# Stable-Omarchy: Day Zero Installation Guide

> Aurora-DX (Immutable Fedora) + Hyprland + Local LLM Development + OBS Content Creation
>
> **Hardware**: AMD Ryzen 9 9950X | NVIDIA RTX 5080 | 64GB DDR5-6000 | ASUS ROG Strix X870E-E

---

## Table of Contents

1. [Phase 0: BIOS/UEFI Configuration](#phase-0-biosuefi-configuration)
2. [Phase 1: Base OS Installation](#phase-1-base-os-installation)
3. [Phase 2: First Boot & NVIDIA Verification](#phase-2-first-boot--nvidia-verification)
4. [Phase 3: Hyprland Desktop Environment](#phase-3-hyprland-desktop-environment)
5. [Phase 4: System-Level Services (rpm-ostree)](#phase-4-system-level-services-rpm-ostree)
6. [Phase 5: DevOps Tooling (Mise + Homebrew + Chezmoi)](#phase-5-devops-tooling)
7. [Phase 6: Distrobox Development Containers](#phase-6-distrobox-development-containers)
8. [Phase 7: AI/ML & Local LLM Playground](#phase-7-aiml--local-llm-playground)
9. [Phase 8: OBS Content Pipeline](#phase-8-obs-content-pipeline)
10. [Phase 9: KVM/QEMU Virtualization](#phase-9-kvmqemu-virtualization)
11. [Phase 10: Chezmoi Final Apply & Dotfile Structure](#phase-10-chezmoi-final-apply--dotfile-structure)
12. [Appendix: Omarchy Component Mapping](#appendix-omarchy-component-mapping)

---

## Phase 0: BIOS/UEFI Configuration

Enter BIOS on the ASUS ROG Strix X870E-E by pressing **Delete** during POST.

### Virtualization & IOMMU

Navigate to **Advanced > AMD CBS > NBIO Common Options**:

| Setting | Value | Purpose |
|---------|-------|---------|
| IOMMU | **Enabled** | Required for VFIO/GPU passthrough |
| ACS Enable | **Enabled** | Improves IOMMU group isolation |
| SVM (Secure Virtual Machine) | **Enabled** | AMD-V hardware virtualization |
| NX Mode | **Enabled** | No-Execute bit, required by KVM |

### Memory (DDR5-6000)

Navigate to **AI Tweaker** (or **Extreme Tweaker**):

| Setting | Value | Purpose |
|---------|-------|---------|
| EXPO Profile | **EXPO I** | Enable rated DDR5-6000 speed |
| Memory Frequency | **6000 MHz** | Sweet spot for Zen 5 (1:1 IF ratio) |
| FCLK | **Auto** or **2000 MHz** | Maintains 1:1 FCLK:MCLK ratio |

> **Critical**: DDR5-6000 is the sweet spot for Ryzen 9000. Going above 6000 forces a 1:2 ratio (FCLK:UCLK), *increasing* latency. If your kit is rated higher (e.g. 6400), manually set to 6000 for optimal performance.

### PCIe & GPU

Navigate to **Advanced > PCI Subsystem Settings**:

| Setting | Value | Purpose |
|---------|-------|---------|
| Above 4G Decoding | **Enabled** | Required for Resizable BAR |
| Resizable BAR Support | **Enabled** | Full CPU access to GPU VRAM |
| SR-IOV Support | **Enabled** | GPU virtualization features |
| Primary GPU PCIe Slot | **Gen 5** or **Auto** | RTX 5080 supports PCIe 5.0 x16 |

### Boot & Security

| Setting | Value | Purpose |
|---------|-------|---------|
| Secure Boot | **Enabled** | Aurora handles NVIDIA signing via MOK |
| TPM | **Enabled (fTPM)** | AMD firmware TPM for disk encryption |
| CSM | **Disabled** | Pure UEFI mode (required for Secure Boot) |
| Fast Boot | **Disabled** (initially) | Easier BIOS access during setup |

### Performance Tuning

| Setting | Value | Purpose |
|---------|-------|---------|
| PBO (Precision Boost Overdrive) | **Enabled / Advanced** | Better boost on 9950X |
| SMT | **Enabled** | Full 16C/32T operation |
| ErP Ready | **Enabled** | Lower standby power |

> PCIe Gen 5 stability note: If you experience instability, set the GPU slot to Gen 4 as a troubleshooting step. Gen 5 should work on recent BIOS revisions.

---

## Phase 1: Base OS Installation

### Choosing Your Image Strategy

There are two paths to get Hyprland on Aurora-DX. Choose one:

#### Option A: Aurora-DX Base + Custom Hyprland Image (Recommended)

Start with Aurora-DX NVIDIA as the base, then rebase to a custom image that adds Hyprland. This gives you the full Aurora-DX developer tooling (Homebrew, Distrobox, ujust recipes) plus Hyprland.

#### Option B: Community Hyprland-Atomic Image

Use a pre-built community image like [hyprland-atomic](https://github.com/cjuniorfox/hyprland-atomic) which provides Hyprland on Fedora Atomic out of the box.

### Step 1: Download Aurora-DX NVIDIA ISO

Download from [getaurora.dev](https://getaurora.dev). Select:
- **Aurora-DX** (developer variant)
- **NVIDIA** variant

### Step 2: Create Bootable USB

```bash
# On an existing Linux/macOS machine
sudo dd if=aurora-dx-nvidia-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Or use [Ventoy](https://www.ventoy.net/) / [Fedora Media Writer](https://flathub.org/apps/org.fedoraproject.MediaWriter).

### Step 3: Install

1. Boot from USB (F8 on ROG Strix for boot menu)
2. Follow the Anaconda installer
3. **Partitioning recommendation**:
   - `/boot/efi` - 512MB EFI System Partition
   - `/boot` - 1GB ext4
   - `/` - Remainder (btrfs recommended for snapshots)
4. Set hostname, create user, set root password
5. Complete installation and reboot

### Step 4: Pin Image Version

After first boot, verify and pin to a specific Fedora version tag (never use `latest`):

```bash
# Check current image
rpm-ostree status

# If on :latest, rebase to a pinned version (e.g., Fedora 42)
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/aurora-dx-nvidia:42
```

> **Important**: Per project policy, we cannot use "latest" tags. Always pin to a specific Fedora version number (`:41`, `:42`, etc.).

---

## Phase 2: First Boot & NVIDIA Verification

### Enroll Secure Boot Key

Universal Blue pre-signs NVIDIA kernel modules with their own MOK. Enroll it:

```bash
ujust enroll-secure-boot-key
```

Reboot. The MOK Manager (shim) will appear:
1. Select "Enroll MOK"
2. Enter the password shown during enrollment
3. Confirm and reboot

### Verify NVIDIA Drivers

```bash
# Check driver version (needs 570.86.16+ for RTX 5080 Blackwell)
nvidia-smi

# Verify open kernel modules are loaded (required for Blackwell)
lsmod | grep nvidia
# Should show nvidia, nvidia_modeset, nvidia_uvm, nvidia_drm
# These MUST be the open kernel modules -- Blackwell does NOT support proprietary modules

# Test CUDA
nvidia-smi -L
```

> **Critical RTX 5080 Requirement**: Blackwell GPUs **require** NVIDIA open kernel modules. The proprietary driver is not supported. Verify with:
> ```bash
> cat /proc/driver/nvidia/version
> # Should reference "Open" kernel module
> ```

### Run Aurora-DX Setup Recipes

```bash
# List all available ujust recipes
ujust --list

# NVIDIA verification
ujust nvidia-test

# Set up virtualization (KVM/QEMU/libvirt)
ujust setup-virtualization

# Set up Docker (if you prefer Docker over Podman)
ujust setup-docker
```

---

## Phase 3: Hyprland Desktop Environment

### Strategy: Rebase to a Hyprland Image

The cleanest approach on Fedora Atomic is to rebase to an image that includes Hyprland at build time, rather than layering packages via rpm-ostree.

#### Option A: Use hyprland-atomic (Community Image)

The [hyprland-atomic](https://github.com/cjuniorfox/hyprland-atomic) project provides pre-built images:

```bash
# Rebase to hyprland-atomic (Solopasha variant with Fedora 43)
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/cjuniorfox/hyprland-atomic-solopasha:43

# Or the virtualization variant (includes libvirt/QEMU)
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/cjuniorfox/hyprland-atomic-solopasha-virt:43
```

> **Note**: This replaces the Aurora-DX base. You may lose some Aurora-DX-specific ujust recipes. Evaluate whether the community image meets your needs.

#### Option B: Build a Custom Image (Maximum Control)

Fork the [Universal Blue image template](https://github.com/ublue-os/image-template) and create a Containerfile that inherits from Aurora-DX NVIDIA and adds Hyprland:

```dockerfile
FROM ghcr.io/ublue-os/aurora-dx-nvidia:42

# Add Hyprland COPR (Solopasha's repo is well-maintained for Fedora)
RUN curl -Lo /etc/yum.repos.d/solopasha-hyprland.repo \
    https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-42/solopasha-hyprland-fedora-42.repo

# Install Hyprland and ecosystem
RUN rpm-ostree install \
    hyprland \
    hyprpaper \
    hyprlock \
    hypridle \
    hyprpicker \
    xdg-desktop-portal-hyprland \
    waybar \
    wofi \
    dunst \
    wl-clipboard \
    grim \
    slurp \
    swappy \
    polkit-gnome \
    && rpm-ostree cleanup -m

# Clean up
RUN rm -rf /var/cache/* /tmp/*
```

Build and push to a container registry (GitHub Container Registry works well), then rebase:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/YOUR_USER/stable-omarchy:42
```

#### Option C: Layer Hyprland via COPR (Simplest, Less Clean)

If you want to stay on the Aurora-DX base without rebasing:

```bash
# Add Solopasha's Hyprland COPR
sudo curl -Lo /etc/yum.repos.d/solopasha-hyprland.repo \
    "https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-$(rpm -E %fedora)/solopasha-hyprland-fedora-$(rpm -E %fedora).repo"

# Layer Hyprland packages
rpm-ostree install \
    hyprland hyprpaper hyprlock hypridle hyprpicker \
    xdg-desktop-portal-hyprland \
    waybar wofi dunst wl-clipboard \
    grim slurp swappy polkit-gnome

systemctl reboot
```

> **Warning**: Layering this many packages on an immutable base increases update fragility. Options A or B are preferred.

### Omarchy Component Mapping

These are the Omarchy (Arch/Hyprland) components and their Fedora equivalents:

| Omarchy Component | Role | Fedora/Aurora Equivalent |
|---|---|---|
| Hyprland | Tiling Wayland compositor | Hyprland (via COPR/custom image) |
| Waybar | Status bar | Waybar (via COPR/custom image) |
| Ghostty | Terminal emulator | Ghostty (Flatpak or Homebrew) |
| Neovim | Editor | `brew install neovim` |
| Wofi / Rofi-wayland | App launcher | Wofi (via COPR/custom image) |
| Hyprpaper | Wallpaper | Hyprpaper (via COPR/custom image) |
| Hyprlock | Lock screen | Hyprlock (via COPR/custom image) |
| Hypridle | Idle daemon | Hypridle (via COPR/custom image) |
| Dunst / Mako | Notifications | Dunst (via COPR/custom image) |
| Chromium | Browser | Chromium (Flatpak) |
| Spotify | Music | Spotify (Flatpak) |
| LibreOffice | Office suite | LibreOffice (Flatpak) |
| Mise | Runtime manager | `brew install mise` or `curl https://mise.run \| sh` |
| Docker | Containers | Podman (pre-installed) or Docker via `ujust setup-docker` |
| Lazydocker | Docker TUI | `brew install lazydocker` |
| GitHub CLI | Git operations | `brew install gh` |

### NVIDIA Environment Variables for Hyprland

Add to `~/.config/hypr/hyprland.conf`:

```ini
# NVIDIA-specific settings (required for RTX 5080)
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = NVD_BACKEND,direct

# Cursor fix for NVIDIA
env = WLR_NO_HARDWARE_CURSORS,1
# Or on newer Hyprland:
cursor {
    no_hardware_cursors = true
}

# Wayland-native hints
env = XDG_SESSION_TYPE,wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = MOZ_ENABLE_WAYLAND,1
```

### XDG Desktop Portal Configuration

Create `~/.config/xdg-desktop-portal/hyprland-portals.conf`:

```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=gtk
```

This is critical for screen sharing (OBS) and file dialogs to work correctly.

---

## Phase 4: System-Level Services (rpm-ostree)

Only layer packages that genuinely need kernel/system-level access. Everything else goes in Homebrew, Mise, Distrobox, or Flatpak.

### keyd (macOS-style Key Remapping)

```bash
# Install from COPR
sudo curl -Lo /etc/yum.repos.d/alternateved-keyd.repo \
    "https://copr.fedorainfracloud.org/coprs/alternateved/keyd/repo/fedora-$(rpm -E %fedora)/alternateved-keyd-fedora-$(rpm -E %fedora).repo"

rpm-ostree install keyd
systemctl reboot
```

After reboot, enable and configure:

```bash
sudo systemctl enable --now keyd
```

Create `/etc/keyd/default.conf`:

```ini
[ids]
*

[main]
# Swap left Alt and left Super for macOS-style shortcuts
leftalt = leftmeta
leftmeta = leftalt

[meta]
# macOS-style shortcuts (physical Alt key, now mapped to Meta)
c = C-c
v = C-v
x = C-x
a = C-a
z = C-z
s = C-s
w = C-w
t = C-t
f = C-f
q = C-q
tab = A-tab
space = A-space
```

### Recommended rpm-ostree Layers (Minimal)

```bash
# Only layer what MUST be at the system level
rpm-ostree install \
    keyd \
    libvirt-daemon-config-network \
    qemu-kvm \
    virt-manager

systemctl reboot
```

Everything else should go through Homebrew, Flatpak, Distrobox, or Mise.

---

## Phase 5: DevOps Tooling

### Installation Priority

| Layer | Tool | Purpose |
|---|---|---|
| Runtimes | **Mise** | Node, Python, Go, Rust, Java version management |
| CLI Utils | **Homebrew** | ripgrep, fd, bat, fzf, lazygit, neovim, etc. |
| Dotfiles | **Chezmoi** | Configuration management across machines |
| GUI Apps | **Flatpak** | Browsers, editors, media apps |
| Dev Environments | **Distrobox** | Full mutable Linux containers |
| System Services | **rpm-ostree** | Last resort (kernel modules, drivers) |

### Mise Setup

Mise replaces asdf, nvm, pyenv, rbenv, and goenv. It installs everything to `~/.local/share/mise/` (userspace, not touching the immutable root).

```bash
# Install Mise
curl https://mise.run | sh

# Or via Homebrew (Aurora-DX ships with brew)
brew install mise
```

Add to `~/.bashrc` or `~/.zshrc`:

```bash
eval "$(mise activate bash)"   # or zsh/fish
```

Create `~/.config/mise/config.toml`:

```toml
[tools]
node = "22"
python = "3.12"
go = "1.23"
rust = "stable"

[settings]
experimental = true
```

```bash
mise install  # Install all configured runtimes
```

### Homebrew CLI Tools

Aurora-DX ships with Homebrew pre-installed. Install the essential toolkit:

```bash
# File & Search
brew install ripgrep fd fzf bat eza zoxide tree

# Git & Dev
brew install lazygit gh git-delta pre-commit

# System & Monitoring
brew install btop dust duf procs

# Data & Text
brew install jq yq sd xh

# Shell & Terminal
brew install starship tmux zellij direnv

# Editors
brew install neovim

# Container Tools
brew install lazydocker

# AI/Dev
brew install ollama
```

### Chezmoi Setup

```bash
# Install
brew install chezmoi

# Initialize from your dotfiles repo (or start fresh)
chezmoi init https://github.com/YOUR_USER/dotfiles.git
# or
chezmoi init

# Add files to management
chezmoi add ~/.config/hypr/hyprland.conf
chezmoi add ~/.config/waybar/config.jsonc
chezmoi add ~/.config/waybar/style.css
chezmoi add ~/.config/mise/config.toml
chezmoi add ~/.bashrc

# Apply dotfiles
chezmoi apply

# See what would change
chezmoi diff
```

### Chezmoi Templates for Multi-Machine Configs

Create `~/.local/share/chezmoi/.chezmoidata.toml`:

```toml
[data]
  hostname = "aurora-desktop"
  gpu = "nvidia"
  monitor_primary = "DP-1"
  monitor_res = "3840x2160@144"
  monitor_scale = "1.5"
```

Then `~/.local/share/chezmoi/dot_config/hypr/hyprland.conf.tmpl`:

```
# Managed by chezmoi
monitor = {{ .monitor_primary }}, {{ .monitor_res }}, 0x0, {{ .monitor_scale }}

{{ if eq .gpu "nvidia" -}}
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
cursor {
    no_hardware_cursors = true
}
{{- end }}

exec-once = waybar
exec-once = hyprpaper
exec-once = dunst
```

---

## Phase 6: Distrobox Development Containers

Distrobox is pre-installed on Aurora-DX. It creates tightly host-integrated containers sharing your home directory, Wayland session, GPU, and network.

### Create Development Containers

```bash
# Fedora dev container (for dnf-based workflows)
distrobox create --name fedora-dev --image registry.fedoraproject.org/fedora-toolbox:42

# Arch Linux container (for AUR access)
distrobox create --name arch-dev --image archlinux:latest

# Ubuntu container (for apt-based workflows)
distrobox create --name ubuntu-dev --image ubuntu:24.04
```

### Set Up Arch Container with AUR

```bash
distrobox enter arch-dev

# Inside arch-dev:
sudo pacman -Syu --noconfirm base-devel git

# Install yay (AUR helper)
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si --noconfirm

# Now install any AUR package
yay -S <package-name>
```

### Export Binaries to Host

```bash
# Export a CLI tool from a container to the host
distrobox-export --bin /usr/bin/some-tool --export-path ~/.local/bin

# Export a GUI app
distrobox-export --app some-app
```

### Reproducible Container Setup with distrobox-assemble

Create `~/.config/distrobox/distrobox.ini`:

```ini
[fedora-dev]
image=registry.fedoraproject.org/fedora-toolbox:42
additional_packages="gcc gcc-c++ make cmake git curl wget openssl-devel"

[arch-dev]
image=archlinux:latest
additional_packages="base-devel git"

[ai-dev]
image=registry.fedoraproject.org/fedora-toolbox:42
additional_packages="gcc gcc-c++ python3-pip python3-devel cuda-toolkit nvidia-driver-cuda"
nvidia=true
```

```bash
distrobox assemble create
```

---

## Phase 7: AI/ML & Local LLM Playground

### RTX 5080 AI Capabilities

- **16GB GDDR7 VRAM** (sufficient for 7B-13B models at full precision, larger models with quantization)
- **5th-gen Tensor Cores** with FP4/FP8 support
- **Dual 9th-gen NVENC encoders** (for simultaneous streaming + recording)
- **Blackwell architecture** requires NVIDIA open kernel modules and driver 570.86.16+

### Ollama (Simple Local LLM Inference)

Ollama is the easiest path to running local LLMs. Install via Homebrew:

```bash
brew install ollama

# Start the Ollama service
ollama serve &

# Pull and run models
ollama pull llama3.1:8b          # 8B parameter model (fits in 16GB VRAM)
ollama pull deepseek-coder-v2:16b # Code-focused model
ollama pull mistral:7b            # Fast general-purpose model

# Run interactively
ollama run llama3.1:8b

# API endpoint available at http://localhost:11434
```

### vLLM (High-Performance Inference Server)

For production-quality inference with higher throughput, use vLLM in a Distrobox container:

```bash
distrobox enter ai-dev

# Inside ai-dev container:
pip install vllm

# Start vLLM server with RTX 5080 optimizations
vllm serve meta-llama/Llama-3.1-8B-Instruct \
    --dtype auto \
    --max-model-len 8192 \
    --gpu-memory-utilization 0.9 \
    --port 8000
```

> **Performance**: vLLM with NVFP4 quantization can achieve ~8,000 tokens/sec on Blackwell. Ollama tops out around ~132 tokens/sec (still excellent for interactive use). Use Ollama for development, vLLM for serving.

### NVIDIA Container Toolkit Setup

For GPU access in Podman/Docker containers:

```bash
# Install NVIDIA Container Toolkit (if not pre-installed on Aurora-DX)
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
    sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# For containers, use --gpus flag rather than distrobox --nvidia
podman run --rm --gpus all nvidia/cuda:12.6.0-runtime-ubi9 nvidia-smi
```

> **Distrobox GPU Note**: The `--nvidia` flag in Distrobox has known issues on Fedora Atomic. Use `--additional-flags "--gpus all"` instead:
> ```bash
> distrobox create --name ai-dev \
>     --image registry.fedoraproject.org/fedora-toolbox:42 \
>     --additional-flags "--gpus all"
> ```

### Agent Framework Playground

Set up an agentic AI development environment:

```bash
distrobox enter ai-dev

# Install agent frameworks
pip install crewai      # Role-based agents, lowest learning curve
pip install langgraph   # Graph-based workflows, most powerful for production
pip install autogen     # Conversational multi-agent, best for iterative tasks

# Or use Claude Code's agent SDK directly with your Anthropic API key
```

**Framework Selection Guide:**

| Framework | Best For | Learning Curve |
|---|---|---|
| **CrewAI** | Role-based team workflows, rapid prototyping | Low |
| **LangGraph** | Production systems, fine-grained control, audit trails | High |
| **AutoGen** | Conversational collaboration, code execution, human-in-the-loop | Medium |

**Recommended starting point**: CrewAI for prototyping, LangGraph for production. Both work excellently with local Ollama models via the OpenAI-compatible API at `http://localhost:11434/v1`.

---

## Phase 8: OBS Content Pipeline

### Install OBS Studio

```bash
# Flatpak is the recommended install method on Fedora Atomic
flatpak install flathub com.obsproject.Studio

# Install PipeWire plugin for Wayland screen capture
flatpak install flathub com.obsproject.Studio.Plugin.obs-pipewire-audio-capture
```

### RTX 5080 Dual NVENC Encoder Setup

The RTX 5080 has **two 9th-gen NVENC encoders**, enabling simultaneous streaming and recording:

- **Encoder 1**: Stream to Twitch/YouTube at 1080p60 AV1
- **Encoder 2**: Local recording at 4K60 AV1

### OBS NVENC AV1 Configuration

**For Streaming (Encoder 1):**

| Setting | Value |
|---------|-------|
| Encoder | NVIDIA NVENC AV1 |
| Rate Control | CBR |
| Bitrate | 6000-8000 Kbps (Twitch) / 12000-20000 (YouTube) |
| Preset | P5 (Quality) |
| Tuning | High Quality |
| Multipass Mode | Two Pass (Quarter Resolution) |
| Profile | Main |

**For Recording (Encoder 2):**

| Setting | Value |
|---------|-------|
| Encoder | NVIDIA NVENC AV1 |
| Rate Control | CQP |
| CQ Level | 18-20 (near-lossless) |
| Preset | P7 (Max Quality) |
| Tuning | High Quality |
| Multipass Mode | Two Pass (Full Resolution) |

> **AV1 Platform Support**: YouTube fully supports AV1. Twitch supports AV1 via Enhanced Broadcast (beta). Discord supports AV1 for streaming.

### Hyprland Screen Capture (PipeWire/Screencopy)

Wayland screen capture requires xdg-desktop-portal-hyprland and PipeWire:

1. Ensure `xdg-desktop-portal-hyprland` is installed (should be from Phase 3)
2. In `~/.config/hypr/hyprland.conf`, add:
   ```
   exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
   exec-once = systemctl --user start xdg-desktop-portal-hyprland
   ```
3. In OBS, add a **Screen Capture (PipeWire)** source
4. A portal dialog will appear asking which screen/window to share

### Known Issues & Workarounds

**PipeWire + NVIDIA buffer issue**: OBS imports PipeWire buffers as `GL_TEXTURE_2D`, but NVIDIA's linear images are external-only. If you see black screens or crashes:

```bash
# Try setting this environment variable before launching OBS
OBS_USE_EGL=1 flatpak run com.obsproject.Studio
```

**OBS 31.x PipeWire crash fix**: Ensure you're on OBS 31.0.0-3 or later (the Flatpak should be current).

**Audio capture**: PipeWire handles all audio routing. Use `pavucontrol` (install via Flatpak) or `pw-top` to verify audio streams.

---

## Phase 9: KVM/QEMU Virtualization

### Setup (via ujust)

```bash
ujust setup-virtualization
```

This installs and configures libvirt, QEMU, and virt-manager, adds your user to the libvirt group, and enables services.

### Kernel Parameters for IOMMU

If not already set, add to kernel command line:

```bash
# For AMD:
rpm-ostree kargs --append=amd_iommu=on --append=iommu=pt
systemctl reboot
```

Verify IOMMU is active:

```bash
dmesg | grep -i iommu
# Should show: AMD-Vi: Found IOMMU
```

### Check IOMMU Groups

```bash
#!/bin/bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done
```

For GPU passthrough to work cleanly, the GPU and its audio controller should be in their own IOMMU group. The X870E-E has good IOMMU group isolation.

### Single GPU Passthrough (Advanced)

If you want to pass your RTX 5080 to a VM (e.g., Windows gaming VM), you need hook scripts that:

1. Stop the display manager (Hyprland)
2. Unbind the GPU from nvidia driver
3. Bind to vfio-pci
4. Start the VM
5. Reverse on VM shutdown

This is complex. See the [Complete Single GPU Passthrough Guide](https://github.com/QaidVoid/Complete-Single-GPU-Passthrough) for reference.

> **NVIDIA note**: NVIDIA guest drivers require Hyper-V Vendor ID spoofing and hiding the KVM CPU leaf. Add to your VM XML:
> ```xml
> <features>
>   <hyperv>
>     <vendor_id state='on' value='123456789ab'/>
>   </hyperv>
>   <kvm>
>     <hidden state='on'/>
>   </kvm>
> </features>
> ```

---

## Phase 10: Chezmoi Final Apply & Dotfile Structure

### Recommended Dotfile Repository Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl                    # Machine-specific variables
├── .chezmoiignore                        # Conditional file exclusion
├── dot_bashrc                            # ~/.bashrc
├── dot_zshrc                             # ~/.zshrc
├── dot_config/
│   ├── hypr/
│   │   ├── hyprland.conf.tmpl            # Templated Hyprland config
│   │   ├── hyprpaper.conf
│   │   └── hyprlock.conf
│   ├── waybar/
│   │   ├── config.jsonc
│   │   └── style.css
│   ├── dunst/
│   │   └── dunstrc
│   ├── wofi/
│   │   ├── config
│   │   └── style.css
│   ├── mise/
│   │   └── config.toml.tmpl             # Templated per-machine runtimes
│   ├── starship.toml
│   ├── ghostty/
│   │   └── config
│   ├── nvim/                             # Neovim config
│   │   └── init.lua
│   ├── distrobox/
│   │   └── distrobox.ini                 # Reproducible container definitions
│   └── xdg-desktop-portal/
│       └── hyprland-portals.conf
├── run_once_01-install-mise.sh           # Install mise on first apply
├── run_once_02-install-brew-packages.sh  # Install Homebrew CLI tools
├── run_onchange_install-mise-tools.sh.tmpl  # Reinstall runtimes when config changes
└── run_once_03-setup-distrobox.sh        # Create Distrobox containers
```

### Bootstrap Scripts

`run_once_01-install-mise.sh`:
```bash
#!/bin/bash
if ! command -v mise &> /dev/null; then
    curl https://mise.run | sh
fi
```

`run_once_02-install-brew-packages.sh`:
```bash
#!/bin/bash
if command -v brew &> /dev/null; then
    brew install ripgrep fd fzf bat eza zoxide lazygit gh git-delta \
        starship tmux jq yq btop neovim direnv ollama lazydocker
fi
```

`run_onchange_install-mise-tools.sh.tmpl`:
```bash
#!/bin/bash
# Hash: {{ include "dot_config/mise/config.toml.tmpl" | sha256sum }}
if command -v mise &> /dev/null; then
    mise install --yes
fi
```

`run_once_03-setup-distrobox.sh`:
```bash
#!/bin/bash
if command -v distrobox &> /dev/null; then
    distrobox assemble create
fi
```

### Final Apply

On a fresh Aurora-DX machine, the entire setup is a single command:

```bash
# One-liner to bootstrap everything
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply YOUR_GITHUB_USER
```

This will:
1. Install Chezmoi
2. Clone your dotfiles repo
3. Apply all configs
4. Run `run_once_*` scripts (install Mise, Homebrew packages, create Distrobox containers)
5. Run `run_onchange_*` scripts (install Mise runtimes)

---

## Appendix: Omarchy Component Mapping

### Complete Arch-to-Fedora Dependency Map

| Arch/AUR Package | Aurora-DX Alternative | Install Method |
|---|---|---|
| `base-devel` (gcc, make) | `gcc`, `make`, `cmake` | Distrobox |
| `yay` / `paru` | N/A (use Arch Distrobox) | Distrobox |
| `nvm` / `pyenv` / `asdf` | **Mise** | Host (userspace) |
| `neovim` | `brew install neovim` | Homebrew |
| `hyprland` | COPR / Custom Image | rpm-ostree or image build |
| `waybar` | COPR / Custom Image | rpm-ostree or image build |
| `ghostty` | Flatpak or Homebrew | Flatpak / Homebrew |
| `firefox` / `chromium` | Flatpak | `flatpak install` |
| `docker` | Podman (pre-installed) | Built-in |
| `docker-compose` | `podman-compose` | `brew install docker-compose` |
| `ripgrep` / `fd` / `bat` / `fzf` | Homebrew | `brew install` |
| `lazygit` / `gh` | Homebrew | `brew install` |
| `starship` | Homebrew | `brew install` |
| `tmux` / `zellij` | Homebrew | `brew install` |
| `nodejs` / `python` / `go` / `rust` | Mise | `mise use` |
| `kubectl` / `helm` / `terraform` | Mise or Homebrew | `mise use` or `brew install` |
| `stow` | **Chezmoi** (superior) | `brew install chezmoi` |
| AUR-only packages | Arch Distrobox + yay | Distrobox |
| `ttf-*` / `otf-*` fonts | Fedora RPM fonts | rpm-ostree |
| `obs-studio` | Flatpak | `flatpak install` |
| `spotify` / `zoom` | Flatpak | `flatpak install` |
| `libreoffice` | Flatpak | `flatpak install` |

### Package Installation Decision Flowchart

```
Need a package?
├── Desktop GUI app? ──────────────> Flatpak
├── Language runtime? ─────────────> Mise
├── CLI tool in Homebrew? ─────────> Homebrew
├── Dev library/compiler? ─────────> Distrobox (fedora-dev)
├── AUR-only package? ─────────────> Distrobox (arch-dev + yay)
├── System service/driver? ────────> rpm-ostree (last resort)
└── Wayland compositor/ecosystem? ─> Custom image build
```

---

## Quick Reference: Day Zero Checklist

```
[ ] Configure BIOS (IOMMU, SVM, EXPO, ReBAR, Secure Boot)
[ ] Install Aurora-DX NVIDIA from ISO
[ ] Pin image to version tag (not latest)
[ ] Enroll Secure Boot MOK key
[ ] Verify NVIDIA driver (570.86.16+, open kernel modules)
[ ] Run ujust nvidia-test
[ ] Install Hyprland (custom image, COPR, or community image)
[ ] Configure Hyprland NVIDIA env vars
[ ] Layer keyd via rpm-ostree, configure macOS bindings
[ ] Run ujust setup-virtualization
[ ] Install Mise, configure runtimes
[ ] Install Homebrew CLI tools
[ ] Initialize Chezmoi, add all configs
[ ] Create Distrobox containers (fedora-dev, arch-dev, ai-dev)
[ ] Install Ollama, pull models
[ ] Install OBS (Flatpak), configure NVENC AV1
[ ] Set up PipeWire screen capture portal
[ ] Configure IOMMU kernel params for KVM
[ ] Final chezmoi apply from dotfiles repo
[ ] Reboot and verify everything works
```

---

## Sources

- [Universal Blue / Aurora](https://universal-blue.org/) | [Aurora GitHub](https://github.com/ublue-os/aurora)
- [Hyprland-Atomic](https://github.com/cjuniorfox/hyprland-atomic) - Community Fedora Atomic Hyprland image
- [Omarchy](https://omarchy.org/) | [GitHub](https://github.com/basecamp/omarchy) | [Manual](https://learn.omacom.io/2/the-omarchy-manual)
- [NVIDIA 570.86.16 Linux Driver (RTX 5080 support)](https://www.phoronix.com/news/NVIDIA-570.86.16-Linux-Driver)
- [RTX 5080 Linux Driver Guide](https://gist.github.com/jatinkrmalik/86afb07cbe6abf5baa2d29d3842aa328)
- [vLLM Blackwell Optimization](https://blog.vllm.ai/2025/10/09/blackwell-inferencemax.html)
- [RTX 5080 LLM Benchmarks](https://www.microcenter.com/site/mc-news/article/benchmarking-ai-on-nvidia-5080.aspx)
- [Distrobox NVIDIA on Bluefin](https://github.com/ublue-os/bluefin/issues/2559)
- [OBS + Hyprland Screen Capture](https://obsproject.com/forum/threads/obs-and-hyprland-works.167558/)
- [OBS PipeWire NVIDIA Fix](https://andrew-mccall.com/blog/2026/01/obs-studio-fix-pipewire-with-nvidia-and-intel-graphics-on-niri-and-wayland/)
- [Single GPU Passthrough Guide](https://github.com/QaidVoid/Complete-Single-GPU-Passthrough)
- [keyd Key Remapper](https://github.com/rvaiya/keyd) | [Fedora COPR](https://copr.fedorainfracloud.org/coprs/alternateved/keyd/)
- [Chezmoi + Mise Integration](https://manuelchichi.com.ar/blog/personal-toolset-2025/)
- [Mise Runtime Manager](https://mise.jdx.dev/)
- [Chezmoi Dotfile Manager](https://www.chezmoi.io/)
- [Best GPUs for Local LLM 2025](https://localllm.in/blog/best-gpus-llm-inference-2025)
- [CrewAI vs LangGraph vs AutoGen](https://www.datacamp.com/tutorial/crewai-vs-langgraph-vs-autogen)
- [NVIDIA NVENC OBS Guide](https://www.nvidia.com/en-us/geforce/guides/broadcasting-guide/)
- [NVIDIA Dual NVENC Encoder Support](https://videocardz.com/newz/nvdia-geforce-gpus-now-support-up-to-8-concurrent-nvenc-encoding-sessions)
