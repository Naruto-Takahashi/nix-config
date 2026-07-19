# =========================================================================
# 全ホスト共通プロファイル (シェル環境 + コア CLI アプリ)
# =========================================================================
# wsl / mac / ubuntu / nixos の全ホストが import する共通セット。
# ホスト固有のモジュール (WM や OS 依存アプリ) は各 hosts/*/ 側で追加する。
{ config, pkgs, lib, ... }:

{
  # -----------------------------------------------------------------------
  # 各モジュールで利用するグローバル引数
  # -----------------------------------------------------------------------
  # mkOutOfStoreSymlink で参照するこのリポジトリのチェックアウト位置。
  # リポジトリをこのパス以外に clone すると、symlink 配置される設定
  # (starship / yasb / komorebi / vivaldi / matugen-common など) が
  # すべて壊れるので注意。
  _module.args = {
    dotfilesPath = "${config.home.homeDirectory}/ghq/github.com/Naruto-Takahashi/nix-config";
  };

  imports = [
    ../modules/shell/zsh
    ../modules/shell/starship
    ../modules/shell/direnv
    ../modules/shell/fastfetch
    ../modules/apps/wezterm
    ../modules/apps/neovim
    ../modules/apps/yazi
    ../modules/apps/lazygit
    ../modules/theming/matugen
  ];

  # -----------------------------------------------------------------------
  # 全ホスト共通の小物 CLI ツール
  # -----------------------------------------------------------------------
  # tldr クライアント (コマンドの使用例を素早く確認する)
  # 配色は kanagawa-dragon 準拠のフォールバック。matugen 環境 (WSL) では
  # matugen-apply が ~/.cache/matugen/tealdeer/config.toml を生成し、
  # zsh が TEALDEER_CONFIG_DIR でそちらを優先する。
  programs.tealdeer = {
    enable = true;
    settings = {
      updates.auto_update = true; # キャッシュが古いとき自動で `tldr --update` 相当を実行
      style = {
        description.foreground.rgb = { r = 197; g = 201; b = 197; };      # text #c5c9c5
        command_name = {
          foreground.rgb = { r = 230; g = 195; b = 132; };                # accent #e6c384
          bold = true;
        };
        example_text.foreground.rgb = { r = 166; g = 166; b = 156; };     # muted #a6a69c
        example_code.foreground.rgb = { r = 122; g = 168; b = 159; };     # tertiary #7aa89f
        example_variable = {
          foreground.rgb = { r = 162; g = 146; b = 163; };                # secondary #a292a3
          italic = true;
        };
      };
    };
  };

  # シェル履歴の検索/記録強化。Ctrl+R を atuin の全文検索 UI に置き換える。
  # ↑キーの挙動は通常の zsh 履歴のまま維持する (--disable-up-arrow)。
  programs.atuin = {
    enable = true;
    # 「失敗した実行時間」と「選択行」の色が AlertError 1スロット共有なのを
    # パッチで分離する (選択行 → Important)。ソースからの再ビルドが走る
    package = pkgs.atuin.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ../modules/patches/atuin-separate-selection-color.patch
      ];
      doCheck = false; # テストをスキップしてビルド時間を短縮
    });
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
      inline_height = 20;
      style = "full"; # fzf の --border 風に検索窓・結果リストを枠線付きで表示
      # 検索バーを上・結果を下に (トップダウン)
      invert = true;
      show_tabs = false; # Search/Inspector タブバーを隠してすっきりさせる
      show_help = false; # 最下部の "<esc>: exit ..." キーヘルプを隠す
      show_preview = false; # 選択中コマンドのプレビュー行を隠す
      update_check = false;
      theme.name = "matugen"; # 実体は下の activation / matugen-apply が配置
    };
  };

  # atuin / btop のテーマは「theme 名は matugen 固定・中身のファイルを
  # 差し替える」方式。matugen 環境では matugen-apply が壁紙由来の配色で
  # 上書きし、無い環境ではここで配置する kanagawa-dragon 版が使われ続ける。
  # btop は終了時に btop.conf を自分で書き換えるため programs.btop
  # (読み取り専用 symlink) は使わず、初回のみ設定をシードする。
  home.activation.seedMatugenThemes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/atuin/themes" "$HOME/.config/btop/themes"
    [ -f "$HOME/.config/atuin/themes/matugen.toml" ] || \
      cp ${../modules/theming/matugen/fallbacks/atuin-theme.toml} \
        "$HOME/.config/atuin/themes/matugen.toml"
    [ -f "$HOME/.config/btop/themes/matugen.theme" ] || \
      cp ${../modules/theming/matugen/fallbacks/btop.theme} \
        "$HOME/.config/btop/themes/matugen.theme"
    chmod u+w "$HOME/.config/atuin/themes/matugen.toml" \
      "$HOME/.config/btop/themes/matugen.theme"
    if [ ! -f "$HOME/.config/btop/btop.conf" ]; then
      printf '%s\n' \
        'color_theme = "matugen"' \
        'theme_background = False' \
        'vim_keys = True' \
        > "$HOME/.config/btop/btop.conf"
    fi
  '';

  home.packages = [
    pkgs.smassh # MonkeyType 風の TUI タイピング練習
    pkgs.fd # find の現代版 (fzf バックエンドにも)
    pkgs.delta # git diff のシンタックスハイライト付きページャ (~/.gitconfig が参照)
    pkgs.btop # システムモニタ TUI (テーマは上の activation / matugen-apply が配置)
  ];
}
