# =========================================================================
# Kanata Linux 用設定テキスト (プレースホルダ置換済み)
# =========================================================================
# config.kbd はプレースホルダー (cap-ctrl-action / wmmodifier- / eisu / kana)
# を含むテンプレート。Linux では以下に置換して使う:
#   1. Ctrl長押しはそのまま通常の lctl 修飾キー (cap-ctrl-action -> lctl)
#   2. WM モディファイアは単一の Super (wmmodifier- -> M-)
#   3. eisu/kana (macOS専用仮想キー) は JIS 無変換/変換 (muhenkan/henkan)
# home-manager 側 (kanata.nix) と NixOS システムサービス側
# (hosts/nixos/default.nix) の両方がこのテキストを共有する。
# macOS は置換内容が異なるため hosts/mac/default.nix に別実装がある。
builtins.replaceStrings
  [ "cap-ctrl-action" "wmmodifier-" "eisu" "kana" ]
  [ "lctl" "M-" "muhenkan" "henkan" ]
  (builtins.readFile ./config.kbd)
