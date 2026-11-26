# =========================================================================
# Karabiner-Elements 設定 (MacBook 用。~/.config/karabiner/karabiner.json を生成)
# =========================================================================
# Kanata (modules/input/kanata/config.kbd + mac-config.nix) の macOS 版と同じ挙動を
# Karabiner の complex_modifications で再現する。デバイスの抜き差し・再起動後の
# 後付け接続は Karabiner 自身が処理するため、kanata で起きていた
# 「起動時に外付けキーボードが無いと効かない」問題が起きない。
# 全キーボード (内蔵・HHKB・Keychron) に同じ設定を適用する。
#
# レイヤーは変数で表現する (kanata の layer-toggle 相当)。
#   alt_layer : 左右Option押下中 (WM 操作レイヤー。Option 自体は OS へ送らない)
#   altctrl   : alt_layer 中にCaps/左Ctrlを押している間 (join-with 等)
#   nav       : Space 長押し中 (ナビゲーションレイヤー)
# 先に書いた manipulator が優先されるので、並びは「上位のレイヤー → 下位」にしてある。
#
# 注意: F1-F12 は触らない。内蔵キーボードの F 行は macOS 標準でメディアキー、
# Fn 併用で素の F キーになるため、kanata で必要だった個別割り当てが不要。
{ pkgs, lib, ... }:

