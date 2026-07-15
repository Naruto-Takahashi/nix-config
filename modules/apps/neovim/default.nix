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
        # builtGrammars の各パッケージは $out/parser 自体がELF共有ライブラリ
        ln -sf ${parserPkg}/parser $out/parser/${lang}.so
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

  # --- nvim設定ディレクトリと共通Luaライブラリの合成 ---
  # blend.lua (2色補間) は yazi (modules/apps/yazi) とも共有しているため
  # modules/theming/lua-lib に置き、ここでは nvim の lua/ 配下にコピーする。
  nvimConfigDir = pkgs.runCommand "nvim-config" {} ''
    cp -r ${./nvim} $out
    chmod -R u+w $out
    cp ${../../theming/lua-lib/blend.lua} $out/lua/blend.lua
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
    extraPackages = [
      pkgs.tree-sitter
      # masonが落とすビルド済みclangdはNixOSの動的リンカで動かないため，Nixで供給します．
      pkgs.clang-tools
      # masonがzip形式のパッケージを展開する際に必要です．
      pkgs.unzip
    ];
  };

  # --- 設定ファイルおよびパーサーの配置 ---
  # Neovim設定ディレクトリの宣言的配置（ディレクトリ・ソース方式）を行います．
  xdg.configFile."nvim".source = nvimConfigDir;

  # ビルド済みのTreesitterパーサーをNeovimのランタイムパスにシンボリックリンクします．
  xdg.dataFile."nvim/site/parser".source = "${treesitter-parsers}/parser";

  # nvim-treesitter (main) は highlights 等のクエリを :TSInstall 時にしか配置しないため，
  # Nix供給パーサーと同一スナップショットのクエリを runtimepath に配置します．
  # (これが無いと Neovim 同梱クエリの無い言語 (python, rust 等) が無色になる)
  xdg.dataFile."nvim/site/queries".source = "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";
}
