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
      url = "https://esm.sh/react@18.3.1/es2022/react.bundle.mjs";
      sha256 = "1npvsxa9razhz3k385qbf8rq1pf64jj10yqj93jigggwhdqa4v9g";
    };
    react-dom = fetchLib {
      name = "react-dom.js";
      url = "https://esm.sh/react-dom@18.3.1/es2022/client.bundle.mjs";
      sha256 = "00afyhh4rgizk7i79d1awzis1bxwrp1jvhifmk4k47fhi45lr3qk";
    };
    htm = fetchLib {
      name = "htm.js";
      url = "https://esm.sh/htm@3.1.1/es2022/htm.bundle.mjs";
      sha256 = "1diw4ldzk8sj0gp6c8mrsy35kr76hc2jnj8ww5rl7s87wzgaiac1";
    };
    zebar = fetchLib {
      name = "zebar.js";
      url = "https://esm.sh/zebar@2.7.0/es2022/zebar.bundle.mjs";
      sha256 = "1iky6hxnvgx58azk5pa3fgrfxnvi00mszf53nyn0vvms9qadyamd";
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
