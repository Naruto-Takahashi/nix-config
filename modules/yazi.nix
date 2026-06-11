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

    [flavor]
    dark = "kanagawa-dragon"

    [icon]
    prepend_dirs = [
      { name = "*", text = "󰉋", fg = "#e6c384" }
    ]
    prepend_files = [
      { name = "Cargo.toml", text = "", fg = "#76946a" },
      { name = "config.toml", text = "", fg = "#76946a" },
      { name = "theme.toml", text = "", fg = "#76946a" },
      { name = "yazi.toml", text = "", fg = "#76946a" },
      { name = "desktop.ini", text = "", fg = "#76946a" }
    ]
    prepend_exts = [
      # ドキュメント・テキスト系 (ホワイト/ゴールド/グリーン)
      { name = "md", text = "󰍔", fg = "#76946a" },
      { name = "pdf", text = "󰈦", fg = "#76946a" },
      { name = "docx", text = "󰈬", fg = "#76946a" },
      { name = "xlsx", text = "󰈛", fg = "#76946a" },
      { name = "ini", text = "", fg = "#76946a" },
      { name = "s", text = "󰘦", fg = "#76946a" },
      { name = "sln", text = "󰘦", fg = "#76946a" },
      { name = "out", text = "", fg = "#76946a" },
      { name = "mp4", text = "󰈫", fg = "#a292a3" },
      { name = "txt", text = "", fg = "#76946a" },
      { name = "html", text = "", fg = "#76946a" },
      { name = "exe", text = "", fg = "#76946a" },
      { name = "json", text = "󰘦", fg = "#e6c384" },
      { name = "toml", text = "", fg = "#76946a" },
      { name = "yaml", text = "󰘦", fg = "#e6c384" },
      { name = "yml", text = "󰘦", fg = "#e6c384" },
      # 画像ファイル (イエロー)
      { name = "png", text = "󰈟", fg = "#e6c384" },
      { name = "jpg", text = "󰈟", fg = "#e6c384" },
      { name = "jpeg", text = "󰈟", fg = "#e6c384" },
      { name = "gif", text = "󰈟", fg = "#e6c384" },
      # 圧縮アーカイブ (レッド)
      { name = "zip", text = "", fg = "#e46876" },
      { name = "tar", text = "", fg = "#e46876" },
      { name = "gz", text = "", fg = "#e46876" },
      { name = "7z", text = "", fg = "#e46876" },
      { name = "rar", text = "", fg = "#e46876" },
      # プログラミング言語・スクリプト系 (ブルー/グリーン/レッド)
      { name = "nix", text = "", fg = "#7fb4ca" },
      { name = "go", text = "", fg = "#7fb4ca" },
      { name = "py", text = "", fg = "#76946a" },
      { name = "sh", text = "", fg = "#76946a" },
      { name = "lua", text = "", fg = "#7fb4ca" },
      { name = "rs", text = "", fg = "#e46876" },
      { name = "js", text = "", fg = "#e6c384" },
      { name = "ts", text = "", fg = "#7fb4ca" }
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
