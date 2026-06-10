# =========================================================================
# Yazi CUI ファイルマネージャ設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      manager = {
        ratio = [
          1
          2
          4
        ];
      };
      opener = {
        open = [
          {
            run = ''
              if command -v wsl-open >/dev/null 2>&1; then
                wsl-open "$@"
              else
                xdg-open "$@"
              fi
            '';
            orphan = true;
            desc = "Open";
          }
        ];
      };
      open = {
        rules = [
          { mime = "text/*"; use = "edit"; }
          { mime = "*"; use = "open"; }
        ];
      };
    };
  };

  # 公式の Cyberdream Yaziテーマをベースに透過・アイコン色・セパレータを調整して適用
  xdg.configFile."yazi/theme.toml".text = ''
    #:schema https://yazi-rs.github.io/schemas/theme.json

    # アプリケーション全体の背景透過設定
    [app]
    overall = { bg = "reset" }

    [mgr]

    # tmTheme files can be found here: https://github.com/scottmckendry/cyberdream.nvim/tree/main/extras/textmate
    syntect_theme = "../bat/themes/cyberdream.tmTheme"

    border_style = { fg = "#3c4048" }
    cwd = { fg = "#5ef1ff" }
    find_keyword = { bold = true, fg = "#5eff6c" }
    find_position = { fg = "#ffffff" }
    marker_copied = { bg = "#f1ff5e", fg = "#f1ff5e" }
    marker_cut = { bg = "#ff6e5e", fg = "#ff6e5e" }
    marker_selected = { bg = "#3c4048", fg = "#5eff6c" }
    count_selected = { bg = "#5eff6c", fg = "#16181a" }
    count_copied = { bg = "#f1ff5e", fg = "#16181a" }
    count_cut = { bg = "#ff6e5e", fg = "#16181a" }

    [cmp]
    active = { bg = "#7b8496", fg = "#bd5eff" }
    border = { fg = "#5ea1ff" }
    inactive = { fg = "#ffffff" }

    [tabs]
    active = { bg = "#5ea1ff", fg = "#16181a" }
    inactive = { bg = "#3c4048", fg = "#ffffff" }

    [filetype]
    rules = [
        { fg = "#5fa0e6", mime = "image/*" },
        { fg = "#f1ff5e", mime = "video/*" },
        { fg = "#f1ff5e", mime = "audio/*" },
        { fg = "#bd5eff", mime = "application/zip" },
        { fg = "#bd5eff", mime = "application/gzip" },
        { fg = "#bd5eff", mime = "application/x-tar" },
        { fg = "#bd5eff", mime = "application/x-bzip" },
        { fg = "#bd5eff", mime = "application/x-bzip2" },
        { fg = "#bd5eff", mime = "application/x-7z-compressed" },
        { fg = "#bd5eff", mime = "application/x-rar" },
        { fg = "#bd5eff", mime = "application/xz" },
        { fg = "#5eff6c", mime = "application/doc" },
        { fg = "#5eff6c", mime = "application/pdf" },
        { fg = "#5eff6c", mime = "application/rtf" },
        { fg = "#5eff6c", mime = "application/vnd.*" },
        # フォルダ（ディレクトリ）テキストの色をcyberdream Directoryハイライト（#5ea1ff）に統一
        { fg = "#5ea1ff", url = "*/" },
        { fg = "#ffffff", url = "*" }
    ]

    # ディレクトリアイコンを塗りつぶし（󰉋）にし，色をcyberdream Directoryハイライト（#5ea1ff）に統一
    [icon]
    prepend_conds = [
        { if = "dir", text = "󰉋", fg = "#5ea1ff" }
    ]
    prepend_dirs = [
        { name = ".config", text = "󰉋", fg = "#ff9800" },
        { name = ".git", text = "󰉋", fg = "#00bcd4" }
    ]

    # 選択されている行（current）と親ディレクトリ行（parent）の背景色を
    # nvimのCursorLine（cyberdream bg_highlight = #3c4048）に合わせて設定
    # 両サイドの半円（rounded shapes）を取り除くために padding をスペース（" "）に設定
    [indicator]
    current = { bg = "#3c4048" }
    parent  = { bg = "#3c4048" }
    preview = { bg = "reset", underline = true }
    padding = { open = " ", close = " " }

    [help]
    desc = { fg = "#ffffff" }
    footer = { fg = "#ffffff" }
    hovered = { bg = "#7b8496", fg = "#ffffff" }
    on = { fg = "#bd5eff" }
    run = { fg = "#5fa0e6" }

    [input]
    border = { fg = "#5ea1ff" }
    selected = { bg = "#7b8496" }
    title = { fg = "#ffffff" }
    value = { fg = "#ffffff" }

    [pick]
    active = { fg = "#bd5eff" }
    border = { fg = "#5ea1ff" }
    inactive = { fg = "#ffffff" }

    # モード表示の背景を完全に透過させ，文字色のみにする（bg = "reset"）
    [mode]
    normal_main = { bold = true, fg = "#5ea1ff", bg = "reset" }
    normal_alt  = { fg = "#7b8496", bg = "reset" }
    select_main = { bold = true, fg = "#5eff6c", bg = "reset" }
    select_alt  = { fg = "#7b8496", bg = "reset" }
    unset_main = { bold = true, fg = "#ff5ef1", bg = "reset" }
    unset_alt  = { fg = "#7b8496", bg = "reset" }

    # ステータスバー全体の背景透過のため，セパレータとprogress設定のbg指定をresetにする
    # 左側のセパレータ（sep_left）を無くし，右側にのみ '<' のような形（ または ）を残す
    # 懸案だった percentage や position（Top, 4K等）の背景も完全に透過（bg = "reset"）させる
    [status]
    sep_left  = { open = "", close = "" }
    sep_right = { open = "", close = "" }
    perm_sep = { fg = "#5ea1ff", bg = "reset" }
    perm_type = { fg = "#5ea1ff", bg = "reset" }
    perm_read = { fg = "#f1ff5e", bg = "reset" }
    perm_write = { fg = "#ff6e5e", bg = "reset" }
    perm_exec = { fg = "#5eff6c", bg = "reset" }
    progress_error = { fg = "#ff6e5e", bg = "reset" }
    progress_label = { fg = "#ffffff", bg = "reset" }
    progress_normal = { fg = "#ffffff", bg = "reset" }
    # 右側のパーセンテージ（percentage）およびファイル位置（position）を透過
    percentage = { fg = "#ffffff", bg = "reset" }
    position = { fg = "#ffffff", bg = "reset" }

    [tasks]
    border = { fg = "#5ea1ff" }
    hovered = { bg = "#7b8496", fg = "#ffffff" }
    title = { fg = "#ffffff" }

    [which]
    cand = { fg = "#5ef1ff" }
    desc = { fg = "#ffffff" }
    mask = { bg = "#3c4048" }
    rest = { fg = "#ff5ef1" }
    separator_style = { fg = "#7b8496" }
  '';
}
