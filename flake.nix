# =========================================================================
# Nix Flake 設定ファイル (~/.config/home-manager/flake.nix)
# =========================================================================
{
  description = "Home Manager configuration of nalt";

  inputs = {
    # Nixpkgs & Home Manager の入力ソース定義
    nixpkgs.url      = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url            = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # nixGL の入力ソース定義 (OpenGLラッパー)
    nixgl = {
      url            = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."nalt" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # メイン設定ファイル (home.nix) の指定
        modules = [ ./home.nix ];

        # 各モジュールへ nixgl 引数を透過的に引き渡す
        extraSpecialArgs = { inherit nixgl; };
      };
    };
}
