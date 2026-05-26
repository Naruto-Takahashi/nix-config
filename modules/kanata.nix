# =========================================================================
# Kanata キーボードリマッパー設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # Kanata: キーボードリマッパー（AHK の代替）
  xdg.configFile."kanata/config.kbd".text = ''
    (defcfg
      process-unmapped-keys yes
    )

    (defsrc
      caps  lalt  spc   ralt
      a s e u b x
      h j k l
    )

    (defalias
      ;; 左右Alt単押しでのIME切り替え (AHKの挙動を再現)
      ;; Tap: Muhenkan (IME Off) / Hold: LAlt
      alt-eng (tap-hold 200 200 muhenkan lalt)
      ;; Tap: Henkan (IME On) / Hold: RAlt
      alt-jp  (tap-hold 200 200 henkan ralt)
      
      ;; CapsLock: Tap -> Esc / Hold -> LCtrl (Vim使い向けの定番設定)
      cap-ctrl (tap-hold 200 200 esc lctl)

      ;; Space: Tap -> Space / Hold -> Navレイヤー (Vim-like navigation)
      spc-nav (tap-hold 200 200 spc (layer-toggle nav))
    )

    (deflayer base
      @cap-ctrl @alt-eng @spc-nav @alt-jp
      _ _ _ _ _ _
      _ _ _ _
    )

    (deflayer nav
      _ _ _ _
      home sysrq end C-z bspc del
      left down up right
    )
  '';

  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata";
    };
    Service = {
      Environment = "PATH=${pkgs.kanata}/bin";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg /home/nalt/.config/kanata/config.kbd";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
