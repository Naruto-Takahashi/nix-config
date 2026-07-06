# =========================================================================
# Starship プロンプト宣言的設定モジュール
# =========================================================================
{ config, dotfilesPath, ... }:

{
  # --- Starshipの有効化 ---
  # Starshipプロンプトを有効化します．
  programs.starship = {
    enable = true;
  };

  # --- 設定ファイルの配置 ---
  # starship.toml（フォールバック配色入りテンプレート）のシンボリックリンクを配置します．
  # yasb-themeがmatugenの配色を流し込んだ版を ~/.cache/matugen/starship.toml
  # に生成し，存在すればzshがSTARSHIP_CONFIGでそちらを優先します．
  xdg.configFile."starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/shell/starship.toml";
    force = true;
  };
}
