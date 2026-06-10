# Chrome Remote Desktop 設定ガイド

研究室の PC に自宅からアクセスするための Chrome Remote Desktop (CRD) の設定手順です。

## 1. ホスト OS (Ubuntu 等) でのインストール

CRD の本体はプロプライエタリなソフトウェアであり、かつシステムサービスとして動作させる必要があるため、Nix ではなくホスト OS のパッケージマネージャでインストールします。

```bash
# .deb パッケージのダウンロード
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

# インストール (依存関係も自動解決)
sudo apt install ./chrome-remote-desktop_current_amd64.deb

# ユーザーをグループに追加 (再ログイン後に有効化)
sudo usermod -a -G chrome-remote-desktop $USER
```

## 2. Home Manager でのセッション設定

このリポジトリの Home Manager 設定を適用すると、`~/.chrome-remote-desktop-session` が自動生成されます。
これにより、CRD で接続した際に自動的に Home Manager 管理下の i3wm が起動します。

```bash
home-manager switch --flake .#nalt-desktop
```

## 3. リモートアクセスの有効化

1. [Chrome Remote Desktop (Headless)](https://remotedesktop.google.com/headless) にアクセスします。
2. 他のパソコンの設定にある「開始」をクリックし、コマンドをコピーします。
3. 研究室の PC の端末でコピーしたコマンドを実行します。
4. PIN を設定します。

## 4. 自宅からの接続

自宅のノート PC の Chrome で [remotedesktop.google.com/access](https://remotedesktop.google.com/access) にアクセスし、研究室の PC を選択して PIN を入力します。

## 5. Tips

- **キーバインド**: CRD では Super (Windows) キーがクライアント側に奪われることがあるため、i3wm の設定で `Mod1` (Alt) を使ったキーバインドも用意されています。
- **解像度**: リモート接続時に画面が小さい場合は、i3wm 内で `xrandr` を使って調整するか、CRD クライアントの設定で「サイズをウィンドウに合わせる」を有効にしてください。
- **高 DPI**: この設定では `DISPLAY` 番号が 10 以上の場合に自動的に DPI を 96 (100%) に設定するようになっています。

## 6. トラブルシューティング：キーバインドが効かない場合

Windows から接続する際、`Super` (Windowsキー) や `Alt` 関連の操作が手元の PC に奪われる場合は、以下の設定を確認してください。

### CRD クライアントの設定
1.  接続画面右側の「**＜**」メニューを開きます。
2.  **「全画面表示」** を有効にします。
3.  **「システムのショートカット キーを送信する」** を有効にします。

### クライアント側 (Windows) の AHK
手元の Windows で AutoHotkey を実行している場合、CRD より先に AHK がキーをフックしてしまいます。リモート接続中は AHK を **Suspend (一時停止)** することを推奨します。

### Kanata について
この環境で使用しているキーボードリマッパー **Kanata は、リモート接続時は動作しません。**
Kanata は物理デバイスのイベントを直接処理するため、ネットワーク経由で注入される CRD の入力には干渉できないためです。
そのため、`modules/i3.nix` には `Mod1` (Alt) を使ったリモート用の代替キーバインドが設定されています。
