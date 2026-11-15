return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Matugen 由来のパレット (matugen-apply が壁紙変更のたびに生成する)
    -- が読めればステータスバーへ適用し、無ければ lua/matugen.lua の
    -- kanagawa-dragon フォールバック配色を使う (常にカスタムテーマを適用)
    local theme = "auto"
    local sections = nil
    do
      local c = require("matugen")
      local complement = c.complement or c.muted
      local replace = c.error

      -- 2色を t:0..1 で混ぜる (「淡い面」の計算用)。yazi (init.lua) と共有。
      local blend = require("blend")

      -- ステータスの地は透過 (本文と同じ)。配色は「一点集中」: 塗るのは左端の「モード」
      -- (モード色のソリッド) と右端の「位置」(淡い地 + 文字) の2か所だけ。
      -- git (ブランチ・差分) は塗らず、モード色の文字だけ。色はモード色に追従する
      -- (Normal は accent の黄色)。区切りは斜め「/」 (タブと同じ形)。
      -- 淡い地は surface から作る
      local function tonal(color, t) return blend(c.surface, color, t) end

      local function mode_theme(color)
        local band = { fg = c.muted, bg = "none" }
        return {
          a = { fg = c.on_accent, bg = color, gui = "bold" },
          b = { fg = color, bg = "none" },
          c = band, x = band, y = band,
          z = { fg = color, bg = tonal(color, 0.22), gui = "bold" },
        }
      end
      theme = {
        normal = mode_theme(c.accent),
        insert = mode_theme(c.tertiary),
        visual = mode_theme(complement),
        replace = mode_theme(replace),
        command = mode_theme(c.accent),
        inactive = mode_theme(c.muted),
      }

      -- 中央寄せ用の区切り (c セクション内 + lualine 自身の c|x 境界の %= で
      -- 「左 | ファイル名 | 右」の左右の余白が均等に分かれる)
      local function center_mark()
        return {
          function() return "%=" end,
          color = { fg = c.muted, bg = "none" },
          padding = 0,
          separator = { left = "", right = "" },
        }
      end

      sections = {
        lualine_a = {
          -- 左端も斜め (◢)、右端も斜め (◤)
          { "mode", separator = { left = "\u{e0ba}", right = "\u{e0bc}" } },
        },
        -- git: モード色の文字だけ (ブランチ + 差分)。地が透過なので、区切りの斜辺は
        -- 出さない (出すと色が決まらず、白い三角形が浮く)
        lualine_b = {
          { "branch", separator = { left = "", right = "" } },
          { "diff", separator = { left = "", right = "" } },
        },
        lualine_c = {
          -- 診断はブランチの右に、帯の上の文字として置く
          { "diagnostics", padding = { left = 1, right = 0 }, separator = { left = "", right = "" } },
          center_mark(),
          {
            -- ファイル名だけ。パス (ディレクトリ階層) は、ウィンドウ上部のパンくず
            -- (dropbar.nvim) に出るため、ここでは重複させない
            "filename",
            symbols = { modified = " \u{25cf}", readonly = " \u{f023}", unnamed = "[No Name]" },
            padding = { left = 0, right = 0 },
            separator = { left = "", right = "" },
          },
        },
        lualine_z = {
          -- 左端 (◢) も右端 (◤) も斜め。left を空にすると、セクション区切り (◢) が
          -- 消えて、位置ブロックの左が縦線になる
          { "location", separator = { left = "\u{e0ba}", right = "\u{e0bc}" } },
        },
      }
    end

    local lualine = require("lualine")
    lualine.setup({
      options = {
        theme = theme,
        -- 画面全体で1本のステータスライン (Neo-tree 等にフォーカスしても
        -- ウィンドウごとに分割されず、常に最下部に表示される)
        globalstatus = true,
        -- 斜めの powerline 区切り (どれも斜辺は右上がりの「/」)。
        -- 左側は ◤ (\u{e0bc})、右側は ◢ (\u{e0ba})、セクション内の細い区切りは \u{e0bb}
        section_separators = { left = "\u{e0bc}", right = "\u{e0ba}" },
        component_separators = { left = "\u{e0bb}", right = "\u{e0bb}" },
      },
      sections = sections,
    })

    -- ファイル名を「真の中央」にする。`左 %= ファイル名 %= 右` の形だと、左右の幅が
    -- 違うときファイル名は中央からずれる。そこで statusline を出力する直前に、
    -- 左右の表示幅を測って短い側に空白を足し、左右を同じ幅にそろえる。
    if sections then
      local band_hl = "LualineBand"
      local function set_band_hl()
        vim.api.nvim_set_hl(0, band_hl, { bg = "none" })
      end
      set_band_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_band_hl })
      local function width(str)
        return vim.api.nvim_eval_statusline(str, { maxwidth = 10000 }).width
      end
      local orig = lualine.statusline
      lualine.statusline = function(...)
        local s = orig(...)
        -- 区切りは `%=` ちょうど2つ (自前の中央マーカー + lualine 自身の c|x 境界)
        local left, mid, right = s:match("^(.-)%%=(.-)%%=(.*)$")
        if not left or right:find("%%=", 1, true) then return s end
        local lw, rw = width(left), width(right)
        local pad = "%#" .. band_hl .. "#"
        if lw < rw then
          left = left .. pad .. string.rep(" ", rw - lw)
        elseif rw < lw then
          right = pad .. string.rep(" ", lw - rw) .. right
        end
        return left .. "%=" .. mid .. "%=" .. right
      end
    end
  end,
}
