{ config, pkgs, ... }:

let
  # NixOS上でC++等のコンパイルリンクエラーを防ぐため、
  # Nixpkgsでビルド済みのパーサー群から .so ファイルを抽出し、フラットな1つのディレクトリにまとめてリンクします。
  treesitter-parsers = pkgs.runCommand "nvim-treesitter-parsers" {} ''
    mkdir -p $out/parser
    ${pkgs.lib.concatMapStringsSep "\n" (lang:
      let
        pkgName = "tree-sitter-${pkgs.lib.replaceStrings ["_"] ["-"] lang}";
        parserPkg = pkgs.vimPlugins.nvim-treesitter.builtGrammars.${pkgName};
      in ''
        ln -sf ${parserPkg}/parser/${lang}.so $out/parser/
      ''
    ) [
      "rust"
      "c"
      "cpp"
      "lua"
      "vim"
      "vimdoc"
      "query"
      "python"
      "javascript"
      "typescript"
      "markdown"
      "markdown_inline"
    ]}
  '';
in
{
  # Neovim パッケージの有効化
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Copilot.lua は Neovim 内で Node.js を使うため、Neovim 自体にも同梱する
    withNodeJs = true;
  };

  # -----------------------------------------------------------------------
  # Neovim 設定ディレクトリの宣言的配置 (ディレクトリ・ソース方式)
  # -----------------------------------------------------------------------
  xdg.configFile."nvim".source = ./nvim;

  # ビルド済みの Treesitter パーサーを Neovim のランタイムパスにシンボリックリンク
  xdg.dataFile."nvim/site/parser".source = "${treesitter-parsers}/parser";
}
