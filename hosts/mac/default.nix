# =========================================================================
# Home Manager Mac環境用設定ファイル (~/.config/home-manager/hosts/mac/default.nix)
# =========================================================================
{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------
  # 各種機能・アプリケーションモジュールの読み込み
  # -----------------------------------------------------------------------
  imports = [
    ../../modules/shell/fastfetch.nix
    ../../modules/shell/zsh.nix
    ../../modules/shell/starship.nix
    ../../modules/apps/wezterm.nix
    ../../modules/apps/neovim
    ../../modules/shell/direnv.nix
    ../../modules/apps/yazi.nix
    ../../modules/apps/lazygit.nix
    ../../modules/apps/aerospace.nix
  ];

  # -----------------------------------------------------------------------
  # ユーザーメタデータ & 基本システム設定
  # -----------------------------------------------------------------------
  home.username      = "nalt";
  home.homeDirectory = "/Users/nalt";
  home.stateVersion  = "25.11";

  # Home Manager 自体の管理を有効化
  programs.home-manager.enable = true;

  # 非自由ライセンスのインストールを許可
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------------------------------
  # インストールするパッケージの定義
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    fastfetch
    cowsay
    fortune
    lolcat
    nodejs_22
    gh
    ghq
    antigravity-cli
    hackgen-nf-font
    kanata
  ];

  # フォントの設定を有効化
  fonts.fontconfig.enable = true;


  # Karabiner-Elements の設定を宣言的に配置
  xdg.configFile."karabiner/karabiner.json" = {
    force = true;
    text = ''
      {
        "profiles": [
          {
            "name": "Default",
            "selected": true,
            "simple_modifications": [],
            "virtual_hid_keyboard": {
              "keyboard_type_v2": "ansi"
            },
            "complex_modifications": {
              "rules": [
                {
                  "description": "左右のOption (Alt) キーの単押しで英数・かなに切り替える",
                  "manipulators": [
                    {
                      "type": "basic",
                      "from": {
                        "key_code": "left_option",
                        "modifiers": {
                          "optional": [
                            "any"
                          ]
                        }
                      },
                      "to": [
                        {
                          "key_code": "left_option"
                        }
                      ],
                      "to_if_alone": [
                        {
                          "key_code": "japanese_eisuu"
                        }
                      ]
                    },
                    {
                      "type": "basic",
                      "from": {
                        "key_code": "right_option",
                        "modifiers": {
                          "optional": [
                            "any"
                          ]
                        }
                      },
                      "to": [
                        {
                          "key_code": "right_option"
                        }
                      ],
                      "to_if_alone": [
                        {
                          "key_code": "japanese_kana"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          }
        ]
      }
    '';
  };

  # Mac向け Kanata 設定ファイルの動的生成（Linux/他環境との互換性を維持する置換）
  xdg.configFile."kanata/config.kbd".text =
    let
      original = builtins.readFile ../../modules/desktop/config.kbd;
      # 1. macOSでは Ctrl 長押し時に ctrl-layer を有効化する
      replaced1 = builtins.replaceStrings [ "cap-ctrl-action" ] [ "(layer-toggle ctrl-layer)" ] original;
      # 2. ウィンドウマネージャーのモディファイアは Ctrl + Cmd (C-M-) にする (wmmodifier- -> C-M-)
      replaced2 = builtins.replaceStrings [ "wmmodifier-" ] [ "C-M-" ] replaced1;
      # 3. macOSでは Alt + Space (alt-layer + spc) を A-spc (Alt + Space) に直接マッピングする
      replaced3 = builtins.replaceStrings [ "@hyp-d" ] [ "A-spc" ] replaced2;
    in
      replaced3;
}
