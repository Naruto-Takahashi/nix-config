# =========================================================================
# Neovim テキストエディタ宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

let
  # --- Treesitterパーサーのビルド ---
  # NixOS上でC++などのコンパイルリンクエラーを防ぐため，
  # Nixpkgsでビルド済みのパーサー群から .so ファイルを抽出し，フラットな1つのディレクトリにまとめてリンクします．
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
      "systemverilog" # verilog ファイルタイプ用 (旧 verilog パーサーの後継)
    ]}
  '';
in
{
  # --- Neovimパッケージ設定 ---
  # Neovimパッケージの有効化と基本オプションを設定します．
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Copilot.luaはNeovim内でNode.jsを使うため，Neovim自体にも同梱します．
    withNodeJs = true;
    # nvim-treesitter (main) の :TSInstall がNix管理外の言語を追加できるように
    # tree-sitter CLI を同梱します．
    extraPackages = [ pkgs.tree-sitter ];
  };

  # --- 設定ファイルおよびパーサーの配置 ---
  # Neovim設定ディレクトリの宣言的配置（ディレクトリ・ソース方式）を行います．
  xdg.configFile."nvim".source = ./nvim;

  # ビルド済みのTreesitterパーサーをNeovimのランタイムパスにシンボリックリンクします．
  xdg.dataFile."nvim/site/parser".source = "${treesitter-parsers}/parser";
}
