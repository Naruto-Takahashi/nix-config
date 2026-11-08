# WSL2 (Ubuntu) セットアップ手順 (`wsl`)

[README.md](../README.md) の「どれがどのOSで動くか」対応表も参照してください。

WSL2 (Ubuntu) 環境で CLI ツール群および Windows 側デスクトップ連携 (komorebi / YASB / Kanata / AHK / Vivaldi) を統合管理する手順です．

```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

1. **Nix のインストール**
   Determinate Nix インストーラを使用してインストールを行います (Flakes が最初から有効化されます)．
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```
   ※ 公式シングルユーザーインストーラを使う場合は `curl -L https://nixos.org/nix/install | sh` 後に `~/.config/nix/nix.conf` へ `experimental-features = nix-command flakes` を追記してください．

2. **Home Manager プロファイルの適用**
   Flakes を利用して Home Manager 構成を適用します．
   ```bash
   nix run github:nix-community/home-manager -- switch --flake .#wsl --impure
   # またはリポジトリ内の justfile を使用 (2回目以降推奨)
   just switch
   ```

3. **機密情報・SSH鍵の復元 (Bitwarden CLI)**
   Bitwarden から API キー (`~/.env`) および SSH 鍵・config (`~/.ssh/`) を安全（chmod 600）に復元します．
   ```bash
   just restore-secrets
   just restore-ssh
   ```

4. **Windows側への設定ファイル同期**
   WSL2 環境下で管理される WezTerm や komorebi / YASB / Kanata の設定を Windows ホストに反映するため，同期コマンドを実行します．
   ```bash
   sync-win # または just sync-win
   exec zsh
   ```

---

## この構成で有効になるもの

キーボードリマップは、Windows 側でネイティブ動作する [Kanata (Windows版)](kanata.md) が SandS / CapsLock / IME 切り替えを担当し、komorebi の WM 操作ホットキーは [AutoHotkey](../modules/input/ahk/main.ahk) が連携します（AHK 側にも同等のフォールバック実装があり、Kanata 終了時は自動で AHK 実装へロールバックします）。komorebi (WM) + YASB (ステータスバー) は Windows 側で動作し、`sync-win` で設定を配置します。Matugen 壁紙配色は Windows 側の壁紙から WSL 経由で自動生成します。詳細は [komorebi.md](komorebi.md) / [kanata.md](kanata.md) / [matugen-palette.md](matugen-palette.md) / [obsidian-brain.md](obsidian-brain.md) を参照してください。
