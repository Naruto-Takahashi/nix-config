# 🌌 nix-config

Declarative configurations for NixOS, Ubuntu (Desktop), and WSL2 managed via **Nix Flakes** and **Home Manager**.

This repository centralizes OS-level declarations, shell utilities, window managers, and developmental tools to achieve a consistent, keyboard-driven environment.

---

## 🗺️ Documentation & Navigation

Comprehensive documentation for specific modules, keymaps, and design systems can be accessed below:

| Target Environment | Component / Module | Guide & Details | Key Functionality |
| :--- | :--- | :--- | :--- |
| **NixOS** | 🗔 Hyprland | [hyprland.md](docs/hyprland.md) | Wayland tile management, Matugen dynamic colors, Waybar. |
| **Windows / WSL2** | 🗔 GlazeWM | [glazewm.md](docs/glazewm.md) | Windows-side tiling WM, Zebar status bar integration. |
| **NixOS / Desktop** | ⌨️ Kanata | [kanata.md](docs/kanata.md) | System-level remap (SandS vim-like navigation, macOS-like IME toggle). |
| **Cross-Platform** | 💻 WezTerm | [wezterm.md](docs/wezterm.md) | 75% transparent blur window, dynamic tab title parser, custom Leader binds. |
| **Cross-Platform** | 📝 Neovim | [neovim.md](docs/neovim.md) | Customized Neovim built with Lazy.nvim, optimized Vim macros. |
| **Cross-Platform** | 📁 Yazi | [yazi.md](docs/yazi.md) | Cyberdream matching transparent file manager with custom shell hook. |

---

## 📂 Repository Structure

```
.
├── flake.nix                  # Flake entry point (defines system configurations)
├── hosts/                     # Host-specific settings (entry points)
│   ├── nixos/                 # NixOS configuration (system + home manager)
│   ├── desktop/               # Linux Desktop (Ubuntu) standalone home-manager config
│   └── wsl/                   # WSL2 standalone home-manager config
├── modules/                   # Shared declarative configuration modules
│   ├── wm/                    # Window Managers (hyprland, glazewm, zebar)
│   ├── apps/                  # CLI and GUI Applications (wezterm, neovim, yazi, lazygit)
│   ├── shell/                 # Shell integrations (zsh, starship, fastfetch, direnv)
│   └── desktop/               # System keyboard / utility layers (kanata, packages)
└── docs/                      # Technical manuals and keymap tables
```

---

## 🚀 Setup & Installation (Migration Guide)

Before continuing, verify that you areクローンing the repository into the standard `ghq` directory structure to maintain consistency with `zsh` settings.

```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

### A. Deploying on NixOS

For a fresh NixOS installation (ensure your system user is created as `nalt`):

1. **Copy Hardware Configuration**  
   Copy the host's automatically generated configurations into the flake directory and track it in git:
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/nixos/hardware-configuration.nix
   git add hosts/nixos/hardware-configuration.nix
   ```

2. **Build and Apply System State**  
   Apply the system flake configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos --impure
   ```

3. **Post-install reboot**  
   Reboot to let system-wide modules (like Kanata systemd service) initialize.

---

### B. Deploying on Standalone Ubuntu Desktop (`nalt-desktop`)

For a standard Ubuntu Linux environment (requires Nix package manager):

1. **Install Nix Package Manager** (Single-user installation)
   ```bash
   curl -L https://nixos.org/nix/install | sh
   . ~/.nix-profile/etc/profile.d/nix.sh
   ```

2. **Enable Flakes support**
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

3. **Deploy Home Manager Profile**
   ```bash
   nix run github:nix-community/home-manager -- switch --flake .#nalt-desktop --impure
   ```

4. **Initialize User Services**
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now kanata
   exec zsh
   ```

---

### C. Deploying on WSL2 (`nalt-wsl`)

For WSL2 (Ubuntu) environments:

1. **Install Nix and Enable Flakes** (same as Ubuntu Desktop step 1 & 2).
2. **Deploy Home Manager Profile**
   ```bash
   nix run github:nix-community/home-manager -- switch --flake .#nalt-wsl --impure
   ```
3. **Sync Settings to Windows Side**  
   WSL profiles manage WezTerm and GlazeWM configurations. To copy these configurations to the Windows host directory, run the sync helper:
   ```bash
   sync-win
   exec zsh
   ```
