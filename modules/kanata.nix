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
      q     w     e     r     t     y     u
      h     j     k     l
    )

    (defalias
      ;; 左右Alt単押しでのIME切り替え (Tap: IME / Hold: Altレイヤー)
      alt-eng (tap-hold 200 200 muhenkan (layer-toggle alt-layer))
      alt-jp  (tap-hold 200 200 henkan ralt)

      cap-ctrl (tap-hold 200 200 esc lctl)
      spc-nav (tap-hold 200 200 spc (layer-toggle nav))

      ;; Alt + Q -> Super + Shift + Q (ウィンドウを閉じる)
      hyp-q (multi lmet lsft q)

      ;; Altレイヤーでの動作: Super + HJKL を送信
      hyp-h (multi lmet h)
      hyp-j (multi lmet j)
      hyp-k (multi lmet k)
      hyp-l (multi lmet l)
    )

    (deflayer base
      @cap-ctrl @alt-eng @spc-nav @alt-jp
      q     w     e     r     t     y     u
      h     j     k     l
    )

    (deflayer alt-layer
      _     _     _     _
      @hyp-q _     _     _     _     _     _
      @hyp-h @hyp-j @hyp-k @hyp-l
    )

    ;; Shiftを伴うAlt操作のためのレイヤー（もし必要なら定義可能ですが、まずは基本のAltレイヤー内でShiftが自然に扱えるか確認）
    ;; Kanataでは Alt + Shift + H を押すと、lalt + lsft + h が届きます。
    ;; 上記の @hyp-h は (multi lmet h) なので、Shiftを同時に押すと (multi lmet lsft h) になるはずです。

    (deflayer nav
      _     _     _     _
      home  prtsc end   C-z   bspc  del   _
      left  down  up    right
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
