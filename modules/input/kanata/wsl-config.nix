# =========================================================================
# Kanata Windows (WSLホスト) 用設定テキスト (プレースホルダ置換済み)
# =========================================================================
# config.kbd は eisu / kana のプレースホルダーと、Windows 固有の物理配列 (caps -> f13) を
# 含むテンプレート。WM修飾子 (Alt) / Alt+Space・Alt+Tab のパススルー / Alt+Shift+Q /
# alt-ctrl-layer (Ctrl+Alt) / Ctrl 長押しは、config.kbd 内の
# (platform (win winiov2 wintercept) ...) で kanata 自身が解決する。
# ここでは Windows でのみ必要な次の置換を行う:
#   1. Alt 長押しレイヤーの hold を (multi 実キー (layer-while-held ...)) に変更
#   2. eisu/kana -> ime-off/ime-on (macOS専用の仮想キーの代わりに、
#      Win32 API (ImmSetOpenStatus) 経由のIME制御が必要。kanata単体では
#      Windows上でこれを直接行えないため、既存の動作実績があるAHKの
#      ime_functions.ahkへ `cmd` アクションで委譲する)
#   3. danger-enable-cmd の有効化、caps -> f13
#
# home-manager (modules/input/kanata/wsl.nix) がこのテキストをWindows側へ
# 配置する。sync-win/matugen-apply等と同じくAHK側 (modules/input/ahk/) の
# ime-off.ahk / ime-on.ahk を直接呼び出す。
#
# 引数 windowsHomeNative: Windows 側ホーム (例: C:/Users/<name>)。platform.wsl から渡す。
{ windowsHomeNative }:

let
  base = builtins.readFile ./config.kbd;

  replaced =
    builtins.replaceStrings
      [
        # Alt長押しレイヤー (alt-eng/alt-jp) のhold動作を素の layer-toggle から
        # (multi 実キー (layer-while-held ...)) に変更する。kanata公式ドキュメント
        # (config.adoc の `multi` action解説) が明示する「レイヤー越しにOS標準の
        # Alt+Tab連続切り替えを機能させる」ための唯一の方法がこれで、単純な
        # layer-toggleではAlt+Tabキーが押されるたびにAlt自体もpress+releaseされて
        # しまい、Windows側のAlt-Tabスイッチャー(押しっぱなしでTabを連打して
        # 選ぶUI)が機能しなくなる (kanata移行後にAlt+Tabでのウィンドウ切り替え
        # が使えなくなったと報告あり。要実機確認)。より具体的なパターンを汎用の
        # "eisu"/"kana" 単語置換より前に置いて先にマッチさせる
        "eisu (layer-toggle alt-layer))"
        "kana (layer-toggle alt-layer))"
        "eisu"
        "kana"
        "process-unmapped-keys yes"
        # 本機はレジストリのScancode MapでCapsLock物理キーをF13として送出する
        # 設定にしている (main.ahkの `*F13::` コメント参照)。そのためkanataの
        # defsrcも "caps" ではなく "f13" を監視しないと物理CapsLockを一切
        # 検知できない。config.kbd内で "caps" はdefsrc行にのみ1箇所しか
        # 出現しないため単純な文字列置換で安全に対応できる
        "caps  lalt"
      ]
      [
        "@ime-off (multi lalt (layer-while-held alt-layer)))"
        "@ime-on (multi ralt (layer-while-held alt-layer)))"
        "@ime-off"
        "@ime-on"
        "process-unmapped-keys yes\n  danger-enable-cmd yes"
        "f13   lalt"
      ]
      base;

  # AHK側の一発実行スクリプト (modules/input/ahk/ime-off.ahk, ime-on.ahk) を
  # cmdアクションで呼び出すためのdefalias。defaliasはconfig.kbd中に複数
  # ブロックがあっても構わない仕様 (kanata公式ドキュメント参照) だが、
  # エイリアスは「参照より前に定義」されている必要がある (実機の
  # `kanata --check` で検証済み) ため、@ime-off/@ime-on を使う既存の
  # defaliasブロックより前に来るよう先頭に配置する
  imeDelegation = ''
    ;; IME制御 (Windows専用委譲): Win32 API呼び出しが必要なため、
    ;; 実績のあるAHKのime_functions.ahk (ime-off.ahk/ime-on.ahk) へ委譲する
    (defalias
      ime-off (cmd "C:/Program Files/AutoHotkey/v1.1.37.02/AutoHotkeyU64.exe" "${windowsHomeNative}/Tools/Customization/ime-off.ahk")
      ime-on  (cmd "C:/Program Files/AutoHotkey/v1.1.37.02/AutoHotkeyU64.exe" "${windowsHomeNative}/Tools/Customization/ime-on.ahk")
    )

  '';
in
imeDelegation + replaced
