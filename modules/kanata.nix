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
      q     w     e     r     t     y     u     i     o     p
      1     2     3     4     5     6     7     8     9
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

      ;; リサイズ用 (Alt + U/I/O/P -> Super + U/I/O/P)
      hyp-u (multi lmet u)
      hyp-i (multi lmet i)
      hyp-o (multi lmet o)
      hyp-p (multi lmet p)

      ;; Alt + 1〜9 -> Super + 1〜9 (ワークスペース切り替え)
      hyp-1 (multi lmet 1)
      hyp-2 (multi lmet 2)
      hyp-3 (multi lmet 3)
      hyp-4 (multi lmet 4)
      hyp-5 (multi lmet 5)
      hyp-6 (multi lmet 6)
      hyp-7 (multi lmet 7)
      hyp-8 (multi lmet 8)
      hyp-9 (multi lmet 9)

      ;; Altレイヤーでの動作: Super + HJKL を送信
      hyp-h (multi lmet h)
      hyp-j (multi lmet j)
      hyp-k (multi lmet k)
      hyp-l (multi lmet l)
    )

    (deflayer base
      @cap-ctrl @alt-eng @spc-nav @alt-jp
      q     w     e     r     t     y     u     i     o     p
      1     2     3     4     5     6     7     8     9
      h     j     k     l
    )

    (deflayer alt-layer
      _     _     _     _
      @hyp-q _     _     _     _     _     @hyp-u @hyp-i @hyp-o @hyp-p
      @hyp-1 @hyp-2 @hyp-3 @hyp-4 @hyp-5 @hyp-6 @hyp-7 @hyp-8 @hyp-9
      @hyp-h @hyp-j @hyp-k @hyp-l
    )

    (deflayer nav
      _     _     _     _
      _     _     _     _     _     _     _     _     _     _
      home  prtsc end   C-z   bspc  del   _     _     _
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
