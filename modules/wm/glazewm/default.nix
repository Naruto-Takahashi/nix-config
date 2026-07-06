# =========================================================================
# GlazeWM & Zebar 宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

let
  # --- 外部ライブラリ定義 ---
  # Zebar用の外部ライブラリをNixで管理します．
  fetchLib = { name, url, sha256 }: pkgs.fetchurl { inherit name url sha256; };
  
  libs = {
    preact = fetchLib {
      name = "preact.js";
      url = "https://unpkg.com/preact@10.22.0/dist/preact.mjs";
      sha256 = "0c2ald5g40i4656s7ks9915va0vz5170qbmv79mdwx1syjv44y88";
    };
    hooks = fetchLib {
      name = "hooks.js";
      url = "https://unpkg.com/preact@10.22.0/hooks/dist/hooks.mjs";
      sha256 = "09m9wdln52qsyaxja3n3y0dj693p42wz5f4fwdp106ypmcvn47pj";
    };
    htm = fetchLib {
      name = "htm.js";
      url = "https://unpkg.com/htm@3.1.1/dist/htm.mjs";
      sha256 = "1r798xcaffwbksfvw2sfkiimc8zvxql02dgmspj9p6q570zxscxb";
    };
    zebar = fetchLib {
      name = "zebar.js";
      url = "https://esm.sh/zebar@2.7.0/es2022/zebar.bundle.mjs";
      sha256 = "1iky6hxnvgx58azk5pa3fgrfxnvi00mszf53nyn0vvms9qadyamd";
    };
  };
in
{
  # --- GlazeWM設定 ---
  # GlazeWM設定ディレクトリを宣言的に配置します．
  xdg.configFile."glazewm".source = ./glazewm;

  # --- Zebar設定 ---
  # Zebar設定ディレクトリを宣言的に配置します（再帰的リンクを有効化）．
  xdg.configFile."zebar" = {
    source = ./zebar;
    recursive = true;
  };

  # --- AutoHotkey設定 ---
  # AutoHotkey設定ディレクトリを宣言的に配置します．
  xdg.configFile."ahk".source = ./ahk;
}
