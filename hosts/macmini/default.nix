# =========================================================================
# Mac mini (常時稼働機) 用 Home Manager 設定
# =========================================================================
# 通常の Mac 構成 (hosts/mac) に、メール秘書の定期実行 (launchd) を加えたもの。
# 二重通知を避けるため、メール秘書の `run --apply` はこのマシンだけで動かす。
{ mail-secretary, ... }:

{
  imports = [
    ../mac
    mail-secretary.homeManagerModules.default
  ];

  services.mailSecretary = {
    enable = true;
    interval = 600; # 10 分おき
  };
}
