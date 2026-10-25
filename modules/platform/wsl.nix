# =========================================================================
# WSL ホスト共通オプション (Windows 側ユーザー情報)
# =========================================================================
# Windows 側のユーザー名を 1 か所で宣言し、sync-win / kanata / Vault パス等の
# Nix 側から参照する。シェルスクリプトや PowerShell は実行時に
# %USERPROFILE% / $env:USERPROFILE から解決するため、このオプションを使わない。
{ config, lib, ... }:

let
  cfg = config.platform.wsl;
in
{
  options.platform.wsl = {
    windowsUser = lib.mkOption {
      type = lib.types.str;
      example = "tnaru";
      description = "Windows 側のユーザー名 (C:\\Users\\<name>)。";
    };

    windowsHome = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "/mnt/c/Users/${cfg.windowsUser}";
      description = "WSL から見た Windows 側ホームディレクトリ。";
    };

    windowsHomeNative = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "C:/Users/${cfg.windowsUser}";
      description = "Windows ネイティブ形式 (スラッシュ区切り) のホームディレクトリ。";
    };
  };
}
