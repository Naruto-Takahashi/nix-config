# =========================================================================
# Kanata キーボードリマッパー設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # Kanata: キーボードリマッパー（宣言的キーマップ管理）
  # -----------------------------------------------------------------------
  xdg.configFile."kanata/config.kbd".text = ''
    (defcfg
      process-unmapped-keys yes
    )

    ;; -------------------------------------------------------------------
    ;; 物理キー監視対象の宣言 (defsrc)
    ;; 実際のキーボードの物理配列に沿って視覚的に整列しています。
    ;; -------------------------------------------------------------------
    (defsrc
      caps  lalt  spc   ralt
      grv   1     2     3     4     5     6     7     8     9
      tab   q     w     e     r     t     y     u     i     o     p     ret
      a     s     d     f     h     j     k     l
      v     m
    )

    ;; -------------------------------------------------------------------
    ;; キーエイリアス（マッピング定義）
    ;; -------------------------------------------------------------------
    (defalias
      ;; 左右Alt単押しでのIME切り替え (Tap: 英数/かな / Hold: 隠しレイヤー)
      alt-eng  (tap-hold 200 200 muhenkan (layer-toggle alt-layer))
      alt-jp   (tap-hold 200 200 henkan ralt)

      ;; CapsLock長押しでのCtrl化 (Tap: Esc / Hold: Left Ctrl)
      cap-ctrl (tap-hold 200 200 esc lctl)

      ;; スペースキー長押しでのナビゲーションレイヤー移行 (Tap: Space / Hold: Nav-Layer)
      spc-nav  (tap-hold 200 200 spc (layer-toggle nav))

      ;; =================================================================
      ;; Alt長押し (Alt-Layer) 時の Super (lmet) ショートカットの定義
      ;; =================================================================
      ;; 窓操作 & ランチャー
      hyp-q       (multi lmet lsft q)   ;; Alt + q   -> Super + Shift + q (閉じる)
      hyp-d       (multi lmet d)        ;; Alt + d   -> Super + d (Rofi起動)
      hyp-ret     (multi lmet ret)      ;; Alt + Ent -> Super + Enter (端末起動)
      hyp-tab     (multi lmet tab)      ;; Alt + Tab -> Super + Tab (窓一覧切り替え)
      hyp-sft-spc (multi lmet lsft spc) ;; Alt + Spc -> Super + Shift + Space (浮動切替)
      hyp-f       (multi lmet f)        ;; Alt + f   -> Super + f (フルスクリーン)
      hyp-t       (multi lmet t)        ;; Alt + t   -> Super + t (タイリング復元)

      ;; 窓の直接リサイズ
      hyp-u       (multi lmet u)        ;; Alt + u   -> Super + u (幅を縮小)
      hyp-i       (multi lmet i)        ;; Alt + i   -> Super + i (高さを縮小)
      hyp-o       (multi lmet o)        ;; Alt + o   -> Super + o (高さを拡大)
      hyp-p       (multi lmet p)        ;; Alt + p   -> Super + p (幅を拡大)

      ;; ワークスペース移動
      hyp-s       (multi lmet s)        ;; Alt + s   -> Super + s (次のWSへ)
      hyp-a       (multi lmet a)        ;; Alt + a   -> Super + a (前のWSへ)
      hyp-grv     (multi lmet grv)      ;; Alt + `   -> Super + ` (直前のWSへ戻る)

      ;; ワークスペース 1-9 へ切り替え
      hyp-1       (multi lmet 1)
      hyp-2       (multi lmet 2)
      hyp-3       (multi lmet 3)
      hyp-4       (multi lmet 4)
      hyp-5       (multi lmet 5)
      hyp-6       (multi lmet 6)
      hyp-7       (multi lmet 7)
      hyp-8       (multi lmet 8)
      hyp-9       (multi lmet 9)

      ;; ウィンドウの移動・最小化・分割方向
      hyp-h       (multi lmet h)        ;; Alt + h   -> Super + h (左へフォーカス)
      hyp-j       (multi lmet j)        ;; Alt + j   -> Super + j (下へフォーカス)
      hyp-k       (multi lmet k)        ;; Alt + k   -> Super + k (上へフォーカス)
      hyp-l       (multi lmet l)        ;; Alt + l   -> Super + l (右へフォーカス)
      hyp-m       (multi lmet m)        ;; Alt + m   -> Super + m (最小化)
      hyp-v       (multi lmet v)        ;; Alt + v   -> Super + v (分割トグル)
    )

    ;; -------------------------------------------------------------------
    ;; デフォルトのベースレイヤー (通常時)
    ;; -------------------------------------------------------------------
    (deflayer base
      @cap-ctrl @alt-eng @spc-nav @alt-jp
      grv   1     2     3     4     5     6     7     8     9
      tab   q     w     e     r     t     y     u     i     o     p     ret
      a     s     d     f     h     j     k     l
      v     m
    )

    ;; -------------------------------------------------------------------
    ;; 左右Alt長押し時のエミュレーションレイヤー (Alt-Layer)
    ;; すべての i3wm アクションが Alt キーの組み合わせだけで発動します。
    ;; -------------------------------------------------------------------
    (deflayer alt-layer
      _     _     @hyp-sft-spc _
      @hyp-grv @hyp-1 @hyp-2 @hyp-3 @hyp-4 @hyp-5 @hyp-6 @hyp-7 @hyp-8 @hyp-9
      @hyp-tab @hyp-q _     _     _     @hyp-t _     @hyp-u @hyp-i @hyp-o @hyp-p @hyp-ret
      @hyp-a @hyp-s @hyp-d @hyp-f @hyp-h @hyp-j @hyp-k @hyp-l
      @hyp-v @hyp-m
    )

    ;; -------------------------------------------------------------------
    ;; スペース長押し時の高速ナビゲーションレイヤー (Nav-Layer)
    ;; -------------------------------------------------------------------
    (deflayer nav
      _     _     _     _
      _     home  prtsc end   C-z   bspc  del   _     _     _
      _     _     _     _     _     _     _     _     _     _     _     _
      _     _     _     _     left  down  up    right
      _     _
    )
  '';

  # -----------------------------------------------------------------------
  # Kanata ユーザーサービスの宣言的管理
  # -----------------------------------------------------------------------
  systemd.user.services.kanata = {
    Unit = {
      Description   = "Kanata keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata";
    };
    Service = {
      Environment = "PATH=${pkgs.kanata}/bin";
      ExecStart   = "${pkgs.kanata}/bin/kanata --cfg /home/nalt/.config/kanata/config.kbd";
      Restart     = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
