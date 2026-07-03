# =========================================================================
# Starship プロンプト設定モジュール
# =========================================================================
{ config, dotfilesPath, ... }:

{
  # Starship プロンプトの有効化
  programs.starship = {
    enable = true;
  };

  # starship.toml (フォールバック配色入りテンプレート)
  # yasb-theme が matugen の配色を流し込んだ版を ~/.cache/matugen/starship.toml
  # に生成し、存在すれば zsh が STARSHIP_CONFIG でそちらを優先する
  xdg.configFile."starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/shell/starship.toml";
    force = true;
  };
}
