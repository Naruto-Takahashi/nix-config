# =========================================================================
# Kanata Linux 用設定テキスト (プレースホルダ置換済み)
# =========================================================================
# config.kbd は eisu / kana (macOS専用仮想キー) のプレースホルダーのみを含む。
# WM修飾子 (Super) や Ctrl 長押しは config.kbd 内の (platform (linux) ...) で解決する。
# Linux では eisu/kana を JIS 無変換/変換 (muhenkan/henkan) に置換する。
# home-manager 側 (kanata.nix) と NixOS システムサービス側
# (hosts/nixos/default.nix) の両方がこのテキストを共有する。
# macOS は置換内容が異なるため hosts/mac/default.nix に別実装がある。
builtins.replaceStrings
  [ "eisu" "kana" ]
  [ "muhenkan" "henkan" ]
  (builtins.readFile ./config.kbd)
