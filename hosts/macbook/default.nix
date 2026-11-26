# =========================================================================
# MacBook 用 Home Manager 設定 (hosts/macbook/default.nix)
# =========================================================================
# 共通の Mac 構成 (hosts/mac) に、Karabiner-Elements の設定を加えたもの。
# Mac mini は Kanata を使うため (hosts/macmini)、キーボードリマップだけがここで分かれる。
{
  imports = [
    ../mac
    ../../modules/input/karabiner
  ];
}
