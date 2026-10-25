# =========================================================================
# Nix Flake 設定ファイル (nix-config エントリーポイント)
# =========================================================================
{
  description = "Home Manager configuration of nalt";

  inputs = {
    # Nixpkgs & Home Manager の入力ソース定義
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixGL の入力ソース定義 (OpenGLラッパー)
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi Kanagawa Dragon フレーバーの入力ソース定義
    kanagawa-dragon-yazi = {
      url = "github:Naruto-Takahashi/kanagawa-dragon.yazi";
      flake = false;
    };

    # nix-darwin の入力ソース定義
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixgl,
      kanagawa-dragon-yazi,
      darwin,
      ...
    }:
    let
      # 全モジュールに渡す追加引数 (使わないモジュールは単に受け取らない)
      specialArgs = { inherit nixgl kanagawa-dragon-yazi; };

      # スタンドアロン Home Manager 構成 (Linux 系ホスト)
      mkHome =
        host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./hosts/${host} ];
          extraSpecialArgs = specialArgs;
        };

      # NixOS / nix-darwin に組み込む Home Manager の共通設定
      hmIntegration = host: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.nalt = import ./hosts/${host};
        home-manager.extraSpecialArgs = specialArgs;
        home-manager.backupFileExtension = "backup";
      };

      forSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] f;
    in
    {
      homeConfigurations = {
        # WSL環境用プロファイル
        "wsl" = mkHome "wsl";

        # rootless podman (distrobox) コンテナ内のCLI専用プロファイル
        "distrobox" = mkHome "distrobox";

        # 実データ非共有コンテナ(wslc等)内のCLI専用プロファイル
        "sandbox" = mkHome "sandbox";

        # Mac は nix-darwin (darwinConfigurations.mac) 経由の Home Manager に一本化している。
        # スタンドアロン版を併存させると CI が実運用と別の経路を検証することになるため置かない。
      };

      # NixOS環境用プロファイル
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          (hmIntegration "nixos")
        ];
      };

      # Mac (nix-darwin) 環境用プロファイル
      darwinConfigurations."mac" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/mac/darwin.nix
          home-manager.darwinModules.home-manager
          (hmIntegration "mac")
        ];
      };

      # コードフォーマッタ (`nix fmt` でリポジトリ全体を整形)
      formatter = forSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
