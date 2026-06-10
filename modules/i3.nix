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
  xsession.profileExtra = ''
    export XDG_SESSION_TYPE=x11

    # DISPLAY番号が10以上（XRDPセッション）の場合のみ、DPIを標準に設定（96 DPI = 100%スケール）
    display_num=$(echo $DISPLAY | cut -d: -f2 | cut -d. -f1)
    if [ -n "$display_num" ] && [ "$display_num" -ge 10 ]; then
      echo "Xft.dpi: 96" | ${pkgs.xrdb}/bin/xrdb -merge
    fi
  '';

  # -----------------------------------------------------------------------
  # i3 Window Manager 設定 (xsession の有効化を含む)
  # -----------------------------------------------------------------------
  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = ''
      # タイトルバーを非表示にし、2pxの枠線のみにする
      default_border pixel 2
      default_floating_border pixel 2

      # すべてのウィンドウ（CSDを使用するブラウザ等も含む）に対して強制的に2pxの枠線を適用する
      for_window [class=".*"] border pixel 2

      # Rofiを強制的にフローティング表示にする
      for_window [class="Rofi"] floating enable, border none
      for_window [instance="rofi"] floating enable, border none

      # ホイール中クリック（単体）で範囲選択スクリーンショットを起動する
      bindsym --whole-window --border button2 exec --no-startup-id "sh -c '${pkgs.maim}/bin/maim -s -c 1.0,0.76,0.05,0.6 | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png'"
    '';
    config = {
      inherit modifier;
      fonts = {
        names = [ "HackGen NF" ];
        size = 11.0;
      };

      # 独自キーバインドの割り当て
      keybindings = lib.mkOptionDefault {
        # =================================================================
        # 1. 基本操作 (Core Operations)
        # =================================================================
        # ターミナルの起動
        "${modifier}+Return"      = "exec ${weztermCmd}";
        "Mod1+Return"             = "exec ${weztermCmd}"; # リモート環境用 (Alt + Enter)

        # アプリケーションランチャー (rofi) の起動 (リモート判定ラッパー経由)
        "${modifier}+d"           = "exec /home/nalt/.config/home-manager/modules/rofi_launcher.sh -show drun -show-icons -theme /home/nalt/.config/rofi/simple_theme.rasi";
        "${modifier}+space"       = "exec --no-startup-id \"/home/nalt/.config/home-manager/modules/rofi_launcher.sh -show drun -show-icons -theme /home/nalt/.config/rofi/simple_theme.rasi\""; # 代替 (Super + Space)
        "F13"                     = "exec --no-startup-id \"/home/nalt/.config/home-manager/modules/rofi_launcher.sh -show drun -show-icons -theme /home/nalt/.config/rofi/simple_theme.rasi\""; # CRDマッピング用 (Alt+SpaceをF13に振る)
        "Mod1+space"              = "exec --no-startup-id \"/home/nalt/.config/home-manager/modules/rofi_launcher.sh -show drun -show-icons -theme /home/nalt/.config/rofi/simple_theme.rasi\""; # リモート環境用 (Alt + Space)
        "--release Mod1+space"    = "exec --no-startup-id \"/home/nalt/.config/home-manager/modules/rofi_launcher.sh -show drun -show-icons -theme /home/nalt/.config/rofi/simple_theme.rasi\""; # 確実な起動用

        # ウィンドウを閉じる (GNOME Forgeと統一)
        "${modifier}+Shift+q"     = "kill";
        "Mod1+Shift+q"            = "kill"; # リモート環境用 (Alt + Shift + q)

        # 画面をオフにする (Alt + Shift + X)
        "Mod1+Shift+x"            = "exec xset dpms force off";

        # フォーカス移動 (Super + HJKL)
        "${modifier}+h"           = "focus left";
        "${modifier}+j"           = "focus down";
        "${modifier}+k"           = "focus up";
        "${modifier}+l"           = "focus right";
        "Mod1+h"                  = "focus left"; # リモート環境用
        "Mod1+j"                  = "focus down"; # リモート環境用
        "Mod1+k"                  = "focus up";   # リモート環境用
        "Mod1+l"                  = "focus right";# リモート環境用

        # ウィンドウ移動 (Super + Shift + HJKL)
        "${modifier}+Shift+h"     = "move left";
        "${modifier}+Shift+j"     = "move down";
        "${modifier}+Shift+k"     = "move up";
        "${modifier}+Shift+l"     = "move right";
        "Mod1+Shift+h"            = "move left";  # リモート環境用
        "Mod1+Shift+j"            = "move down";  # リモート環境用
        "Mod1+Shift+k"            = "move up";    # リモート環境用
        "Mod1+Shift+l"            = "move right"; # リモート環境用

        # フローティング切り替え
        "${modifier}+Shift+space" = "floating toggle";
        "Mod1+Shift+space"        = "floating toggle"; # リモート環境用 (Alt + Shift + Space)

        # フルスクリーン切り替え
        "${modifier}+f"           = "fullscreen toggle";
        "Mod1+f"                  = "fullscreen toggle"; # リモート環境用 (Alt + f)

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
        "${modifier}+Tab"         = "exec /home/nalt/.config/home-manager/modules/rofi_window_wrapper.py";
        "Mod1+Tab"                = "exec /home/nalt/.config/home-manager/modules/rofi_window_wrapper.py"; # リモート環境用 (Alt + Tab)

        # ウィンドウの最小化 (Scratchpadへの退避)
        "${modifier}+m"           = "move scratchpad";
        "Mod1+m"                  = "move scratchpad"; # リモート環境用 (Alt + m)

        # 最小化したウィンドウの視覚的な一覧復元 (Rofi Window Switcherで選択)
        "${modifier}+Shift+m"     = "exec /home/nalt/.config/home-manager/modules/rofi_window_wrapper.py";
        "Mod1+Shift+m"            = "exec /home/nalt/.config/home-manager/modules/rofi_window_wrapper.py"; # リモート環境用

        # =================================================================
        # 4. GlazeWM風 即時サイズ調整 (Direct Resizing)
        # =================================================================
        "${modifier}+u"           = "resize shrink width 2 px or 2 ppt";
        "${modifier}+p"           = "resize grow width 2 px or 2 ppt";
        "${modifier}+o"           = "resize grow height 2 px or 2 ppt";
        "${modifier}+i"           = "resize shrink height 2 px or 2 ppt";
        "Mod1+u"                  = "resize shrink width 2 px or 2 ppt";  # リモート環境用
        "Mod1+p"                  = "resize grow width 2 px or 2 ppt";    # リモート環境用
        "Mod1+o"                  = "resize grow height 2 px or 2 ppt";   # リモート環境用
        "Mod1+i"                  = "resize shrink height 2 px or 2 ppt";  # リモート環境用

        # =================================================================
        # 5. ワークスペース操作 (Workspace Navigation & Follow)
        # =================================================================
        # ワークスペース切り替え (次へ / 前へ / 直前へ)
        "${modifier}+s"           = "workspace next";
        "${modifier}+a"           = "workspace prev";
        "${modifier}+grave"       = "workspace back_and_forth";
        "Mod1+s"                  = "workspace next"; # リモート環境用
        "Mod1+a"                  = "workspace prev"; # リモート環境用
        "Mod1+grave"              = "workspace back_and_forth"; # リモート環境用

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
        "Mod1+v"                  = "layout toggle split"; # リモート環境用 (Alt + v)
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
        # 起動時にデフォルトのワークスペースを1にする
        { command = "i3-msg workspace 1"; notification = false; }

        # 壁紙の設定 (ユーザーカスタム壁紙)
        { command = "${pkgs.feh}/bin/feh --bg-fill /home/nalt/Pictures/my-wallpaper.jpg"; notification = false; always = true; }

        # X11 コンポジタ (Picom) の起動 (透過表示・美化効果の有効化)
        # ※現在の DISPLAY に属する picom インスタンスのみを特定して kill してから再起動することで、物理画面に干渉せずリモートでも透過を有効化します
        { command = "for pid in \$(pgrep picom); do [ -r /proc/\$pid/environ ] && [ \"\$(cat /proc/\$pid/environ | tr '\\0' '\\n' | grep '^DISPLAY=' | cut -d= -f2)\" = \"\$DISPLAY\" ] && kill \$pid; done; ${pkgs.picom}/bin/picom --backend xrender -b"; notification = false; always = true; }

        # 日本語入力 (fcitx5) のバックグラウンド起動 (NixでラップされたMozc付きパッケージ。トレイアイコンは無効化)
        { command = "${config.i18n.inputMethod.package}/bin/fcitx5 --disable notificationitem -d"; notification = false; always = true; }

        # Wayland誤検知バグの修正 (DBus/Systemdユーザー環境変数を強制上書き)
        { command = "dbus-update-activation-environment --systemd XDG_SESSION_TYPE=x11"; notification = false; always = true; }

        # XRDPセッションの場合のみ、DPIを標準に設定（96 DPI = 100%スケール）し、i3本体とバーのフォントをさらに小さくする
        { command = "display_num=\$(echo \$DISPLAY | cut -d: -f2 | cut -d. -f1); if [ -n \"\$display_num\" ] && [ \"\$display_num\" -ge 10 ]; then echo \"Xft.dpi: 96\" | ${pkgs.xrdb}/bin/xrdb -merge; i3-msg 'font pango:HackGen NF 9'; i3-msg 'bar mainbar font pango:HackGen NF 8'; fi"; notification = false; always = true; }
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
          id = "mainbar";
          position = "top";
          fonts = {
            names = [ "HackGen NF" ];
            size = 10.0;
          };
          statusCommand = "/home/nalt/.config/home-manager/modules/i3status_wrapper.py";
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
      "load".enable            = false;
      "disk /".enable          = false;
      "memory" = {
        enable = true;
        position = 1;
        settings = {
          format             = "RAM %used";
          threshold_degraded = "10%";
          format_degraded    = "RAM MEMORY LOW: %free";
        };
      };
      "cpu_usage" = {
        enable = true;
        position = 2;
        settings = {
          format = "CPU %usage";
        };
      };
      "ethernet _first_" = {
        enable = true;
        position = 3;
        settings = {
          format_up = "ETH %ip (%speed)";
          format_down = "ETH down";
        };
      };
      "tztime local" = {
        enable = true;
        position = 4;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}
