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

    # Yazi Kanagawa Dragon フレーバーの入力ソース定義
    kanagawa-dragon-yazi = {
      url   = "github:Naruto-Takahashi/kanagawa-dragon.yazi";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, kanagawa-dragon-yazi, ... }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        # WSL環境用プロファイル
        "nalt-wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/wsl ];
          extraSpecialArgs = { inherit nixgl kanagawa-dragon-yazi; };
        };

        # Linuxデスクトップ環境用プロファイル
        "nalt-desktop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/desktop ];
          extraSpecialArgs = { inherit nixgl kanagawa-dragon-yazi; };
        };

        # 互換性維持のためのデフォルトプロファイル（WSL設定を参照）
        "nalt" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/wsl ];
          extraSpecialArgs = { inherit nixgl kanagawa-dragon-yazi; };
        };
      };
    };
}