let
  # ---- 小さな部品 ---------------------------------------------------------
  cc = [
    "left_control"
    "left_command"
  ]; # Ctrl+Cmd (AeroSpace 用の WM 修飾子)
  cca = cc ++ [ "left_option" ]; # Ctrl+Cmd+Option (join-with)

  varIf = name: {
    type = "variable_if";
    inherit name;
    value = 1;
  };
  setVar = name: value: {
    set_variable = { inherit name value; };
  };
  out =
    key: mods:
    {
      key_code = key;
    }
    // lib.optionalAttrs (mods != [ ]) { modifiers = mods; };

  # レイヤー内のキー: Shift 等の修飾キーはそのまま通す (optional any)
  layerKey = layers: from: to: {
    type = "basic";
    from = {
      key_code = from;
      modifiers.optional = [ "any" ];
    };
    to = [ to ];
    conditions = map varIf layers;
  };

  mkLayer = layers: attrs: lib.mapAttrsToList (layerKey layers) attrs;

  # ---- Alt レイヤー (Option 長押し): WM 操作 ------------------------------
  # config.kbd の alt-layer と同じ対応 (macOS: C-M- = Ctrl+Cmd)
  digits = lib.genAttrs (map toString (lib.range 1 9)) (k: out k cc);
  letters = lib.genAttrs [
    "w"
    "e"
    "r"
    "y"
    "u"
    "i"
    "o"
    "p"
    "a"
    "s"
    "f"
    "h"
    "j"
    "k"
    "l"
    "c"
    "v"
    "b"
    "n"
    "m"
  ] (k: out k cc);
  altLayerMap =
    digits
    // letters
    // {
      grave_accent_and_tilde = out "grave_accent_and_tilde" cc;
      tab = out "tab" [ "left_option" ]; # Option+Tab (AltTab アプリ連携)
      q = out "w" (cc ++ [ "left_shift" ]); # 閉じる (Cmd+Shift+Q=ログアウト回避で w にずらす)
      t = out "spacebar" (cc ++ [ "left_shift" ]); # 浮動切替
      d = out "t" cc; # タイリング復元
      spacebar = out "spacebar" [ "left_option" ]; # Option+Space (Raycast 等)
      return_or_enter = out "return_or_enter" cc;
      comma = out "comma" cc;
      slash = out "slash" cc;
      left_arrow = out "left_arrow" cc;
      down_arrow = out "down_arrow" cc;
      up_arrow = out "up_arrow" cc;
      right_arrow = out "right_arrow" cc;
    };

  # ---- Alt+Ctrl レイヤー: join-with と Moonlight 切断 --------------------
  altCtrlMap = {
    h = out "h" cca;
    j = out "j" cca;
    k = out "k" cca;
    l = out "l" cca;
    q = out "q" [
      "left_control"
      "left_option"
      "left_shift"
    ]; # Moonlight 切断
  };

  # ---- Nav レイヤー (Space 長押し) ---------------------------------------
  navMap = {
    e = out "end" [ ];
    u = out "z" [ "left_command" ]; # Undo (macOS は Cmd+Z)
    a = out "home" [ ];
    d = out "right_control" [ ]; # Superwhisper 録音キー
    h = out "left_arrow" [ ];
    j = out "down_arrow" [ ];
    k = out "up_arrow" [ ];
    l = out "right_arrow" [ ];
    x = out "delete_forward" [ ];
    b = out "delete_or_backspace" [ ];
  };

  # ---- 単独のキー割り当て --------------------------------------------------
  simple =
    from: to: extra:
    {
      type = "basic";
      from.key_code = from;
      inherit to;
    }
    // extra;

  # Caps / 左Ctrl は他の修飾キーを先に押していても拾う
  # (拾えないと Shift 先押しで本物の CapsLock が入ってしまう)
  modKey =
    from: to: extra:
    simple from to extra
    // {
      from = {
        key_code = from;
        modifiers.optional = [ "any" ];
      };
    };

  optionKey =
    key:
    simple key
      [
        (setVar "alt_layer" 1)
      ]
      {
        to_after_key_up = [
          (setVar "alt_layer" 0)
          (setVar "altctrl" 0)
        ];
      };

  # Alt レイヤー中に Caps / 左Ctrl を押している間だけ altctrl を立てる
  altCtrlToggle =
    key:
    modKey key [ (setVar "altctrl" 1) ] {
      to_after_key_up = [ (setVar "altctrl" 0) ];
      conditions = [ (varIf "alt_layer") ];
    };

  # 左右 Command: 単押しで英数/かな、長押し・同時押しは通常の Command
  commandKey =
    key: ime:
    simple key [ { key_code = key; } ] {
      to_if_alone = [ { key_code = ime; } ];
    };

  rules = [
    {
      description = "Esc: Esc + 英数";
      manipulators = [
        (simple "escape" [
          { key_code = "escape"; }
          { key_code = "japanese_eisuu"; }
        ] { })
      ];
    }
    {
      description = "Alt+Ctrl レイヤー (Option 押下中に Caps/左Ctrl)";
      manipulators =
        map altCtrlToggle [
          "caps_lock"
          "left_control"
        ]
        ++ mkLayer [ "alt_layer" "altctrl" ] altCtrlMap;
    }
    {
      description = "Alt レイヤー (Option 長押しで WM 操作)";
      manipulators = mkLayer [ "alt_layer" ] altLayerMap;
    }
    {
      description = "左右 Option を Alt レイヤーのトリガーにする";
      manipulators = map optionKey [
        "left_option"
        "right_option"
      ];
    }
    {
      description = "Nav レイヤー (Space 長押し)";
      manipulators = mkLayer [ "nav" ] navMap;
    }
    {
      description = "Space: 単押しで Space、長押しで Nav レイヤー";
      manipulators = [
        (simple "spacebar" [ (setVar "nav" 1) ] {
          to_if_alone = [ { key_code = "spacebar"; } ];
          to_after_key_up = [ (setVar "nav" 0) ];
        })
      ];
    }
    {
      description = "Caps Lock: 単押しで Esc+英数、長押しで Ctrl";
      manipulators = [
        (modKey "caps_lock" [ { key_code = "left_control"; } ] {
          to_if_alone = [
            { key_code = "escape"; }
            { key_code = "japanese_eisuu"; }
          ];
        })
      ];
    }
    {
      description = "左 Ctrl を右 Ctrl に (Superwhisper 録音キー)";
      manipulators = [ (modKey "left_control" [ { key_code = "right_control"; } ] { }) ];
    }
    {
      description = "左右 Command: 単押しで英数/かな";
      manipulators = [
        (commandKey "left_command" "japanese_eisuu")
        (commandKey "right_command" "japanese_kana")
      ];
    }
  ];

  config = {
    global = {
      check_for_updates_on_startup = false;
      show_in_menu_bar = false;
    };
    profiles = [
      {
        name = "Default profile";
        selected = true;
        complex_modifications = {
          parameters = {
            "basic.to_if_alone_timeout_milliseconds" = 200;
            "basic.to_if_held_down_threshold_milliseconds" = 200;
          };
          inherit rules;
        };
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
      }
    ];
  };

  # 人が読める整形 JSON にして配置する (差分確認・トラブルシュート用)
  pretty = pkgs.runCommand "karabiner.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
    jq . ${pkgs.writeText "karabiner-raw.json" (builtins.toJSON config)} > $out
  '';
in
{
  # Karabiner は GUI から設定を書き換えうるが、ここから配置する読み取り専用リンクが正本。
  # 設定変更は必ずこのファイルを編集して switch する。
  xdg.configFile."karabiner/karabiner.json".source = pretty;
}
