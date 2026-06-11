# =========================================================================
# Yazi CUI ファイルマネージャ設定モジュール
# =========================================================================
{ config, pkgs, kanagawa-dragon-yazi, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      mgr = {
        ratio = [
          1
          2
          4
        ];
        show_symlink = false;
        linemode = "size";
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

    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "K" ];
          run = "seek -5";
          desc = "Seek up 5 units in the preview";
        }
        {
          on = [ "J" ];
          run = "seek 5";
          desc = "Seek down 5 units in the preview";
        }
        {
          on = [ "<C-y>" ];
          run = "seek -1";
          desc = "Seek up 1 unit in the preview";
        }
        {
          on = [ "<C-e>" ];
          run = "seek 1";
          desc = "Seek down 1 unit in the preview";
        }
      ];
    };
  };

  # スクリーンショットに基づいたUIロジックの刷新（フルボーダー、カスタムヘッダー等）
  xdg.configFile."yazi/init.lua".text = ''
    ---@diagnostic disable: undefined-global

    -- Full borders and vertical separators logic
    -- Yaziのバージョンによって Manager または mgr がグローバルに存在するため、両方に対応
    local m = Manager or mgr
    if m then
        m.render = function(self, area)
            local chunks = self:layout(area)
            return ya.flat {
                -- 全体の枠線
                ui.Border(area, ui.Border.ALL):fg("#665c54"),
                -- 垂直セパレータ (ParentとCurrentの間)
                ui.Bar(chunks[1]:right() - 1, chunks[1].y, 1, chunks[1].h, ui.Bar.VERTICAL):symbol("│"):fg("#665c54"),
                -- 垂直セパレータ (CurrentとPreviewの間)
                ui.Bar(chunks[2]:right() - 1, chunks[2].y, 1, chunks[2].h, ui.Bar.VERTICAL):symbol("│"):fg("#665c54"),

                -- 各ペインのレンダリング
                Parent:render(chunks[1]:padding(ui.Padding.y(1))),
                Current:render(chunks[2]:padding(ui.Padding.y(1))),
                Preview:render(chunks[3]:padding(ui.Padding.y(1))),
            }
        end
    end

    -- ヘッダーのカスタマイズ
    local h = Header or header
    if h then
        h.render = function(self, area)
            local chunks = self:layout(area)
            local left = ui.Line {
                ui.Span(ya.user_name() .. "@" .. ya.host_name()):fg("#b8bb26"):bold(true),
                ui.Span(":"):fg("#ebdbb2"),
                ui.Span(ya.readable_path(tostring(self._current.cwd))):fg("#83a598"),
            }
            return ui.Canvas(area, function(c)
                c:draw_str(left, chunks[1].x, chunks[1].y)
            end)
        end
    end
  '';



  # フレーバーリポジトリの配置
  xdg.configFile."yazi/flavors/kanagawa-dragon.yazi".source = kanagawa-dragon-yazi;

  # スクリーンショットの色使いを再現したテーマ設定
  xdg.configFile."yazi/theme.toml".text = ''
    #:schema https://yazi-rs.github.io/schemas/theme.json

    [filetype]
    rules = [
      # 特定ファイル
      { url = "**/Cargo.toml", fg = "#76946a" },
      { url = "**/config.toml", fg = "#76946a" },
      { url = "**/theme.toml", fg = "#76946a" },
      { url = "**/yazi.toml", fg = "#76946a" },
      { url = "**/desktop.ini", fg = "#76946a" },
      { url = "**/.env*", fg = "#e6c384" },
      # ドキュメント・テキスト系 (Green: #76946a)
      { url = "**.md", fg = "#76946a" },
      { url = "**.pdf", fg = "#76946a" },
      { url = "**.txt", fg = "#76946a" },
      { url = "**.log", fg = "#76946a" },
      { url = "**.csv", fg = "#76946a" },
      { url = "**.docx", fg = "#76946a" },
      { url = "**.doc", fg = "#76946a" },
      { url = "**.xlsx", fg = "#76946a" },
      { url = "**.xls", fg = "#76946a" },
      { url = "**.pptx", fg = "#76946a" },
      { url = "**.ppt", fg = "#76946a" },
      { url = "**.ini", fg = "#76946a" },
      { url = "**.toml", fg = "#76946a" },
      { url = "**.tex", fg = "#76946a" },
      { url = "**.bib", fg = "#76946a" },
      { url = "**.odt", fg = "#76946a" },
      { url = "**.ods", fg = "#76946a" },
      { url = "**.html", fg = "#76946a" },
      { url = "**.htm", fg = "#76946a" },
      { url = "**.xhtml", fg = "#76946a" },
      # ビデオ・オーディオ系 (Purple: #a292a3)
      { url = "**.mp4", fg = "#a292a3" },
      { url = "**.mkv", fg = "#a292a3" },
      { url = "**.avi", fg = "#a292a3" },
      { url = "**.mov", fg = "#a292a3" },
      { url = "**.wmv", fg = "#a292a3" },
      { url = "**.flv", fg = "#a292a3" },
      { url = "**.webm", fg = "#a292a3" },
      { url = "**.mp3", fg = "#a292a3" },
      { url = "**.wav", fg = "#a292a3" },
      { url = "**.flac", fg = "#a292a3" },
      { url = "**.m4a", fg = "#a292a3" },
      { url = "**.ogg", fg = "#a292a3" },
      # 画像ファイル (Yellow: #e6c384)
      { url = "**.png", fg = "#e6c384" },
      { url = "**.jpg", fg = "#e6c384" },
      { url = "**.jpeg", fg = "#e6c384" },
      { url = "**.gif", fg = "#e6c384" },
      { url = "**.webp", fg = "#e6c384" },
      { url = "**.svg", fg = "#e6c384" },
      { url = "**.ico", fg = "#e6c384" },
      { url = "**.bmp", fg = "#e6c384" },
      { url = "**.tiff", fg = "#e6c384" },
      { url = "**.heic", fg = "#e6c384" },
      # 圧縮アーカイブ・実行ファイル (Red: #e46876)
      { url = "**.zip", fg = "#e46876" },
      { url = "**.tar", fg = "#e46876" },
      { url = "**.gz", fg = "#e46876" },
      { url = "**.7z", fg = "#e46876" },
      { url = "**.rar", fg = "#e46876" },
      { url = "**.bz2", fg = "#e46876" },
      { url = "**.xz", fg = "#e46876" },
      { url = "**.zst", fg = "#e46876" },
      { url = "**.deb", fg = "#e46876" },
      { url = "**.rpm", fg = "#e46876" },
      { url = "**.iso", fg = "#e46876" },
      { url = "**.img", fg = "#e46876" },
      { url = "**.rs", fg = "#e46876" }, # Rust (Red)
      # プログラミング・データ系 (Blue: #7fb4ca)
      { url = "**.nix", fg = "#7fb4ca" },
      { url = "**.go", fg = "#7fb4ca" },
      { url = "**.lua", fg = "#7fb4ca" },
      { url = "**.cpp", fg = "#7fb4ca" },
      { url = "**.c", fg = "#7fb4ca" },
      { url = "**.h", fg = "#7fb4ca" },
      { url = "**.hpp", fg = "#7fb4ca" },
      { url = "**.cs", fg = "#7fb4ca" },
      { url = "**.java", fg = "#7fb4ca" },
      { url = "**.kt", fg = "#7fb4ca" },
      { url = "**.swift", fg = "#7fb4ca" },
      { url = "**.dart", fg = "#7fb4ca" },
      { url = "**.ts", fg = "#7fb4ca" },
      { url = "**.sql", fg = "#7fb4ca" },
      # スクリプト・設定データ系 (Mixed)
      { url = "**.py", fg = "#76946a" },
      { url = "**.sh", fg = "#76946a" },
      { url = "**.rb", fg = "#76946a" },
      { url = "**.php", fg = "#76946a" },
      { url = "**.js", fg = "#e6c384" },
      { url = "**.json", fg = "#e6c384" },
      { url = "**.jsonc", fg = "#e6c384" },
      { url = "**.yaml", fg = "#e6c384" },
      { url = "**.yml", fg = "#e6c384" },
      { url = "**.lock", fg = "#e6c384" },
      # バイナリ・その他 (Fallback)
      { url = "**.exe", fg = "#76946a" },
      { url = "**.out", fg = "#76946a" },
      { url = "**/", fg = "#8ba4b0" }, # ディレクトリ
      { url = "*", fg = "#c5c9c5" }   # その他
    ]

    [flavor]
    dark = "kanagawa-dragon"

    [icon]
    prepend_dirs = [
      { name = "Desktop", text = "󰉋", fg = "#e6c384" },
      { name = "Downloads", text = "󰉋", fg = "#e6c384" },
      { name = "Documents", text = "󰉋", fg = "#e6c384" },
      { name = "Pictures", text = "󰉋", fg = "#e6c384" },
      { name = "Music", text = "󰉋", fg = "#e6c384" },
      { name = "Videos", text = "󰉋", fg = "#e6c384" },
      { name = "Public", text = "󰉋", fg = "#e6c384" },
      { name = "Templates", text = "󰉋", fg = "#e6c384" }
    ]
    prepend_files = [
      { name = "Cargo.toml", text = "", fg = "#76946a" },
      { name = "config.toml", text = "", fg = "#76946a" },
      { name = "theme.toml", text = "", fg = "#76946a" },
      { name = "yazi.toml", text = "", fg = "#76946a" },
      { name = "desktop.ini", text = "", fg = "#76946a" }
    ]
    prepend_exts = [
      # ドキュメント・テキスト系 (Green: #76946a)
      { name = "md", text = "󰍔", fg = "#76946a" },
      { name = "pdf", text = "󰈦", fg = "#76946a" },
      { name = "txt", text = "", fg = "#76946a" },
      { name = "log", text = "", fg = "#76946a" },
      { name = "csv", text = "󰈛", fg = "#76946a" },
      { name = "docx", text = "󰈬", fg = "#76946a" },
      { name = "doc", text = "󰈬", fg = "#76946a" },
      { name = "xlsx", text = "󰈛", fg = "#76946a" },
      { name = "xls", text = "󰈛", fg = "#76946a" },
      { name = "pptx", text = "󰈫", fg = "#76946a" },
      { name = "ppt", text = "󰈫", fg = "#76946a" },
      { name = "ini", text = "", fg = "#76946a" },
      { name = "toml", text = "", fg = "#76946a" },
      { name = "tex", text = "󰙩", fg = "#76946a" },
      { name = "bib", text = "󰙩", fg = "#76946a" },
      { name = "html", text = "", fg = "#76946a" },
      # ビデオ・オーディオ系 (Purple: #a292a3)
      { name = "mp4", text = "󰈫", fg = "#a292a3" },
      { name = "mkv", text = "󰈫", fg = "#a292a3" },
      { name = "avi", text = "󰈫", fg = "#a292a3" },
      { name = "mov", text = "󰈫", fg = "#a292a3" },
      { name = "webm", text = "󰈫", fg = "#a292a3" },
      { name = "mp3", text = "󰎈", fg = "#a292a3" },
      { name = "wav", text = "󰎈", fg = "#a292a3" },
      { name = "flac", text = "󰎈", fg = "#a292a3" },
      { name = "m4a", text = "󰎈", fg = "#a292a3" },
      { name = "ogg", text = "󰎈", fg = "#a292a3" },
      # 画像ファイル (Yellow: #e6c384)
      { name = "png", text = "󰈟", fg = "#e6c384" },
      { name = "jpg", text = "󰈟", fg = "#e6c384" },
      { name = "jpeg", text = "󰈟", fg = "#e6c384" },
      { name = "gif", text = "󰈟", fg = "#e6c384" },
      { name = "webp", text = "󰈟", fg = "#e6c384" },
      { name = "svg", text = "󰈟", fg = "#e6c384" },
      { name = "ico", text = "󰈟", fg = "#e6c384" },
      # 圧縮アーカイブ (Red: #e46876)
      { name = "zip", text = "", fg = "#e46876" },
      { name = "tar", text = "", fg = "#e46876" },
      { name = "gz", text = "", fg = "#e46876" },
      { name = "7z", text = "", fg = "#e46876" },
      { name = "rar", text = "", fg = "#e46876" },
      { name = "bz2", text = "", fg = "#e46876" },
      { name = "xz", text = "", fg = "#e46876" },
      { name = "zst", text = "", fg = "#e46876" },
      { name = "iso", text = "󰭆", fg = "#e46876" },
      { name = "img", text = "󰭆", fg = "#e46876" },
      # プログラミング言語・スクリプト系 (Mixed)
      { name = "nix", text = "", fg = "#7fb4ca" },
      { name = "go", text = "", fg = "#7fb4ca" },
      { name = "lua", text = "", fg = "#7fb4ca" },
      { name = "rs", text = "", fg = "#e46876" },
      { name = "cpp", text = "", fg = "#7fb4ca" },
      { name = "c", text = "", fg = "#7fb4ca" },
      { name = "h", text = "", fg = "#7fb4ca" },
      { name = "hpp", text = "", fg = "#7fb4ca" },
      { name = "cs", text = "󰌛", fg = "#7fb4ca" },
      { name = "java", text = "", fg = "#7fb4ca" },
      { name = "kt", text = "", fg = "#7fb4ca" },
      { name = "ts", text = "", fg = "#7fb4ca" },
      { name = "js", text = "", fg = "#e6c384" },
      { name = "py", text = "", fg = "#76946a" },
      { name = "sh", text = "", fg = "#76946a" },
      { name = "json", text = "󰘦", fg = "#e6c384" },
      { name = "yaml", text = "󰘦", fg = "#e6c384" },
      { name = "yml", text = "󰘦", fg = "#e6c384" }
    ]
    prepend_conds = [
      { if = "dir", text = "󰉋", fg = "#e6c384" },
      { if = "exec", text = "", fg = "#76946a" },
      { if = "link", text = "", fg = "#7fb4ca" },
      { if = "mime", mime = "image/*", text = "󰈟", fg = "#e6c384" },
      { if = "mime", mime = "video/*", text = "󰈫", fg = "#a292a3" },
      { if = "mime", mime = "application/pdf", text = "󰈦", fg = "#6a9589" },
      # 一般ファイルのデフォルト（ホワイト）
      { if = "!dir", text = "", fg = "#c5c9c5" }
    ]
  '';
}
