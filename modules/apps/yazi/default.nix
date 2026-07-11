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
      };
      open = {
        rules = [
          { mime = "text/*"; use = "edit"; }
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
      ];
    };
  };

  # --- UIロジック設定 (init.lua) ---
  # フルボーダーや matugen 連携のステータスバーなどの UI カスタマイズ (実 Lua ファイル)．
  xdg.configFile."yazi/init.lua".source = ./init.lua;

  # --- フレーバー設定 ---
  # フレーバーリポジトリの配置を行います．
  xdg.configFile."yazi/flavors/kanagawa-dragon.yazi".source = kanagawa-dragon-yazi;

  # --- テーマ設定 (テンプレート) ---
  # @@プレースホルダ@@ を matugen-apply が matugen パレットで置換して theme.toml を生成する．
  xdg.configFile."yazi/theme-template.toml".source = ./theme-template.toml;
}
