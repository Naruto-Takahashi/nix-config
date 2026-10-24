# =========================================================================
# Neovim テキストエディタ宣言的設定モジュール
# =========================================================================
{ config, pkgs, dotfilesPath, ... }:

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
      # --- 日常的に開く設定・スクリプト系 ---
      # make は bash がないとレシピ行 (シェルコマンド) が injection されず
      # ハイライトが粗いままになる。必ずセットで入れること。
      "make"
      "bash"
      "nix"
      "toml"
      "yaml"
      "json"
      "css"
      "html"
      "xml"
      "ini"
      "tsx"
      "dockerfile"
      "powershell" # komorebi/YASB まわりの .ps1 用
      "hyprlang" # hyprland.conf 用
      "rasi" # rofi 設定用
      # --- git / ssh 系設定ファイル ---
      "diff"
      "git_rebase"
      "gitcommit"
      "git_config"
      "gitignore"
      "gitattributes"
      "ssh_config"
      "editorconfig"
      "desktop" # .desktop エントリ用
      # --- 他言語への注入専用 (単体では使わない) ---
      "regex" # 各言語内の正規表現リテラル
      "comment" # コメント内の TODO/FIXME 等の構造化
      "luadoc" # lua のアノテーションコメント
      "luap" # lua の string.match パターン
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
    # stateVersion < 26.05 の従来デフォルトを明示 (デフォルト変更警告の抑止)
    withRuby = true;
    withPython3 = true;
    # nvim-treesitter (main) の :TSInstall がNix管理外の言語を追加できるように
    # tree-sitter CLI を同梱します．
    extraPackages = [
      pkgs.tree-sitter
      # masonが落とすビルド済みclangdはNixOSの動的リンカで動かないため，Nixで供給します．
      pkgs.clang-tools
      # masonがzip形式のパッケージを展開する際に必要です．
      pkgs.unzip
      # --- Nix供給の言語サーバー (masonのビルド済みバイナリはNixOSで動かないため) ---
      pkgs.nil # Nix LSP
      pkgs.nixfmt-rfc-style # nil が使うフォーマッタ
      pkgs.bash-language-server # bash/zsh LSP
      pkgs.shellcheck # bash-language-server が診断に使う
      pkgs.shfmt # bash-language-server がフォーマットに使う
      # telescope.nvim (live_grep/find_files) が実行時に呼ぶ外部コマンド。
      # WSL/NixOSはmodules/desktop/packages.nix経由で入るがMacはそれを
      # importしないため、ここで明示的に供給する (eza同様の理由)。
      pkgs.ripgrep
      pkgs.fd
      # telescope-fzf-native.nvim等、buildフックでネイティブ拡張をmakeする
      # プラグイン用。同じ理由でWSL/NixOS以外 (Mac、distrobox) には
      # 無いと"make: command not found"でビルドが失敗し、該当プラグインの
      # config()実行時にエラーになる。
      pkgs.gcc
      pkgs.gnumake
      # marp.nvim が呼び出すMarp CLI本体。npx経由だと毎回ダウンロードが走るため
      # Nix供給のバイナリをPATHに直接置く。
      pkgs.marp-cli
    ];
  };

  # --- 設定ファイルおよびパーサーの配置 ---
  # リポジトリ編集がそのまま反映されるよう mkOutOfStoreSymlink で実ファイルに直結する。
  # home-manager switch 不要でプラグインや Lua 設定のホットリロードが可能。
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/apps/neovim/nvim";

  # ビルド済みのTreesitterパーサーをNeovimのランタイムパスにシンボリックリンクします．
  xdg.dataFile."nvim/site/parser".source = "${treesitter-parsers}/parser";

  # nvim-treesitter (main) は highlights 等のクエリを :TSInstall 時にしか配置しないため，
  # Nix供給パーサーと同一スナップショットのクエリを runtimepath に配置します．
  # (これが無いと Neovim 同梱クエリの無い言語 (python, rust 等) が無色になる)
  xdg.dataFile."nvim/site/queries".source = "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";
}
