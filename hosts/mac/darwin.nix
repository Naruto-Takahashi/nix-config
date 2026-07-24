# =========================================================================
# nix-darwin Macシステム環境設定ファイル (~/.config/home-manager/hosts/mac/darwin.nix)
# =========================================================================
{ pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # システム共通パッケージの定義
  # -----------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    git
    vim
    kanata
  ];

  # -----------------------------------------------------------------------
  # Homebrew連携 (Caskアプリの宣言的インストール用)
  # -----------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none"; # 既存の手動インストールアプリを誤って削除しないよう保護
    };
    taps = [
      "nikitabobko/tap"
      "FelixKratz/formulae"
    ];
    casks = [
      "aerospace"          # タイリングウィンドウマネージャ
      "vivaldi"            # Vivaldiブラウザ
      "raycast"            # クイックランチャー / Spotlight代替
      "alt-tab"            # WindowsスタイルのAlt+Tabスイッチャー
    ];
    brews = [
      "borders"            # アクティブウィンドウの枠線ハイライト用ツール
    ];
  };

  # Determinate Nix 衝突防止のため、nix-darwin側のNix管理を無効化
  nix.enable = false;

  # -----------------------------------------------------------------------
  # macOS システムレベルの設定
  # -----------------------------------------------------------------------
  # プライマリユーザーの指定（homebrew.enable 等に必須）
  system.primaryUser = "nalt";

  # ユーザーアカウントの定義
  users.users.nalt = {
    name = "nalt";
    home = "/Users/nalt";
  };

  # macOS システムレベルの設定
  system.stateVersion = 5;

  # シェルの設定 (Zshを有効化)
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;



  # Karabiner-DriverKit-VirtualHIDDevice デーモンの起動サービス設定．
  # Karabiner-Elements本体（グラバー/メニュー等）はmacOSのBackground Task
  # Managementで管理されており launchctl disable が定着しないため，
  # Karabiner-Elements本体は導入せず，このドライバ（Kanataの仮想キー出力に
  # 必須）だけを nix-darwin 管理の LaunchDaemon で直接起動する．
  # ドライバ本体（システム拡張）は事前に手動インストール・承認が必要．
  launchd.daemons.karabiner-vhid-daemon = {
    serviceConfig = {
      ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Library/Logs/karabiner-vhid-daemon.out.log";
      StandardErrorPath = "/Library/Logs/karabiner-vhid-daemon.err.log";
    };
  };

  # macOS向け Kanata バックグラウンド起動サービスの設定 (System Daemon として実行し、root権限を付与)
  # 仮想キーボードへの書き込み先である上記 VirtualHIDDevice デーモンの起動を待ってから起動する．
  # 実行ファイルはNixストアの直接パスではなく，安定パス (/usr/local/bin/kanata) を使う．
  # 理由は下記 postActivation の再署名処理を参照．
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "until pgrep -f Karabiner-VirtualHIDDevice-Daemon >/dev/null; do sleep 1; done && until [ -x /usr/local/bin/kanata ]; do sleep 1; done && sleep 5 && exec /usr/local/bin/kanata --cfg /Users/nalt/.config/kanata/config.kbd"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/Library/Logs/kanata.out.log";
      StandardErrorPath = "/Library/Logs/kanata.err.log";
    };
  };

  # Kanataバイナリのビルドのたびに macOS の Input Monitoring / Accessibility 権限が
  # リセットされる問題への対処．Nixの成果物はad-hoc署名（中身のハッシュが識別子）のため，
  # バージョンや依存が変わるたびにTCC上「別アプリ」扱いになり権限が消える．
  # そこで永続的な自己署名証明書を(初回のみ)作成し，ビルドごとにNixストアの実体を
  # 安定パス (/usr/local/bin/kanata) へコピーしてその証明書で再署名することで，
  # TCC側の識別子を固定化し，権限が再ビルド後も維持されるようにする．
  system.activationScripts.postActivation.text = ''
    echo "Stabilizing kanata binary identity for TCC permission persistence..."

    KANATA_CERT_NAME="nix-config-kanata-codesign"
    KANATA_KEYCHAIN="/Library/Keychains/System.keychain"
    KANATA_STABLE_BIN="/usr/local/bin/kanata"
    KANATA_SRC_BIN="/run/current-system/sw/bin/kanata"

    if ! /usr/bin/security find-certificate -c "$KANATA_CERT_NAME" "$KANATA_KEYCHAIN" >/dev/null 2>&1; then
      echo "Creating persistent local code-signing certificate: $KANATA_CERT_NAME"
      TMP_CERT_DIR=$(mktemp -d)
      ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 \
        -keyout "$TMP_CERT_DIR/key.pem" -out "$TMP_CERT_DIR/cert.pem" \
        -days 36500 -nodes -subj "/CN=$KANATA_CERT_NAME" \
        -addext "keyUsage=critical,digitalSignature" \
        -addext "extendedKeyUsage=critical,codeSigning" 2>/dev/null
      # -legacy: OpenSSL 3.x's default PKCS12 MAC/cipher isn't parsable by
      # macOS Keychain ("MAC verification failed during PKCS12 import"),
      # so force the old RC2/3DES encoding that `security import` understands.
      ${pkgs.openssl}/bin/openssl pkcs12 -export -legacy -out "$TMP_CERT_DIR/bundle.p12" \
        -inkey "$TMP_CERT_DIR/key.pem" -in "$TMP_CERT_DIR/cert.pem" -passout pass:nixconfig
      /usr/bin/security import "$TMP_CERT_DIR/bundle.p12" -k "$KANATA_KEYCHAIN" -P nixconfig -T /usr/bin/codesign -A
      rm -rf "$TMP_CERT_DIR"
    fi

    if [ -f "$KANATA_SRC_BIN" ]; then
      cp -f "$KANATA_SRC_BIN" "$KANATA_STABLE_BIN"
      chmod 755 "$KANATA_STABLE_BIN"
      /usr/bin/codesign --force --sign "$KANATA_CERT_NAME" --identifier "com.nalt.kanata" "$KANATA_STABLE_BIN"
    fi
  '';
}
