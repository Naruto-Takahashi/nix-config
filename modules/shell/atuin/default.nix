# =========================================================================
# atuin (シェル履歴の検索・記録) 宣言的設定モジュール
# =========================================================================
# Ctrl+R を fzf (ghq 検索等) と同じ文法の見た目の履歴検索 UI に置き換える。
# ↑キーの挙動は通常の zsh 履歴のまま維持する (--disable-up-arrow)。
#
# 見た目の詳細 (選択行の背景・ポインタ色など) は fzf-style.patch による
# ソースパッチで実現している。配色テーマは「theme 名は matugen 固定・
# 中身のファイルを差し替える」方式で、matugen 環境では matugen-apply が
# 壁紙由来の配色で上書きし、無い環境では activation が配置する
# kanagawa-dragon フォールバックが使われ続ける。
{ pkgs, lib, ... }:

{
  programs.atuin = {
    enable = true;
    # fzf 風の見た目にするパッチ (詳細はパッチ先頭のコメント参照)。
    # ソースからの再ビルドが走る。atuin のバージョンアップでパッチが
    # 当たらなくなった場合はビルドエラーで気づける
    package = pkgs.atuin.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./fzf-style.patch ];
      doCheck = false; # テストをスキップしてビルド時間を短縮
    });
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
      inline_height = 20;
      style = "full"; # fzf の --border 風に検索窓・結果リストを枠線付きで表示
      # 検索バーを上・結果を下に (トップダウン)
      invert = true;
      show_tabs = false; # Search/Inspector タブバーを隠してすっきりさせる
      show_help = false; # 最下部の "<esc>: exit ..." キーヘルプを隠す
      # 数字ショートカット (Alt+1..9) は komorebi のワークスペース移動と衝突して
      # 使えず、Ctrl+数字も端末の制約で届かないため、番号表示ごと無効化する
      show_numeric_shortcuts = false;
      # プレビュー: リストは1エントリ=1行の制約があるため、複数行 (\ 継続)
      # コマンドは選択時に下部プレビューで改行構造ごと表示する
      show_preview = true;
      preview.strategy = "auto"; # 1行コマンドは1行分、複数行なら行数に応じて拡大
      max_preview_height = 10;
      # 経過時間 (◯m ago) 列は非表示 (長いコマンドとの表示競合を避ける。
      # 実行時刻などの詳細は Ctrl+O のインスペクタで確認できる)
      ui.columns = [ "duration" "command" ];
      # Enter = 選択したコマンドを即実行 / Tab = プロンプトに挿入して編集
      # (デフォルト false だと Enter も挿入になり Tab と区別がなくなる)
      enter_accept = true;
      # invert=true だと ↑ (SelectPrevious) が index0 (最新側) へ向かう扱いになり、
      # デフォルト (scroll_exits=true) では最上段で ↑ を押すと atuin ごと終了する。
      # 単に選択が止まるだけにしたいので無効化する
      keys.scroll_exits = false;
      update_check = false;
      theme.name = "matugen"; # 実体は下の activation / matugen-apply が配置
    };
  };

  # atuin init は vicmd (viノーマルモード) に '/' しか割り当てず ^R を放置する
  # ため、そのままだと古い fzf の履歴ウィジェットが顔を出す。明示的に上書きする
  programs.zsh.initContent = lib.mkOrder 2000 ''
    bindkey -M vicmd '^r' atuin-search-vicmd
  '';

  # kanagawa-dragon フォールバックテーマのシード (存在しない場合のみ)
  home.activation.seedAtuinTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/atuin/themes"
    [ -f "$HOME/.config/atuin/themes/matugen.toml" ] || \
      cp ${../../theming/matugen/fallbacks/atuin-theme.toml} \
        "$HOME/.config/atuin/themes/matugen.toml"
    chmod u+w "$HOME/.config/atuin/themes/matugen.toml"
  '';
}
