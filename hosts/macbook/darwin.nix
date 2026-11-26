# =========================================================================
# MacBook 専用の nix-darwin 設定 (hosts/macbook/darwin.nix)
# =========================================================================
# キーボードリマップは Karabiner-Elements (設定は modules/input/karabiner)。
# Kanata は起動時にしかデバイスを掴まず、外付けキーボードの後付け接続・再起動後の
# 接続順に弱かったため移行した。Mac mini は引き続き Kanata (hosts/mac/kanata-darwin.nix)。
#
# 注意: Karabiner-Elements は専用のドライバ (Karabiner-DriverKit-VirtualHIDDevice) を
# 同梱する。Kanata 用に単体で入れていたデーモンと競合するので、この構成では
# 単体デーモンを定義しない (旧 launchd デーモンは switch で自動的に外れる)。
{
  homebrew.casks = [
    "karabiner-elements" # キーボードリマップ (設定は modules/input/karabiner から配置)
  ];
}
