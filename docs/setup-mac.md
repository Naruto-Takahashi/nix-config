# macOS (darwin) セットアップ手順 (`mac`)

[README.md](../README.md) の「どれがどのOSで動くか」対応表も参照してください。

M1 Mac などの macOS 環境でシステム設定およびアプリケーション群を統合管理する手順です．
キーボード操作 (Kanata) と壁紙配色連携 (Matugen) は macOS の TCC (権限管理) の都合上，
Nixの適用だけでは完結せず，何点か手動でのGUI操作が必要です．下記の順番通りに進めてください．

Mac を買い替える場合は，先に下の「[移行チェックリスト](#移行チェックリスト)」で旧 Mac
からの持ち出しを済ませてください．

```bash
mkdir -p ~/ghq/github.com/Naruto-Takahashi
cd ~/ghq/github.com/Naruto-Takahashi
git clone https://github.com/Naruto-Takahashi/nix-config.git
cd nix-config
```

1. **Xcode Command Line Tools のインストール**
   インストールされていない場合は，以下を実行して導入します．
   ```bash
   xcode-select --install
   ```

2. **Nix のインストール**
   Determinate Nix インストーラを使用してインストールを行います．
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

3. **Homebrew のインストール**
   Nix-darwin による Cask アプリ（AeroSpace, Vivaldi, Raycast, Alt-Tab など）の管理に
   必要となるため，事前にインストールしておきます．
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. **設定の構築とシステムへの適用**
   リポジトリを `ghq` 規定位置に配置した状態で，システム構成を適用します．
   ```bash
   # システムの適用と有効化 (初回起動時は nix run でブートストラップ)
   cd ~/ghq/github.com/Naruto-Takahashi/nix-config
   sudo nix run github:LnL7/nix-darwin -- switch --flake .#mac

   # 2回目以降の更新適用 (こちらが推奨・高速)
   sudo darwin-rebuild switch --flake .#mac
   # または justfile 経由 (sudo は付けない。内部で必要な箇所だけ sudo を求める)
   just switch
   ```

5. **機密情報の復元 (Bitwarden CLI)**
   Bitwarden のセキュアメモから API キー等の環境変数を安全（chmod 600）に復元します．
   ```bash
   just restore-secrets
   ```

6. **ドライバの機能拡張を有効化 (初回のみ・手動)**
   上記でインストール・有効化リクエストまでは自動化されていますが，**実際に
   有効化するトグルはSIPの制約上どうしても手動操作が必要**です．
   `システム設定 → 一般 → ログイン項目と機能拡張 → ドライバの機能拡張` を開き，
   `Karabiner DriverKit VirtualHIDDevice` を有効化してください．

7. **Kanataへの権限付与 (初回のみ)**
   `システム設定 → プライバシーとセキュリティ` で以下2つを許可してください．
   `/usr/local/bin/kanata` をFinderの `Cmd+Shift+G` で直接パス入力して追加する
   のが確実です．
   - **入力監視 (Input Monitoring)**
   - **アクセシビリティ (Accessibility)**

   許可後にKanataが権限を拾わない場合は，一度再起動を促してください．
   ```bash
   sudo launchctl kickstart -k system/org.nixos.kanata
   ```

   署名用の証明書 (`hosts/mac/darwin.nix` の `KANATA_CERT_NAME`) が変わると，macOSは
   Kanataを別アプリとみなし権限が外れます (ログに `needs macOS Accessibility permission`
   等が出る)．その場合は両方の一覧から既存の `kanata` を「−」で削除し，上記の手順で
   追加し直してから再起動してください (オフ→オンだけでは古い署名の情報が残ります)．
   アクセシビリティの一覧は
   `open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"`
   で直接開けます．

8. **配色反映 (Matugen) の初回許可 (任意)**
   `ctrl-cmd-w` (壁紙ピッカー) や `matugen-apply` を初めて実行すると，現在の壁紙を
   取得するために「システムイベント」のオートメーション許可を求めるダイアログが
   出ることがあります．許可すると以後は自動で通ります．詳細は
   [matugen-palette.md](matugen-palette.md) を参照してください．

9. **AeroSpace設定の再読み込み (通常は不要)**
   ログイン20秒後にAeroSpaceの設定リロードとborders起動を自動で行うLaunchAgent
   (`modules/wm/aerospace/default.nix`) があるため，通常は何もしなくても
   次回ログイン時に最新設定が反映されます．`darwin-rebuild switch` 直後，
   ログアウトを待たずにすぐ反映を見たい場合だけ手動でリロードしてください
   （`xdg.configFile`で生成される`aerospace.toml`はファイルを書き換えただけでは
   AeroSpace自身に反映されず，`after-startup-command`はAeroSpace自身の起動時に
   しか走らないため）．
   ```bash
   aerospace reload-config
   ```

---

## 移行チェックリスト

Nix で再現できないもの (認証情報・アプリ内データ・手動インストールのアプリ) の持ち出しと，
新しい Mac での後始末をまとめたものです．

### 旧 Mac で行うこと
- [ ] **SSH 鍵**: `~/.ssh/id_ed25519` (と `.pub`) を安全な経路で新しい Mac へ移す．リポジトリの
      リモートはすべて SSH (`git@github.com:...`) のため，鍵が無いと push・Vault 同期ができない．
      移さない場合は新しい鍵を作り GitHub に登録する．
- [ ] **Raycast**: ショートカット・拡張機能・スニペットは Raycast 内部の暗号化DBにあり宣言できない．
      Raycast のコマンド `Export Settings & Data` で `.rayconfig` を書き出す (Cloud Sync を使うなら不要)．
- [ ] **ブラウザ・アプリのログイン状態**: Vivaldi は Vivaldi Sync，Zotero は Zotero アカウントの同期で
      引き継ぐ (書誌・注釈は Zotero，PDF は Google Drive)．
- [ ] **未 push の変更**: nix-config と obsidian-vault に未 push のコミットや未コミットの変更が無いことを確認する．

### 新しい Mac で行うこと (上の手順 1〜9 の後)
- [ ] **GitHub CLI**: `gh auth login` (Git の操作プロトコルは SSH を選ぶ)．
- [ ] **機密情報**: `just restore-secrets` で `~/.env` を復元する (手順 5)．
- [ ] **Raycast**: 書き出した `.rayconfig` を Raycast のコマンド `Import Settings & Data` で取り込む．
- [ ] **手動インストールのアプリ**: cask が無いもの．
  - Orca (<https://github.com/stablyai/orca>)。同名の Homebrew cask `orca` は別のアプリなので使わない．
  - マウスのドライバ (KensingtonWorks / Logi Options+) は使う機種に合わせて入れる．
- [ ] **Homebrew の掃除方針**: すべてのアプリが宣言どおりに入ったら，`hosts/mac/darwin.nix` の
      `homebrew.onActivation.cleanup` を `"uninstall"` に変える．以後は宣言から外した cask が
      switch で自動削除され，宣言と実態がずれなくなる．

---

## この構成で有効になるもの

AeroSpace (WM) + JankyBorders，Kanata (キーリマップ，`Ctrl+Cmd`変換)，Matugen壁紙配色 (壁紙ピッカー含む)，Homebrew Cask管理。詳細は [aerospace.md](aerospace.md) / [kanata.md](kanata.md) / [matugen-palette.md](matugen-palette.md) を参照してください。

---

## 手動作業が残る理由 (SIP/TCC)

macOSはセキュリティ上の制約 (System Integrity Protection・Transparency Consent and Control) により，カーネル拡張の有効化やアプリへの権限付与を外部プロセスから完全に自動化することができません。このリポジトリはNixで自動化できる範囲は全て自動化していますが，「トグルを1回押す」「ダイアログでOKを押す」という最後の一手だけはどうしても人間の操作が必要です。
