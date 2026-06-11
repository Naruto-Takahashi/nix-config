# =========================================================================
# Yazi CUI ファイルマネージャ設定モジュール
# =========================================================================
{ config, pkgs, ... }:

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

    -- ステータスバーの無効化
    local s = Status or status
    if s then
        s.render = function(self, area)
            return ui.Line {}
        end
    end
  '';



  # スクリーンショットの色使いを再現したテーマ設定
  xdg.configFile."yazi/theme.toml".text = ''
    #:schema https://yazi-rs.github.io/schemas/theme.json

    [mgr]
    border_style = { fg = "#665c54" }

    [mode]
    # 選択時のティール色の背景 (#5f8787)
    normal_main = { fg = "#1d2021", bg = "#5f8787", bold = true }
    select_main = { fg = "#1d2021", bg = "#fabd2f", bold = true }
    unset_main  = { fg = "#1d2021", bg = "#fb4934", bold = true }

    [filetype]
    rules = [
        # ディレクトリは白文字、アイコンは黄色
        { mime = "*/", fg = "#ffffff", bold = true },
        # メディア・アーカイブは赤/ピンク系
        { mime = "image/*", fg = "#fb4934" },
        { mime = "video/*", fg = "#fb4934" },
        { mime = "application/{zip,rar,7z*,tar,gzip,xz}", fg = "#fb4934" },
        # その他は白
        { mime = "*", fg = "#ffffff" },
    ]

    [indicator]
    # 選択行をシャープな四角形にする
    current = { bg = "#5f8787" }
    parent  = { bg = "#3c3836" }
    preview = { bg = "#5f8787" }
    padding = { open = "", close = "" }

    [icon]
    prepend_dirs = [
        { name = "*", text = "󰉋", fg = "#fabd2f" },
    ]
    conds = [
        { if = "dir",  text = "󰉋", fg = "#fabd2f" },
        { if = "exec", text = "", fg = "#b8bb26" },
        { if = "link", text = "", fg = "#83a598" },
        { if = "!dir", text = "", fg = "#ebdbb2" },
    ]
    prepend_conds = [
        { if = "mime", mime = "image/*", text = "󰈟", fg = "#fb4934" },
        { if = "mime", mime = "video/*", text = "󰈫", fg = "#fb4934" },
        { if = "mime", mime = "application/pdf", text = "󰈦", fg = "#fb4934" },
    ]
  '';





}
