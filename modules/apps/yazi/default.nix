# =========================================================================
# Yazi CUI ファイルマネージャ設定モジュール
# =========================================================================
{ config, pkgs, kanagawa-dragon-yazi, ... }:

{
  # --- Yaziの基本設定 ---
  # Yaziの有効化，およびZsh連携，表示設定を設定します．
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # stateVersion < 26.05 の従来デフォルト "yy" を明示 (デフォルト変更警告の抑止)
    shellWrapperName = "yy";

    # markdownをそのままレンダリングして表示するプレビュープラグイン。
    # csv/json/ipynb/rst は rich-preview (rich-cli) に任せる (md は
    # glowの方が見やすいため、md自体はrich-previewの担当から外す)
    plugins = {
      glow = pkgs.yaziPlugins.glow;
      rich-preview = pkgs.yaziPlugins.rich-preview;
      # アーカイブ操作: 圧縮はcompress (多機能・パスワード対応)、
      # 展開はouch (openerに登録、compressの圧縮キーマップと役割が
      # 被らないようouch側のCキーマップは使わない)
      compress = pkgs.yaziPlugins.compress;
      ouch = pkgs.yaziPlugins.ouch;
    };

    settings = {
      mgr = {
        ratio = [
          1
          2
          4
        ];
        show_symlink = false;
        linemode = "size";
      };

      preview = {
        wrap = "yes";
      };

      plugin = {
        prepend_previewers = [
          # yaziの実際のmime判定は.mdをtext/plainとして返すため、
          # mime指定だけでは一度もマッチしない。拡張子(url)で直接マッチさせる
          { url = "*.md"; run = "glow"; }
          { url = "*.csv"; run = "rich-preview"; }
          { url = "*.rst"; run = "rich-preview"; }
          { url = "*.ipynb"; run = "rich-preview"; }
          { url = "*.json"; run = "rich-preview"; }
        ];
      };

      opener = {
        open = [
          {
            run = ''
              if command -v wsl-open >/dev/null 2>&1; then
                wsl-open "$@"
              else
                xdg-open "$@"
              fi
            '';
            orphan = true;
            desc = "Open";
          }
        ];
        # ouchでその場に展開 (ouch.yazi READMEの推奨設定通り)
        extract = [
          { run = ''ouch d -y "$@"''; desc = "Extract here with ouch"; }
        ];
      };
      open = {
        rules = [
          { mime = "text/*"; use = "edit"; }
          { mime = "application/zip"; use = "extract"; }
          { mime = "application/x-tar"; use = "extract"; }
          { mime = "application/x-bzip2"; use = "extract"; }
          { mime = "application/x-7z-compressed"; use = "extract"; }
          { mime = "application/x-rar"; use = "extract"; }
          { mime = "application/gzip"; use = "extract"; }
          { mime = "application/x-xz"; use = "extract"; }
          { mime = "*"; use = "open"; }
        ];
      };
    };

    # キーマップ設定
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "K" ];
          run = "seek -5";
          desc = "Seek up 5 units in the preview";
        }
        {
          on = [ "J" ];
          run = "seek 5";
          desc = "Seek down 5 units in the preview";
        }
        {
          on = [ "<C-y>" ];
          run = "seek -1";
          desc = "Seek up 1 unit in the preview";
        }
        {
          on = [ "<C-e>" ];
          run = "seek 1";
          desc = "Seek down 1 unit in the preview";
        }
        # 選択中のファイル/フォルダをアーカイブ化 (compress.yazi)
        {
          on = [ "c" "a" "a" ];
          run = "plugin compress";
          desc = "Archive selected files";
        }
        {
          on = [ "c" "a" "p" ];
          run = "plugin compress -p";
          desc = "Archive selected files (password)";
        }
        {
          on = [ "c" "a" "l" ];
          run = "plugin compress -l";
          desc = "Archive selected files (compression level)";
        }
      ];
    };
  };

  # プレビュー・アーカイブプラグインが実行時に呼ぶ実体 (PATHに必要)。
  # zipはcompress.yaziの既定フォーマット用
  home.packages = [ pkgs.glow pkgs.rich-cli pkgs.ouch pkgs.zip pkgs.unzip ];

  # --- UIロジック設定 (init.lua) ---
  # フルボーダーや matugen 連携のステータスバーなどの UI カスタマイズ (実 Lua ファイル)．
  xdg.configFile."yazi/init.lua".source = ./init.lua;

  # 2色補間 (blend) は nvim (modules/apps/neovim) の lualine とロジックを
  # 共有しているため modules/theming/lua-lib に集約し、ここに配置する。
  # yazi の Lua ランタイムは require が使えないため dofile で読み込む。
  xdg.configFile."yazi/blend.lua".source = ../../theming/lua-lib/blend.lua;

  # --- フレーバー設定 ---
  # フレーバーリポジトリの配置を行います．
  xdg.configFile."yazi/flavors/kanagawa-dragon.yazi".source = kanagawa-dragon-yazi;

  # --- テーマ設定 (テンプレート) ---
  # @@プレースホルダ@@ を matugen-apply が matugen パレットで置換して theme.toml を生成する．
  xdg.configFile."yazi/theme-template.toml".source = ./theme-template.toml;
}
