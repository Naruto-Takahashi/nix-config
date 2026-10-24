# NixOS セットアップ手順

[README.md](../README.md) の「どれがどのOSで動くか」対応表も参照してください。

NixOSの公式インストーラで最小インストール（ユーザー名は **`nalt`** で作成）を完了した後の手順です。

```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

1. **ハードウェア構成ファイルのコピー**
   PC固有のハードウェア構成ファイルをリポジトリ内に上書きコピーし，Gitの追跡対象に加えます．
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/nixos/hardware-configuration.nix
   git add hosts/nixos/hardware-configuration.nix
   ```

2. **設定の構築とシステムへの適用**
   Flakesを利用してシステム構成と Home Manager の設定を一括適用します．
   ```bash
   sudo nixos-rebuild switch --flake .#nixos --impure
   # または justfile 経由
   just switch
   ```

3. **機密情報の復元 (Bitwarden CLI)**
   Bitwarden のセキュアメモから API キー等の環境変数を安全（chmod 600）に復元します．
   ```bash
   just restore-secrets
   ```

4. **システムの再起動**
   Kanata などのシステムサービスを完全に認識させるため，適用後は一度PCを再起動してください．

5. **リモートデスクトップの初回認証（Tailscale + Sunshine）**
   認証情報はステートのため初回のみ手動で有効化します．
   ```bash
   # 1. Tailscale ログイン
   sudo tailscale up
   tailscale ip -4

   # 2. Sunshine のペアリング
   # ブラウザで https://localhost:47990 を開き、アカウント作成と Moonlight からの PIN 入力を行う
   ```

---

## この構成で有効になるもの

Hyprland (WM) + Waybar，Kanata (キーリマップ，`Super`変換)，fcitx5+Mozc，Matugen壁紙配色，Tailscale+Sunshine無人リモート接続。詳細は各ドキュメント ([hyprland.md](hyprland.md) / [kanata.md](kanata.md) / [matugen-palette.md](matugen-palette.md)) を参照してください。
