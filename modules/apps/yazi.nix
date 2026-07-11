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

  # --- テーマ設定 (テンプレート) ---
  # フォルダ色などに @@SECONDARY@@ プレースホルダを含むテンプレート。
  # yasb-theme が matugen の secondary を差し込んで theme.toml を生成する．
  xdg.configFile."yazi/theme-template.toml".text = ''
    #:schema https://yazi-rs.github.io/schemas/theme.json

    [manager]
    cwd = { fg = "@@ERROR@@" }

    [mgr]
    cwd = { fg = "@@ERROR@@" }

    [filetype]
    rules = [
      # 特定ファイル
      { url = "**/Cargo.toml", fg = "@@ERROR@@" },
      { url = "**/config.toml", fg = "@@ACCENT@@" },
      { url = "**/theme.toml", fg = "@@ACCENT@@" },
      { url = "**/yazi.toml", fg = "@@ACCENT@@" },
      { url = "**/desktop.ini", fg = "@@ACCENT_SUB@@" },
      { url = "**/.env*", fg = "@@ACCENT@@" },
      { url = "**/Dockerfile", fg = "@@ACCENT_SUB@@" },
      # ドキュメント・テキスト・インフラ系 (matugen accent_sub)
      { url = "**.md", fg = "@@ACCENT_SUB@@" },
      { url = "**.pdf", fg = "@@ACCENT_SUB@@" },
      { url = "**.txt", fg = "@@ACCENT_SUB@@" },
      { url = "**.log", fg = "@@ACCENT_SUB@@" },
      { url = "**.csv", fg = "@@ACCENT_SUB@@" },
      { url = "**.docx", fg = "@@ACCENT_SUB@@" },
      { url = "**.doc", fg = "@@ACCENT_SUB@@" },
      { url = "**.xlsx", fg = "@@ACCENT_SUB@@" },
      { url = "**.xls", fg = "@@ACCENT_SUB@@" },
      { url = "**.pptx", fg = "@@ACCENT_SUB@@" },
      { url = "**.ppt", fg = "@@ACCENT_SUB@@" },
      { url = "**.ini", fg = "@@ACCENT_SUB@@" },
      { url = "**.toml", fg = "@@ACCENT_SUB@@" },
      { url = "**.tex", fg = "@@ACCENT_SUB@@" },
      { url = "**.bib", fg = "@@ACCENT_SUB@@" },
      { url = "**.nix", fg = "@@ACCENT_SUB@@" },
      { url = "**.sql", fg = "@@ACCENT_SUB@@" },
      # スクリプト・メディア系 (matugen visual)
      { url = "**.py", fg = "@@VISUAL@@" },
      { url = "**.sh", fg = "@@VISUAL@@" },
      { url = "**.lua", fg = "@@VISUAL@@" },
      { url = "**.rb", fg = "@@VISUAL@@" },
      { url = "**.php", fg = "@@VISUAL@@" },
      { url = "**.pl", fg = "@@VISUAL@@" },
      { url = "**.mp4", fg = "@@VISUAL@@" },
      { url = "**.mkv", fg = "@@VISUAL@@" },
      { url = "**.avi", fg = "@@VISUAL@@" },
      { url = "**.mov", fg = "@@VISUAL@@" },
      { url = "**.webm", fg = "@@VISUAL@@" },
      { url = "**.mp3", fg = "@@VISUAL@@" },
      { url = "**.wav", fg = "@@VISUAL@@" },
      { url = "**.flac", fg = "@@VISUAL@@" },
      { url = "**.m4a", fg = "@@VISUAL@@" },
      { url = "**.ogg", fg = "@@VISUAL@@" },
      # Web・データ系 (matugen accent)
      { url = "**.js", fg = "@@ACCENT@@" },
      { url = "**.ts", fg = "@@ACCENT@@" },
      { url = "**.jsx", fg = "@@ACCENT@@" },
      { url = "**.tsx", fg = "@@ACCENT@@" },
      { url = "**.json", fg = "@@ACCENT@@" },
      { url = "**.jsonc", fg = "@@ACCENT@@" },
      { url = "**.yaml", fg = "@@ACCENT@@" },
      { url = "**.yml", fg = "@@ACCENT@@" },
      { url = "**.toml", fg = "@@ACCENT@@" },
      { url = "**.lock", fg = "@@ACCENT@@" },
      { url = "**.html", fg = "@@ACCENT@@" },
      { url = "**.htm", fg = "@@ACCENT@@" },
      { url = "**.css", fg = "@@ACCENT@@" },
      { url = "**.scss", fg = "@@ACCENT@@" },
      { url = "**.png", fg = "@@ACCENT@@" },
      { url = "**.jpg", fg = "@@ACCENT@@" },
      { url = "**.jpeg", fg = "@@ACCENT@@" },
      { url = "**.gif", fg = "@@ACCENT@@" },
      { url = "**.webp", fg = "@@ACCENT@@" },
      { url = "**.svg", fg = "@@ACCENT@@" },
      # コンパイル言語・アーカイブ (matugen error)
      { url = "**.rs", fg = "@@ERROR@@" },
      { url = "**.cpp", fg = "@@ERROR@@" },
      { url = "**.c", fg = "@@ERROR@@" },
      { url = "**.h", fg = "@@ERROR@@" },
      { url = "**.hpp", fg = "@@ERROR@@" },
      { url = "**.go", fg = "@@ERROR@@" },
      { url = "**.java", fg = "@@ERROR@@" },
      { url = "**.kt", fg = "@@ERROR@@" },
      { url = "**.cs", fg = "@@ERROR@@" },
      { url = "**.swift", fg = "@@ERROR@@" },
      { url = "**.zip", fg = "@@ERROR@@" },
      { url = "**.tar", fg = "@@ERROR@@" },
      { url = "**.gz", fg = "@@ERROR@@" },
      { url = "**.7z", fg = "@@ERROR@@" },
      { url = "**.rar", fg = "@@ERROR@@" },
      { url = "**.xz", fg = "@@ERROR@@" },
      # バイナリ・その他 (Fallback)
      { url = "**.exe", fg = "@@ACCENT_SUB@@" },
      { url = "**.out", fg = "@@ACCENT_SUB@@" },
      { url = "**/", fg = "@@SECONDARY@@" }, # ディレクトリ (matugen secondary)
      { url = "*", fg = "#c5c9c5" }   # その他
    ]

    [flavor]
    dark = "kanagawa-dragon"

    [icon]
    prepend_dirs = [
      { name = "Desktop", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Downloads", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Documents", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Pictures", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Music", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Videos", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Public", text = "󰉋", fg = "@@SECONDARY@@" },
      { name = "Templates", text = "󰉋", fg = "@@SECONDARY@@" }
    ]
    prepend_files = [
      { name = "Cargo.toml", text = "", fg = "@@ACCENT_SUB@@" },
      { name = "config.toml", text = "", fg = "@@ACCENT@@" },
      { name = "theme.toml", text = "", fg = "@@ACCENT@@" },
      { name = "yazi.toml", text = "", fg = "@@ACCENT@@" },
      { name = "desktop.ini", text = "", fg = "@@ACCENT_SUB@@" },
      { name = "package-lock.json", text = "󰘦", fg = "@@ACCENT@@" },
      { name = "pnpm-lock.yaml", text = "󰘦", fg = "@@ACCENT@@" },
      { name = "flake.lock", text = "󰘦", fg = "@@ACCENT@@" }
    ]
    prepend_globs = [
      # 特定ファイル
      { url = "**/Cargo.toml", text = "", fg = "@@ERROR@@" },
      { url = "**/config.toml", text = "", fg = "@@ACCENT@@" },
      { url = "**/theme.toml", text = "", fg = "@@ACCENT@@" },
      { url = "**/yazi.toml", text = "", fg = "@@ACCENT@@" },
      { url = "**/desktop.ini", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**/package-lock.json", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**/pnpm-lock.yaml", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**/flake.lock", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**/Dockerfile", text = "󰡨", fg = "@@ACCENT_SUB@@" },
      # ドキュメント・テキスト・インフラ系 (matugen accent_sub)
      { url = "**.md", text = "󰍔", fg = "@@ACCENT_SUB@@" },
      { url = "**.pdf", text = "󰈦", fg = "@@ACCENT_SUB@@" },
      { url = "**.txt", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.log", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.csv", text = "󰈛", fg = "@@ACCENT_SUB@@" },
      { url = "**.docx", text = "󰈬", fg = "@@ACCENT_SUB@@" },
      { url = "**.doc", text = "󰈬", fg = "@@ACCENT_SUB@@" },
      { url = "**.xlsx", text = "󰈛", fg = "@@ACCENT_SUB@@" },
      { url = "**.xls", text = "󰈛", fg = "@@ACCENT_SUB@@" },
      { url = "**.pptx", text = "󰈫", fg = "@@ACCENT_SUB@@" },
      { url = "**.ppt", text = "󰈫", fg = "@@ACCENT_SUB@@" },
      { url = "**.ini", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.toml", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.tex", text = "󰙩", fg = "@@ACCENT_SUB@@" },
      { url = "**.bib", text = "󰙩", fg = "@@ACCENT_SUB@@" },
      { url = "**.nix", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.sql", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.exe", text = "", fg = "@@ACCENT_SUB@@" },
      { url = "**.out", text = "", fg = "@@ACCENT_SUB@@" },
      # スクリプト・メディア系 (matugen visual)
      { url = "**.py", text = "", fg = "@@VISUAL@@" },
      { url = "**.sh", text = "", fg = "@@VISUAL@@" },
      { url = "**.lua", text = "", fg = "@@VISUAL@@" },
      { url = "**.rb", text = "", fg = "@@VISUAL@@" },
      { url = "**.php", text = "", fg = "@@VISUAL@@" },
      { url = "**.pl", text = "", fg = "@@VISUAL@@" },
      { url = "**.mp4", text = "󰈫", fg = "@@VISUAL@@" },
      { url = "**.mkv", text = "󰈫", fg = "@@VISUAL@@" },
      { url = "**.mov", text = "󰈫", fg = "@@VISUAL@@" },
      { url = "**.webm", text = "󰈫", fg = "@@VISUAL@@" },
      { url = "**.mp3", text = "󰎈", fg = "@@VISUAL@@" },
      { url = "**.wav", text = "󰎈", fg = "@@VISUAL@@" },
      { url = "**.flac", text = "󰎈", fg = "@@VISUAL@@" },
      { url = "**.m4a", text = "󰎈", fg = "@@VISUAL@@" },
      { url = "**.ogg", text = "󰎈", fg = "@@VISUAL@@" },
      # Web・データ系 (matugen accent)
      { url = "**.html", text = "", fg = "@@ACCENT@@" },
      { url = "**.htm", text = "", fg = "@@ACCENT@@" },
      { url = "**.js", text = "", fg = "@@ACCENT@@" },
      { url = "**.ts", text = "", fg = "@@ACCENT@@" },
      { url = "**.jsx", text = "", fg = "@@ACCENT@@" },
      { url = "**.tsx", text = "", fg = "@@ACCENT@@" },
      { url = "**.json", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**.jsonc", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**.yaml", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**.yml", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**.lock", text = "󰘦", fg = "@@ACCENT@@" },
      { url = "**.css", text = "", fg = "@@ACCENT@@" },
      { url = "**.scss", text = "", fg = "@@ACCENT@@" },
      { url = "**.png", text = "󰈟", fg = "@@ACCENT@@" },
      { url = "**.jpg", text = "󰈟", fg = "@@ACCENT@@" },
      { url = "**.jpeg", text = "󰈟", fg = "@@ACCENT@@" },
      { url = "**.webp", text = "󰈟", fg = "@@ACCENT@@" },
      { url = "**.svg", text = "󰈟", fg = "@@ACCENT@@" },
      # コンパイル言語・アーカイブ (matugen error)
      { url = "**.rs", text = "", fg = "@@ERROR@@" },
      { url = "**.cpp", text = "", fg = "@@ERROR@@" },
      { url = "**.c", text = "", fg = "@@ERROR@@" },
      { url = "**.h", text = "", fg = "@@ERROR@@" },
      { url = "**.hpp", text = "", fg = "@@ERROR@@" },
      { url = "**.go", text = "", fg = "@@ERROR@@" },
      { url = "**.java", text = "", fg = "@@ERROR@@" },
      { url = "**.kt", text = "", fg = "@@ERROR@@" },
      { url = "**.cs", text = "󰌛", fg = "@@ERROR@@" },
      { url = "**.swift", text = "", fg = "@@ERROR@@" },
      { url = "**.zip", text = "", fg = "@@ERROR@@" },
      { url = "**.tar", text = "", fg = "@@ERROR@@" },
      { url = "**.gz", text = "", fg = "@@ERROR@@" },
      { url = "**.7z", text = "", fg = "@@ERROR@@" },
      { url = "**.rar", text = "", fg = "@@ERROR@@" },
      { url = "**.xz", text = "", fg = "@@ERROR@@" }
    ]
    prepend_conds = [
      { if = "dir", text = "󰉋", fg = "@@SECONDARY@@" },
      { if = "link", text = "", fg = "#7fb4ca" }
    ]
  '';
}
