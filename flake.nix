# =========================================================================
# Nix Flake 設定ファイル (~/.config/home-manager/flake.nix)
# =========================================================================
{
  description = "Home Manager configuration of nalt";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # nixGLのリポジトリを指定
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 💡 修正ポイント1: nixgl を関数の引数としてしっかり受け取るように追加します
  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."nalt" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        # 💡 修正ポイント2: コメントアウトを外して、home.nixにnixglを引き渡します
        extraSpecialArgs = { inherit nixgl; };
      };
    };
}
