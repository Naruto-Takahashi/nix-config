# =========================================================================
# Yazi CUI ファイルマネージャ設定モジュール
# =========================================================================
{ config, pkgs, kanagawa-dragon-yazi, ... }:

{
  # --- Yaziの基本設定 ---
  # Yaziの有効化，およびZsh連携，表示設定を設定します．
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

      preview = {
        wrap = "yes";
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

    # キーマップ設定
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

  # --- UIロジック設定 (init.lua) ---
  # スクリーンショットに基づいたUIロジックの刷新（フルボーダー，カスタムヘッダー等）を行います．
  xdg.configFile."yazi/init.lua".text = ''
    ---@diagnostic disable: undefined-global

    -- matugen配色（フォールバック #e46876）．無い環境ではフォールバックを使用します．
    -- yaziのLuaランタイムではdofileが使えないため，io.open + パターンマッチで読み込みます．
    local path_color = "#e46876"
    do
      local ok, res = pcall(function()
        local home = os.getenv("HOME")
        if not home then return nil end
        local fh = io.open(home .. "/.cache/matugen/colors.lua", "r")
        if not fh then return nil end
        local s = fh:read("*a")
        fh:close()
        return s:match('accent%s*=%s*"(#%x+)"')
      end)
      if ok and res then
        path_color = res
      end
    end

    -- yazi 26+ ではコンポーネントのrender差し替えが効かないため，
    -- テーマ（th.mgr.cwd）を直接上書きしてヘッダーのパス色を変更します．
    pcall(function()
      th.mgr.cwd = ui.Style():fg(path_color)
    end)

    -- ステータスバー: Starship プロンプト / nvim lualine と同じデザイン．
    --   モードセグメント = matugen accent 系 + Bold，鋭角 powerline 矢印で接続
    do
      local pal = {}
      local fh = io.open((os.getenv("HOME") or "") .. "/.cache/matugen/colors.lua", "r")
      if fh then
        local s = fh:read("*a")
        fh:close()
        for k, v in s:gmatch('([%w_]+)%s*=%s*"(#%x+)"') do pal[k] = v end
      end
      if pal.accent and pal.on_accent and pal.surface then
        pcall(function()
          -- Normal = accent / Select = accent_sub / Unset = muted (lualine と同じ割当)
          th.mode.normal_main = ui.Style():fg(pal.on_accent):bg(pal.accent):bold()
          th.mode.normal_alt  = ui.Style():fg(pal.accent):bg(pal.surface)
          local vis = pal.visual or pal.accent_sub
          th.mode.select_main = ui.Style():fg(pal.on_accent):bg(vis):bold()
          th.mode.select_alt  = ui.Style():fg(vis):bg(pal.surface)
          th.mode.unset_main  = ui.Style():fg(pal.on_accent):bg(pal.muted):bold()
          th.mode.unset_alt   = ui.Style():fg(pal.muted):bg(pal.surface)
          -- 丸型ではなく Starship と同じ鋭角矢印
          th.status.sep_left  = { open = "", close = "\u{e0b0}" }
          th.status.sep_right = { open = "\u{e0b2}", close = "" }
          -- フレーバーがバー全体 (overall) に敷く青背景を無効化し端末地に馴染ませる
          th.status.overall = ui.Style():fg(pal.text)
          -- パーセンテージ (progress) セグメントもフレーバーの青からパレット色へ
          th.status.progress_label  = ui.Style():fg(pal.text):bold()
          th.status.progress_normal = ui.Style():fg(pal.accent):bg(pal.surface)
          th.status.progress_error  = ui.Style():fg("#c4746e"):bg(pal.surface)
        end)

        -- Starship の左端と同じ装飾ブロックをモードセグメントの前に追加。
        -- Normal は secondary、他モードはモード色を白側に寄せたパステル版
        local function blend(h1, h2, t)
          local r1, g1, b1 = tonumber(h1:sub(2, 3), 16), tonumber(h1:sub(4, 5), 16), tonumber(h1:sub(6, 7), 16)
          local r2, g2, b2 = tonumber(h2:sub(2, 3), 16), tonumber(h2:sub(4, 5), 16), tonumber(h2:sub(6, 7), 16)
          return string.format("#%02x%02x%02x",
            math.floor(r1 + (r2 - r1) * t + 0.5),
            math.floor(g1 + (g2 - g1) * t + 0.5),
            math.floor(b1 + (b2 - b1) * t + 0.5))
        end
        pcall(function()
          Status:children_add(function()
            local mode = tostring(cx.active.mode)
            local mode_bg = pal.accent
            -- secondary が無いパレット(旧テンプレート)でも壊れないようフォールバック
            local block_bg = pal.secondary or pal.accent_sub
            if mode == "select" then
              mode_bg = pal.visual or pal.accent_sub
              block_bg = blend(mode_bg, "#ffffff", 0.4)
            elseif mode == "unset" then
              mode_bg = pal.muted
              block_bg = blend(mode_bg, "#ffffff", 0.4)
            end
            return ui.Line {
              ui.Span(" "):style(ui.Style():bg(block_bg)),
              ui.Span("\u{e0b0}"):style(ui.Style():fg(block_bg):bg(mode_bg)),
            }
          end, 100, Status.LEFT)
        end)

        -- 既定のモード表示は3文字略記 (NOR/SEL/UNS) のため、フル表記に置き換える
        pcall(function()
          -- 既定コンポーネントの id は登録順 (mode=1, size=2, name=3)
          Status:children_remove(1, Status.LEFT)
          Status:children_add(function()
            local mode = tostring(cx.active.mode)
            local bg = pal.accent
            if mode == "select" then bg = pal.visual or pal.accent_sub
            elseif mode == "unset" then bg = pal.muted end
            return ui.Line {
              ui.Span(" " .. mode:upper() .. " "):style(ui.Style():fg(pal.on_accent):bg(bg):bold()),
              ui.Span("\u{e0b0}"):style(ui.Style():fg(bg):bg(pal.surface)),
            }
          end, 1000, Status.LEFT)
        end)
      end
    end

    -- フルボーダー（yazi 26 API / 公式 full-borderプラグイン相当）．
    pcall(function()
      th.mgr.border_style = ui.Style():fg("#665c54")
      local old_build = Tab.build

      Tab.build = function(self, ...)
        local bar = function(c, x, y)
          if x <= 0 or x == self._area.w - 1 or th.mgr.border_symbol ~= "│" then
            return ui.Bar(ui.Edge.TOP)
          end

          return ui.Bar(ui.Edge.TOP)
            :area(ui.Rect {
              x = x,
              y = math.max(0, y),
              w = ya.clamp(0, self._area.w - x, 1),
              h = math.min(1, self._area.h),
            })
            :symbol(c)
        end

        local c = self._chunks
        self._chunks = {
          c[1]:pad(ui.Pad.y(1)),
          c[2]:pad(ui.Pad.y(1)),
          c[3]:pad(ui.Pad.y(1)),
        }

        local style = th.mgr.border_style
        self._base = ya.list_merge(self._base or {}, {
          ui.Border(ui.Edge.ALL):area(self._area):type(ui.Border.ROUNDED):style(style),

          bar("┬", c[2].x, c[1].y),
          bar("┴", c[2].x, c[1].bottom - 1),
          bar("┬", c[2].right - 1, c[2].y),
          bar("┴", c[2].right - 1, c[2].bottom - 1),
        })

        old_build(self, ...)
      end
    end)
  '';

  # --- フレーバー設定 ---
  # フレーバーリポジトリの配置を行います．
  xdg.configFile."yazi/flavors/kanagawa-dragon.yazi".source = kanagawa-dragon-yazi;

  # --- テーマ設定 (theme.toml) ---
  # スクリーンショットの色使いを再現したテーマ設定を行います．
  xdg.configFile."yazi/theme.toml".text = ''
    #:schema https://yazi-rs.github.io/schemas/theme.json

    [manager]
    cwd = { fg = "#e46876" }

    [mgr]
    cwd = { fg = "#e46876" }

    [filetype]
    rules = [
      # 特定ファイル
      { url = "**/Cargo.toml", fg = "#e46876" },
      { url = "**/config.toml", fg = "#e6c384" },
      { url = "**/theme.toml", fg = "#e6c384" },
      { url = "**/yazi.toml", fg = "#e6c384" },
      { url = "**/desktop.ini", fg = "#76946a" },
      { url = "**/.env*", fg = "#e6c384" },
      { url = "**/Dockerfile", fg = "#76946a" },
      # ドキュメント・テキスト・インフラ系 (Green: #76946a)
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
      { url = "**.nix", fg = "#76946a" },
      { url = "**.sql", fg = "#76946a" },
      # スクリプト・メディア系 (Purple: #a292a3)
      { url = "**.py", fg = "#a292a3" },
      { url = "**.sh", fg = "#a292a3" },
      { url = "**.lua", fg = "#a292a3" },
      { url = "**.rb", fg = "#a292a3" },
      { url = "**.php", fg = "#a292a3" },
      { url = "**.pl", fg = "#a292a3" },
      { url = "**.mp4", fg = "#a292a3" },
      { url = "**.mkv", fg = "#a292a3" },
      { url = "**.avi", fg = "#a292a3" },
      { url = "**.mov", fg = "#a292a3" },
      { url = "**.webm", fg = "#a292a3" },
      { url = "**.mp3", fg = "#a292a3" },
      { url = "**.wav", fg = "#a292a3" },
      { url = "**.flac", fg = "#a292a3" },
      { url = "**.m4a", fg = "#a292a3" },
      { url = "**.ogg", fg = "#a292a3" },
      # Web・データ系 (Yellow: #e6c384)
      { url = "**.js", fg = "#e6c384" },
      { url = "**.ts", fg = "#e6c384" },
      { url = "**.jsx", fg = "#e6c384" },
      { url = "**.tsx", fg = "#e6c384" },
      { url = "**.json", fg = "#e6c384" },
      { url = "**.jsonc", fg = "#e6c384" },
      { url = "**.yaml", fg = "#e6c384" },
      { url = "**.yml", fg = "#e6c384" },
      { url = "**.toml", fg = "#e6c384" },
      { url = "**.lock", fg = "#e6c384" },
      { url = "**.html", fg = "#e6c384" },
      { url = "**.htm", fg = "#e6c384" },
      { url = "**.css", fg = "#e6c384" },
      { url = "**.scss", fg = "#e6c384" },
      { url = "**.png", fg = "#e6c384" },
      { url = "**.jpg", fg = "#e6c384" },
      { url = "**.jpeg", fg = "#e6c384" },
      { url = "**.gif", fg = "#e6c384" },
      { url = "**.webp", fg = "#e6c384" },
      { url = "**.svg", fg = "#e6c384" },
      # コンパイル言語・アーカイブ (Red: #e46876)
      { url = "**.rs", fg = "#e46876" },
      { url = "**.cpp", fg = "#e46876" },
      { url = "**.c", fg = "#e46876" },
      { url = "**.h", fg = "#e46876" },
      { url = "**.hpp", fg = "#e46876" },
      { url = "**.go", fg = "#e46876" },
      { url = "**.java", fg = "#e46876" },
      { url = "**.kt", fg = "#e46876" },
      { url = "**.cs", fg = "#e46876" },
      { url = "**.swift", fg = "#e46876" },
      { url = "**.zip", fg = "#e46876" },
      { url = "**.tar", fg = "#e46876" },
      { url = "**.gz", fg = "#e46876" },
      { url = "**.7z", fg = "#e46876" },
      { url = "**.rar", fg = "#e46876" },
      { url = "**.xz", fg = "#e46876" },
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
      { name = "config.toml", text = "", fg = "#e6c384" },
      { name = "theme.toml", text = "", fg = "#e6c384" },
      { name = "yazi.toml", text = "", fg = "#e6c384" },
      { name = "desktop.ini", text = "", fg = "#76946a" },
      { name = "package-lock.json", text = "󰘦", fg = "#e6c384" },
      { name = "pnpm-lock.yaml", text = "󰘦", fg = "#e6c384" },
      { name = "flake.lock", text = "󰘦", fg = "#e6c384" }
    ]
    prepend_globs = [
      # 特定ファイル
      { url = "**/Cargo.toml", text = "", fg = "#e46876" },
      { url = "**/config.toml", text = "", fg = "#e6c384" },
      { url = "**/theme.toml", text = "", fg = "#e6c384" },
      { url = "**/yazi.toml", text = "", fg = "#e6c384" },
      { url = "**/desktop.ini", text = "", fg = "#76946a" },
      { url = "**/package-lock.json", text = "󰘦", fg = "#e6c384" },
      { url = "**/pnpm-lock.yaml", text = "󰘦", fg = "#e6c384" },
      { url = "**/flake.lock", text = "󰘦", fg = "#e6c384" },
      { url = "**/Dockerfile", text = "󰡨", fg = "#76946a" },
      # ドキュメント・テキスト・インフラ系 (Green: #76946a)
      { url = "**.md", text = "󰍔", fg = "#76946a" },
      { url = "**.pdf", text = "󰈦", fg = "#76946a" },
      { url = "**.txt", text = "", fg = "#76946a" },
      { url = "**.log", text = "", fg = "#76946a" },
      { url = "**.csv", text = "󰈛", fg = "#76946a" },
      { url = "**.docx", text = "󰈬", fg = "#76946a" },
      { url = "**.doc", text = "󰈬", fg = "#76946a" },
      { url = "**.xlsx", text = "󰈛", fg = "#76946a" },
      { url = "**.xls", text = "󰈛", fg = "#76946a" },
      { url = "**.pptx", text = "󰈫", fg = "#76946a" },
      { url = "**.ppt", text = "󰈫", fg = "#76946a" },
      { url = "**.ini", text = "", fg = "#76946a" },
      { url = "**.toml", text = "", fg = "#76946a" },
      { url = "**.tex", text = "󰙩", fg = "#76946a" },
      { url = "**.bib", text = "󰙩", fg = "#76946a" },
      { url = "**.nix", text = "", fg = "#76946a" },
      { url = "**.sql", text = "", fg = "#76946a" },
      { url = "**.exe", text = "", fg = "#76946a" },
      { url = "**.out", text = "", fg = "#76946a" },
      # スクリプト・メディア系 (Purple: #a292a3)
      { url = "**.py", text = "", fg = "#a292a3" },
      { url = "**.sh", text = "", fg = "#a292a3" },
      { url = "**.lua", text = "", fg = "#a292a3" },
      { url = "**.rb", text = "", fg = "#a292a3" },
      { url = "**.php", text = "", fg = "#a292a3" },
      { url = "**.pl", text = "", fg = "#a292a3" },
      { url = "**.mp4", text = "󰈫", fg = "#a292a3" },
      { url = "**.mkv", text = "󰈫", fg = "#a292a3" },
      { url = "**.mov", text = "󰈫", fg = "#a292a3" },
      { url = "**.webm", text = "󰈫", fg = "#a292a3" },
      { url = "**.mp3", text = "󰎈", fg = "#a292a3" },
      { url = "**.wav", text = "󰎈", fg = "#a292a3" },
      { url = "**.flac", text = "󰎈", fg = "#a292a3" },
      { url = "**.m4a", text = "󰎈", fg = "#a292a3" },
      { url = "**.ogg", text = "󰎈", fg = "#a292a3" },
      # Web・データ系 (Yellow: #e6c384)
      { url = "**.html", text = "", fg = "#e6c384" },
      { url = "**.htm", text = "", fg = "#e6c384" },
      { url = "**.js", text = "", fg = "#e6c384" },
      { url = "**.ts", text = "", fg = "#e6c384" },
      { url = "**.jsx", text = "", fg = "#e6c384" },
      { url = "**.tsx", text = "", fg = "#e6c384" },
      { url = "**.json", text = "󰘦", fg = "#e6c384" },
      { url = "**.jsonc", text = "󰘦", fg = "#e6c384" },
      { url = "**.yaml", text = "󰘦", fg = "#e6c384" },
      { url = "**.yml", text = "󰘦", fg = "#e6c384" },
      { url = "**.lock", text = "󰘦", fg = "#e6c384" },
      { url = "**.css", text = "", fg = "#e6c384" },
      { url = "**.scss", text = "", fg = "#e6c384" },
      { url = "**.png", text = "󰈟", fg = "#e6c384" },
      { url = "**.jpg", text = "󰈟", fg = "#e6c384" },
      { url = "**.jpeg", text = "󰈟", fg = "#e6c384" },
      { url = "**.webp", text = "󰈟", fg = "#e6c384" },
      { url = "**.svg", text = "󰈟", fg = "#e6c384" },
      # コンパイル言語・アーカイブ (Red: #e46876)
      { url = "**.rs", text = "", fg = "#e46876" },
      { url = "**.cpp", text = "", fg = "#e46876" },
      { url = "**.c", text = "", fg = "#e46876" },
      { url = "**.h", text = "", fg = "#e46876" },
      { url = "**.hpp", text = "", fg = "#e46876" },
      { url = "**.go", text = "", fg = "#e46876" },
      { url = "**.java", text = "", fg = "#e46876" },
      { url = "**.kt", text = "", fg = "#e46876" },
      { url = "**.cs", text = "󰌛", fg = "#e46876" },
      { url = "**.swift", text = "", fg = "#e46876" },
      { url = "**.zip", text = "", fg = "#e46876" },
      { url = "**.tar", text = "", fg = "#e46876" },
      { url = "**.gz", text = "", fg = "#e46876" },
      { url = "**.7z", text = "", fg = "#e46876" },
      { url = "**.rar", text = "", fg = "#e46876" },
      { url = "**.xz", text = "", fg = "#e46876" }
    ]
    prepend_conds = [
      { if = "dir", text = "󰉋", fg = "#e6c384" },
      { if = "link", text = "", fg = "#7fb4ca" }
    ]
  '';
}
