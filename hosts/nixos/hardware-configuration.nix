# =========================================================================
# ハードウェア構成設定のプレースホルダー
# =========================================================================
# 実際の NixOS 環境構築時に，システム側で生成された
# `/etc/nixos/hardware-configuration.nix` の内容でこのファイルを置き換えてください．
# =========================================================================
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/placeholder";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
