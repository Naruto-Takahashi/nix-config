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
  # X11セッション用環境変数の修正 (Wayland判定バグ回避)
  # -----------------------------------------------------------------------
  xsession.profileExtra = ''
    export XDG_SESSION_TYPE=x11
  '';

  # -----------------------------------------------------------------------
  # i3 Window Manager 設定
  # -----------------------------------------------------------------------
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      inherit modifier;

      # 独自キーバインドの割り当て
      keybindings = lib.mkOptionDefault {
        # =================================================================
        # 1. 基本操作 (Core Operations)
        # =================================================================
        # ターミナルの起動
        "${modifier}+Return"      = "exec ${weztermCmd}";

        # アプリケーションランチャー (rofi) の起動 (Wayland誤判定防止環境変数つき)
        "${modifier}+d"           = "exec env XDG_SESSION_TYPE=x11 ${pkgs.rofi}/bin/rofi -show drun -show-icons";

        # ウィンドウを閉じる (GNOME Forgeと統一)
        "${modifier}+Shift+q"     = "kill";

        # フォーカス移動 (Super + HJKL)
        "${modifier}+h"           = "focus left";
        "${modifier}+j"           = "focus down";
        "${modifier}+k"           = "focus up";
        "${modifier}+l"           = "focus right";

        # ウィンドウ移動 (Super + Shift + HJKL)
        "${modifier}+Shift+h"     = "move left";
        "${modifier}+Shift+j"     = "move down";
        "${modifier}+Shift+k"     = "move up";
        "${modifier}+Shift+l"     = "move right";

        # フローティング切り替え
        "${modifier}+Shift+space" = "floating toggle";

        # フルスクリーン切り替え
        "${modifier}+f"           = "fullscreen toggle";

        # =================================================================
        # 2. 高品質スクリーンショット (Premium Screenshots - maim + xclip)
        # =================================================================
        # 範囲選択スクリーンショット (ゴールド `#ffc20d` の美しい半透明ドラッグ枠) -> クリップボード保存
        "${modifier}+Shift+s"     = "exec --no-startup-id \"sh -c '${pkgs.maim}/bin/maim -s -c 1.0,0.76,0.05,0.6 | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png'\"";
        "Print"                   = "exec --no-startup-id \"sh -c '${pkgs.maim}/bin/maim -s -c 1.0,0.76,0.05,0.6 | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png'\"";
        
        # 画面全体のスクリーンショット -> ~/Pictures へ自動保存
        "Shift+Print"             = "exec --no-startup-id \"sh -c 'mkdir -p ~/Pictures && ${pkgs.maim}/bin/maim ~/Pictures/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png'\"";

        # =================================================================
        # 3. ウィンドウ切り替え & 最小化・復元 (Alt+Tab & Minimization)
        # =================================================================
        # Windows風の Alt + Tab (Super + Tab) による視覚的ウィンドウ切り替え
        "${modifier}+Tab"         = "exec env XDG_SESSION_TYPE=x11 ${pkgs.rofi}/bin/rofi -show window";

        # ウィンドウの最小化 (Scratchpadへの退避)
        "${modifier}+m"           = "move scratchpad";

        # 最小化したウィンドウの視覚的な一覧復元 (Rofi Window Switcherで選択)
        "${modifier}+Shift+m"     = "exec env XDG_SESSION_TYPE=x11 ${pkgs.rofi}/bin/rofi -show window";

        # =================================================================
        # 4. GlazeWM風 即時サイズ調整 (Direct Resizing)
        # =================================================================
        "${modifier}+u"           = "resize shrink width 2 px or 2 ppt";
        "${modifier}+p"           = "resize grow width 2 px or 2 ppt";
        "${modifier}+o"           = "resize grow height 2 px or 2 ppt";
        "${modifier}+i"           = "resize shrink height 2 px or 2 ppt";

        # =================================================================
        # 5. ワークスペース操作 (Workspace Navigation & Follow)
        # =================================================================
        # ワークスペース切り替え (次へ / 前へ / 直前へ)
        "${modifier}+s"           = "workspace next";
        "${modifier}+a"           = "workspace prev";
        "${modifier}+grave"       = "workspace back_and_forth";

        # ウィンドウを別ワークスペースへ移動し、自動的に追従 (Move and Follow)
        "${modifier}+Shift+1"     = "move container to workspace number 1; workspace number 1";
        "${modifier}+Shift+2"     = "move container to workspace number 2; workspace number 2";
        "${modifier}+Shift+3"     = "move container to workspace number 3; workspace number 3";
        "${modifier}+Shift+4"     = "move container to workspace number 4; workspace number 4";
        "${modifier}+Shift+5"     = "move container to workspace number 5; workspace number 5";
        "${modifier}+Shift+6"     = "move container to workspace number 6; workspace number 6";
        "${modifier}+Shift+7"     = "move container to workspace number 7; workspace number 7";
        "${modifier}+Shift+8"     = "move container to workspace number 8; workspace number 8";
        "${modifier}+Shift+9"     = "move container to workspace number 9; workspace number 9";
        "${modifier}+Shift+0"     = "move container to workspace number 10; workspace number 10";

        # =================================================================
        # 6. レイアウト操作 (Layout Controls)
        # =================================================================
        # タイリング分割方向の切り替え (トグル)
        "${modifier}+v"           = "layout toggle split";
      };

      # -----------------------------------------------------------------------
      # リサイズモードの設定 (Vim風 HJKL をフルサポート)
      # -----------------------------------------------------------------------
      modes = {
        resize = {
          # Vim風 HJKL でのリサイズ
          "h"       = "resize shrink width 2 px or 2 ppt";
          "j"       = "resize grow height 2 px or 2 ppt";
          "k"       = "resize shrink height 2 px or 2 ppt";
          "l"       = "resize grow width 2 px or 2 ppt";

          # 矢印キーでのリサイズ
          "Left"    = "resize shrink width 2 px or 2 ppt";
          "Down"    = "resize grow height 2 px or 2 ppt";
          "Up"      = "resize shrink height 2 px or 2 ppt";
          "Right"   = "resize grow width 2 px or 2 ppt";

          # モード終了
          "Escape"  = "mode default";
          "Return"  = "mode default";
        };
      };

      # -----------------------------------------------------------------------
      # スタートアップ起動コマンド
      # -----------------------------------------------------------------------
      startup = [
        # 日本語入力 (fcitx5) のバックグラウンド起動 (NixでラップされたMozc付きパッケージ)
        { command = "${config.i18n.inputMethod.package}/bin/fcitx5 -d"; notification = false; always = true; }

        # Wayland誤検知バグの修正 (DBus/Systemdユーザー環境変数を強制上書き)
        { command = "dbus-update-activation-environment --systemd XDG_SESSION_TYPE=x11"; notification = false; always = true; }
      ];

      # -----------------------------------------------------------------------
      # ゴールドカラーテーマ（GNOME Forgeと美しく統一）
      # -----------------------------------------------------------------------
      colors = {
        focused = {
          border      = "#ffc20d";
          background  = "#ffc20d";
          text        = "#000000";
          indicator   = "#ffc20d";
          childBorder = "#ffc20d";
        };
        focusedInactive = {
          border      = "#333333";
          background  = "#333333";
          text        = "#888888";
          indicator   = "#292929";
          childBorder = "#292929";
        };
        unfocused = {
          border      = "#333333";
          background  = "#333333";
          text        = "#888888";
          indicator   = "#292929";
          childBorder = "#292929";
        };
      };

      # -----------------------------------------------------------------------
      # ステータスバー設定 (i3status連携)
      # -----------------------------------------------------------------------
      bars = [
        {
          position = "top";
          statusCommand = "/home/nalt/.config/home-manager/modules/i3status_wrapper.sh";
          colors = {
            background = "#1a1b26";
            statusline = "#ffffff";
            separator  = "#666666";
            focusedWorkspace = {
              border      = "#ffc20d";
              background  = "#ffc20d";
              text        = "#000000";
            };
            activeWorkspace = {
              border      = "#333333";
              background  = "#333333";
              text        = "#ffffff";
            };
            inactiveWorkspace = {
              border      = "#1a1b26";
              background  = "#1a1b26";
              text        = "#888888";
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
      output_format   = "i3bar";
      colors          = true;
      interval        = 5;
      color_good      = "#9ece6a";
      color_degraded  = "#e0af68";
      color_bad       = "#f7768e";
    };
    modules = {
      "ipv6".enable            = false;
      "wireless _first_".enable = false;
      "battery all".enable      = false;
      "disk /" = {
        enable = true;
        position = 1;
        settings = {
          format = "DISK %avail";
        };
      };
      "memory" = {
        enable = true;
        position = 2;
        settings = {
          format             = "RAM %used";
          threshold_degraded = "10%";
          format_degraded    = "RAM MEMORY LOW: %free";
        };
      };
      "load" = {
        enable = true;
        position = 3;
        settings = {
          format = "CPU %1min";
        };
      };
      "ethernet _first_" = {
        enable = true;
        position = 4;
        settings = {
          format_up = "ETH %ip (%speed)";
          format_down = "ETH down";
        };
      };
      "tztime local" = {
        enable = true;
        position = 5;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}
