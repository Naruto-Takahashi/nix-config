# 🌌 Naruto's Declarative Desktop Configuration (Nix + Home Manager)

This repository manages Naruto's Linux desktop environment declaratively using **Nix Flakes** and **Home Manager**. It provides a fully unified, modern, keyboard-driven development environment with premium gold/dark hacker-mode aesthetics.

---

## 🎨 Environment & Theme Showcase

* **Window Manager**: `i3wm` (X11) with customized premium Gold (`#ffc20d`) / Dark Theme.
* **Terminal**: `WezTerm` with 75% uniform background transparency, HackGen NF font, and sleek custom tab layout.
* **Shell**: `Zsh` with Starship Prompt, smart syntax highlighting (valid commands in green, invalid in red), automatic `zoxide` integration, and `fzf` completion widgets.
* **Keyboard Mapper**: `Kanata` daemon configuring Mac-style Alt Tap IME switching, and **SandS (Space and Shift)** Vim-like navigation layer (Space + HJKL/A/E/U/B/X).
* **Compositor**: `picom` (configured with robust `xrender` backend for seamless performance on NVIDIA GPUs).
* **Intelligence**: Custom auto-tiling wrapper script (`rofi_window_wrapper.py`) that instantly restores minimized scratchpad windows in tiled mode rather than floating when selected via Alt+Tab.

---

## 🚀 Environment Setup & Replication Guide (PC Migration)

Follow these **6 steps** to replicate this exact extreme-productivity desktop environment on any fresh Linux distribution (e.g., Ubuntu).

### ⚙️ Pre-setup Customization (If your username is different)
If your username on the new PC is different from `nalt` (e.g., `naruto`), edit the [home.nix](home.nix) file's user metadata before applying:
```nix
# home.nix
home.username      = "new_username";
home.homeDirectory = "/home/new_username";
```

---

### Step 1: Install the Nix Package Manager
Nix provides a secure, deterministic sandbox `/nix/store` for all programs to guarantee absolute stability.

```bash
curl -L https://nixos.org/nix/install | sh
```
*Follow the on-screen instructions. Once completed, restart your terminal or load Nix paths using:*
```bash
. ~/.nix-profile/etc/profile.d/nix.sh
```

### Step 2: Enable Nix Flakes
Enable the modern declarative Nix Flakes feature on your local system:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Step 3: Clone this Configuration Repository
Clone this repository directly into the required config folder path:

```bash
git clone https://github.com/Naruto-Takahashi/home-manager-config.git ~/.config/home-manager
```

### Step 4: Run the First Home Manager Switch (Activation)
Bootstraps the Home Manager client, downloads all required packages, generates configuration configurations, and creates seamless symlinks in one single command.

```bash
nix run github:nix-community/home-manager -- switch --flake ~/.config/home-manager --impure
```
> [!TIP]
> The `--impure` flag is necessary to dynamically bind the host machine's proprietary NVIDIA graphics driver layers so that WezTerm and picom run at maximum hardware acceleration.

### Step 5: Enable Kanata User Daemon
Register and launch the Kanata keyboard remapper service immediately to enable standard custom spacebar mappings:

```bash
systemctl --user daemon-reload
systemctl --user enable --now kanata
```

### Step 6: Start the Recreated Zsh Shell
Replace your default shell session with the newly created, high-productivity Zsh configuration:

```bash
exec zsh
```

Enjoy your premium, unified, and highly optimized hacking environment! 🌌
