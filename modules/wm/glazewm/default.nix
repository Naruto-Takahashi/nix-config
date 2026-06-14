# =========================================================================
# GlazeWM & Zebar 宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

let
  # Zebar用の外部ライブラリをNixで管理
  fetchLib = { name, url, sha256 }: pkgs.fetchurl { inherit name url sha256; };
  
  libs = {
    react = fetchLib {
      name = "react.js";
      url = "https://esm.sh/react@18?bundle";
      sha256 = "075hv0yxg1vana0x4mc97bm1rhq0qwmlvbxd3kr9y1fmw1zv3778";
    };
    react-dom = fetchLib {
      name = "react-dom.js";
      url = "https://esm.sh/react-dom@18/client?bundle";
      sha256 = "0g794wqgwggz94q83f1b34xgdviv5lk0y20mhqvpf73jskxpqvgp";
    };
    htm = fetchLib {
      name = "htm.js";
      url = "https://esm.sh/htm?bundle";
      sha256 = "0ryir6qsr0xilr781mrgqr13rd9xaw52z5i5ccdk8036nhz5wnv7";
    };
    zebar = fetchLib {
      name = "zebar.js";
      url = "https://esm.sh/zebar@2?bundle";
      sha256 = "1mq20xvp2wd9rnv9lc68naqk74abp6ajc117fsw6c7g17p412mzq";
    };
  };
in
{
  # GlazeWM 設定ディレクトリの宣言的配置
  xdg.configFile."glazewm".source = ./glazewm;

  # Zebar 設定ディレクトリの宣言的配置 (再帰的リンクを有効化)
  xdg.configFile."zebar" = {
    source = ./zebar;
    recursive = true;
  };

  # ライブラリファイルを配置
  xdg.configFile."zebar/custom/status-bar/lib/react.js".source = libs.react;
  xdg.configFile."zebar/custom/status-bar/lib/react-dom.js".source = libs.react-dom;
  xdg.configFile."zebar/custom/status-bar/lib/htm.js".source = libs.htm;
  xdg.configFile."zebar/custom/status-bar/lib/zebar.js".source = libs.zebar;

  # AutoHotkey 設定ディレクトリの宣言的配置
  xdg.configFile."ahk".source = ./ahk;
}
