# =========================================================================
# i3wm (i3 window manager) & i3status 設定モジュール
# =========================================================================
{ config, pkgs, lib, nixgl, ... }:

let
  modifier = "Mod4"; # Superキー (Windowsキー)
  # weztermをnixGL経由で起動するためのヘルパー
  weztermCmd = "${nixgl.packages.${pkgs.system}.nixGLDefault}/bin/nixGL ${pkgs.wezterm}/bin/wezterm";
in
{
  # -----------------------------------------------------------------------
  # i3 Window Manager 設定
  # -----------------------------------------------------------------------
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      inherit modifier;

      # 独自キーバインドの割り当て
      keybindings = lib.mkOptionDefault {
        # ターミナルの起動
        "${modifier}+Return" = "exec ${weztermCmd}";

        # アプリケーションランチャー (rofi) の起動
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun -show-icons";

        # ウィンドウを閉じる (GNOME Forgeと統一: Super+Shift+Q)
        "${modifier}+Shift+q" = "kill";

        # フォーカス移動 (Super + HJKL)
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        # ウィンドウ移動 (Super + Shift + HJKL)
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        # フローティング切り替え
        "${modifier}+Shift+space" = "floating toggle";

        # フルスクリーン切り替え
        "${modifier}+f" = "fullscreen toggle";
      };

      # スタートアップ起動コマンド
      startup = [
        # 日本語入力 (fcitx5) のバックグラウンド起動
        { command = "${pkgs.fcitx5}/bin/fcitx5 -d"; notification = false; always = true; }
      ];

      # ゴールドカラーテーマ（GNOME Forgeと統一）
      colors = {
        focused = {
          border = "#ffc20d";
          background = "#ffc20d";
          text = "#000000";
          indicator = "#ffc20d";
          childBorder = "#ffc20d";
        };
        focusedInactive = {
          border = "#333333";
          background = "#333333";
          text = "#888888";
          indicator = "#292929";
          childBorder = "#292929";
        };
        unfocused = {
          border = "#333333";
          background = "#333333";
          text = "#888888";
          indicator = "#292929";
          childBorder = "#292929";
        };
      };

      # ステータスバー設定 (i3status連携)
      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          colors = {
            background = "#1a1b26";
            statusline = "#ffffff";
            separator = "#666666";
            focusedWorkspace = {
              border = "#ffc20d";
              background = "#ffc20d";
              text = "#000000";
            };
            activeWorkspace = {
              border = "#333333";
              background = "#333333";
              text = "#ffffff";
            };
            inactiveWorkspace = {
              border = "#1a1b26";
              background = "#1a1b26";
              text = "#888888";
            };
          };
        }
      ];
    };
  };

  # -----------------------------------------------------------------------
  # i3status 設定の宣言的管理
  # -----------------------------------------------------------------------
  programs.i3status = {
    enable = true;
    general = {
      colors = true;
      interval = 5;
      colorGood = "#9ece6a";
      colorWarning = "#e0af68";
      colorBad = "#f7768e";
    };
    modules = {
      "ipv6".enable = false;
      "wireless _first_".enable = false;
      "ethernet _first_".enable = false;
      "battery all".enable = false;
      "disk /" = {
        enable = true;
        position = 1;
        settings = {
          format = "💾 %avail";
        };
      };
      "memory" = {
        enable = true;
        position = 2;
        settings = {
          format = "RAM %used";
          thresholdDegraded = "10%";
          formatDegraded = "RAM MEMORY LOW: %free";
        };
      };
      "load" = {
        enable = true;
        position = 3;
        settings = {
          format = "CPU %1min";
        };
      };
      "tztime local" = {
        enable = true;
        position = 4;
        settings = {
          format = "📅 %Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}
