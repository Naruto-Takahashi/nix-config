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
          -- Normal = accent / Select = complement / Unset = muted (lualine と同じ割当)
          th.mode.normal_main = ui.Style():fg(pal.on_accent):bg(pal.accent):bold()
          th.mode.normal_alt  = ui.Style():fg(pal.accent):bg(pal.surface)
          local vis = pal.complement or pal.tertiary
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
            local block_bg = pal.secondary or pal.tertiary
            if mode == "select" then
              mode_bg = pal.complement or pal.tertiary
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
            if mode == "select" then bg = pal.complement or pal.tertiary
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
      { url = "**/config.toml", fg = "@@TRIAD@@" },
      { url = "**/theme.toml", fg = "@@TRIAD@@" },
      { url = "**/yazi.toml", fg = "@@TRIAD@@" },
      { url = "**/desktop.ini", fg = "@@TERTIARY@@" },
      { url = "**/.env*", fg = "@@TRIAD@@" },
      { url = "**/Dockerfile", fg = "@@TERTIARY@@" },
      # ドキュメント・テキスト・インフラ系 (matugen tertiary)
      { url = "**.md", fg = "@@TERTIARY@@" },
      { url = "**.pdf", fg = "@@TERTIARY@@" },
      { url = "**.txt", fg = "@@TERTIARY@@" },
      { url = "**.log", fg = "@@TERTIARY@@" },
      { url = "**.csv", fg = "@@TERTIARY@@" },
      { url = "**.docx", fg = "@@TERTIARY@@" },
      { url = "**.doc", fg = "@@TERTIARY@@" },
      { url = "**.xlsx", fg = "@@TERTIARY@@" },
      { url = "**.xls", fg = "@@TERTIARY@@" },
      { url = "**.pptx", fg = "@@TERTIARY@@" },
      { url = "**.ppt", fg = "@@TERTIARY@@" },
      { url = "**.ini", fg = "@@TERTIARY@@" },
      { url = "**.toml", fg = "@@TERTIARY@@" },
      { url = "**.tex", fg = "@@TERTIARY@@" },
      { url = "**.bib", fg = "@@TERTIARY@@" },
      { url = "**.nix", fg = "@@TERTIARY@@" },
      { url = "**.sql", fg = "@@TERTIARY@@" },
      # スクリプト・メディア系 (matugen complement)
      { url = "**.py", fg = "@@COMPLEMENT@@" },
      { url = "**.sh", fg = "@@COMPLEMENT@@" },
      { url = "**.lua", fg = "@@COMPLEMENT@@" },
      { url = "**.rb", fg = "@@COMPLEMENT@@" },
      { url = "**.php", fg = "@@COMPLEMENT@@" },
      { url = "**.pl", fg = "@@COMPLEMENT@@" },
      { url = "**.mp4", fg = "@@COMPLEMENT@@" },
      { url = "**.mkv", fg = "@@COMPLEMENT@@" },
      { url = "**.avi", fg = "@@COMPLEMENT@@" },
      { url = "**.mov", fg = "@@COMPLEMENT@@" },
      { url = "**.webm", fg = "@@COMPLEMENT@@" },
      { url = "**.mp3", fg = "@@COMPLEMENT@@" },
      { url = "**.wav", fg = "@@COMPLEMENT@@" },
      { url = "**.flac", fg = "@@COMPLEMENT@@" },
      { url = "**.m4a", fg = "@@COMPLEMENT@@" },
      { url = "**.ogg", fg = "@@COMPLEMENT@@" },
      # Web・データ系 (matugen triad: 色相120°シフト)
      { url = "**.js", fg = "@@TRIAD@@" },
      { url = "**.ts", fg = "@@TRIAD@@" },
      { url = "**.jsx", fg = "@@TRIAD@@" },
      { url = "**.tsx", fg = "@@TRIAD@@" },
      { url = "**.json", fg = "@@TRIAD@@" },
      { url = "**.jsonc", fg = "@@TRIAD@@" },
      { url = "**.yaml", fg = "@@TRIAD@@" },
      { url = "**.yml", fg = "@@TRIAD@@" },
      { url = "**.toml", fg = "@@TRIAD@@" },
      { url = "**.lock", fg = "@@TRIAD@@" },
      { url = "**.html", fg = "@@TRIAD@@" },
      { url = "**.htm", fg = "@@TRIAD@@" },
      { url = "**.css", fg = "@@TRIAD@@" },
      { url = "**.scss", fg = "@@TRIAD@@" },
      { url = "**.png", fg = "@@TRIAD@@" },
      { url = "**.jpg", fg = "@@TRIAD@@" },
      { url = "**.jpeg", fg = "@@TRIAD@@" },
      { url = "**.gif", fg = "@@TRIAD@@" },
      { url = "**.webp", fg = "@@TRIAD@@" },
      { url = "**.svg", fg = "@@TRIAD@@" },
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
      { url = "**.exe", fg = "@@TERTIARY@@" },
      { url = "**.out", fg = "@@TERTIARY@@" },
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
      { name = "Cargo.toml", text = "", fg = "@@TERTIARY@@" },
      { name = "config.toml", text = "", fg = "@@TRIAD@@" },
      { name = "theme.toml", text = "", fg = "@@TRIAD@@" },
      { name = "yazi.toml", text = "", fg = "@@TRIAD@@" },
      { name = "desktop.ini", text = "", fg = "@@TERTIARY@@" },
      { name = "package-lock.json", text = "󰘦", fg = "@@TRIAD@@" },
      { name = "pnpm-lock.yaml", text = "󰘦", fg = "@@TRIAD@@" },
      { name = "flake.lock", text = "󰘦", fg = "@@TRIAD@@" }
    ]
    prepend_globs = [
      # 特定ファイル
      { url = "**/Cargo.toml", text = "", fg = "@@ERROR@@" },
      { url = "**/config.toml", text = "", fg = "@@TRIAD@@" },
      { url = "**/theme.toml", text = "", fg = "@@TRIAD@@" },
      { url = "**/yazi.toml", text = "", fg = "@@TRIAD@@" },
      { url = "**/desktop.ini", text = "", fg = "@@TERTIARY@@" },
      { url = "**/package-lock.json", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**/pnpm-lock.yaml", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**/flake.lock", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**/Dockerfile", text = "󰡨", fg = "@@TERTIARY@@" },
      # ドキュメント・テキスト・インフラ系 (matugen tertiary)
      { url = "**.md", text = "󰍔", fg = "@@TERTIARY@@" },
      { url = "**.pdf", text = "󰈦", fg = "@@TERTIARY@@" },
      { url = "**.txt", text = "", fg = "@@TERTIARY@@" },
      { url = "**.log", text = "", fg = "@@TERTIARY@@" },
      { url = "**.csv", text = "󰈛", fg = "@@TERTIARY@@" },
      { url = "**.docx", text = "󰈬", fg = "@@TERTIARY@@" },
      { url = "**.doc", text = "󰈬", fg = "@@TERTIARY@@" },
      { url = "**.xlsx", text = "󰈛", fg = "@@TERTIARY@@" },
      { url = "**.xls", text = "󰈛", fg = "@@TERTIARY@@" },
      { url = "**.pptx", text = "󰈫", fg = "@@TERTIARY@@" },
      { url = "**.ppt", text = "󰈫", fg = "@@TERTIARY@@" },
      { url = "**.ini", text = "", fg = "@@TERTIARY@@" },
      { url = "**.toml", text = "", fg = "@@TERTIARY@@" },
      { url = "**.tex", text = "󰙩", fg = "@@TERTIARY@@" },
      { url = "**.bib", text = "󰙩", fg = "@@TERTIARY@@" },
      { url = "**.nix", text = "", fg = "@@TERTIARY@@" },
      { url = "**.sql", text = "", fg = "@@TERTIARY@@" },
      { url = "**.exe", text = "", fg = "@@TERTIARY@@" },
      { url = "**.out", text = "", fg = "@@TERTIARY@@" },
      # スクリプト・メディア系 (matugen complement)
      { url = "**.py", text = "", fg = "@@COMPLEMENT@@" },
      { url = "**.sh", text = "", fg = "@@COMPLEMENT@@" },
      { url = "**.lua", text = "", fg = "@@COMPLEMENT@@" },
      { url = "**.rb", text = "", fg = "@@COMPLEMENT@@" },
      { url = "**.php", text = "", fg = "@@COMPLEMENT@@" },
      { url = "**.pl", text = "", fg = "@@COMPLEMENT@@" },
      { url = "**.mp4", text = "󰈫", fg = "@@COMPLEMENT@@" },
      { url = "**.mkv", text = "󰈫", fg = "@@COMPLEMENT@@" },
      { url = "**.mov", text = "󰈫", fg = "@@COMPLEMENT@@" },
      { url = "**.webm", text = "󰈫", fg = "@@COMPLEMENT@@" },
      { url = "**.mp3", text = "󰎈", fg = "@@COMPLEMENT@@" },
      { url = "**.wav", text = "󰎈", fg = "@@COMPLEMENT@@" },
      { url = "**.flac", text = "󰎈", fg = "@@COMPLEMENT@@" },
      { url = "**.m4a", text = "󰎈", fg = "@@COMPLEMENT@@" },
      { url = "**.ogg", text = "󰎈", fg = "@@COMPLEMENT@@" },
      # Web・データ系 (matugen triad: 色相120°シフト)
      { url = "**.html", text = "", fg = "@@TRIAD@@" },
      { url = "**.htm", text = "", fg = "@@TRIAD@@" },
      { url = "**.js", text = "", fg = "@@TRIAD@@" },
      { url = "**.ts", text = "", fg = "@@TRIAD@@" },
      { url = "**.jsx", text = "", fg = "@@TRIAD@@" },
      { url = "**.tsx", text = "", fg = "@@TRIAD@@" },
      { url = "**.json", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**.jsonc", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**.yaml", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**.yml", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**.lock", text = "󰘦", fg = "@@TRIAD@@" },
      { url = "**.css", text = "", fg = "@@TRIAD@@" },
      { url = "**.scss", text = "", fg = "@@TRIAD@@" },
      { url = "**.png", text = "󰈟", fg = "@@TRIAD@@" },
      { url = "**.jpg", text = "󰈟", fg = "@@TRIAD@@" },
      { url = "**.jpeg", text = "󰈟", fg = "@@TRIAD@@" },
      { url = "**.webp", text = "󰈟", fg = "@@TRIAD@@" },
      { url = "**.svg", text = "󰈟", fg = "@@TRIAD@@" },
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
