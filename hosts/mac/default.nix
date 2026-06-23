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
    ../../modules/desktop/kanata.nix
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
    hackgen-nf-font
    kanata
  ];

  # フォントの設定を有効化
  fonts.fontconfig.enable = true;

  # macOS向け Kanata バックグラウンド起動サービスの設定
  launchd.agents.kanata = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.kanata}/bin/kanata"
        "--cfg"
        "${config.home.homeDirectory}/.config/kanata/config.kbd"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/kanata.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/kanata.err.log";
    };
  };

  # Karabiner-Elements の設定を宣言的に配置
  xdg.configFile."karabiner/karabiner.json".text = ''
    {
      "profiles": [
        {
          "name": "Default",
          "selected": true,
          "simple_modifications": [],
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
}
