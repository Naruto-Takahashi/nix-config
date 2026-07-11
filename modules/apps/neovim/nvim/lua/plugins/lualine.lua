return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Matugen 由来のパレット (matugen-apply が壁紙変更のたびに生成する)
    -- が読めればステータスバーへ適用し、無ければ従来の "auto" にフォールバック
    local theme = "auto"
    local sections = nil
    local ok, c = pcall(dofile, vim.fn.expand("~/.cache/matugen/colors.lua"))
    if ok and type(c) == "table" then
      local complement = c.complement or c.muted
      local replace = "#c4746e"

      -- 2色を t:0..1 で混ぜる (「薄め色」計算用)
      local function blend(h1, h2, t)
        local r1, g1, b1 = tonumber(h1:sub(2, 3), 16), tonumber(h1:sub(4, 5), 16), tonumber(h1:sub(6, 7), 16)
        local r2, g2, b2 = tonumber(h2:sub(2, 3), 16), tonumber(h2:sub(4, 5), 16), tonumber(h2:sub(6, 7), 16)
        return string.format("#%02x%02x%02x",
          math.floor(r1 + (r2 - r1) * t + 0.5),
          math.floor(g1 + (g2 - g1) * t + 0.5),
          math.floor(b1 + (b2 - b1) * t + 0.5))
      end

      -- Starship プロンプトと同じ文法: 明色セグメント → 暗色セグメント → 無地。
      -- 暗色セグメント (b) の文字色はモード色に追従させる
      local function mode_theme(color)
        return {
          a = { fg = c.on_accent, bg = color, gui = "bold" },
          b = { fg = color, bg = c.surface },
          c = { fg = c.muted, bg = "none" },
        }
      end
      theme = {
        normal = mode_theme(c.accent),
        insert = mode_theme(c.tertiary),
        visual = mode_theme(complement),
        replace = mode_theme(replace),
        command = mode_theme(c.accent),
        inactive = {
          a = { fg = c.muted, bg = c.surface },
          b = { fg = c.muted, bg = c.surface },
          c = { fg = c.muted, bg = "none" },
        },
      }

      -- 白側に寄せたパステル調の「薄め色」(装飾ブロック用)
      local function pale(color)
        return blend(color, "#ffffff", 0.4)
      end

      -- 左端の装飾ブロック: Normal は secondary、他モードはモード色のパステル版
      local mode_colors = {
        i = c.tertiary,
        v = complement, V = complement, ["\22"] = complement,
        s = complement, S = complement,
        R = replace,
      }
      local function lead_color()
        local m = vim.fn.mode():sub(1, 1)
        local mcol = mode_colors[m]
        if not mcol then
          return { fg = c.on_accent, bg = c.secondary, gui = "bold" }
        end
        return { fg = c.on_accent, bg = pale(mcol), gui = "bold" }
      end

      sections = {
        lualine_a = {
          {
            function() return " " end, -- 無地の装飾ブロック
            color = lead_color,
            separator = { left = "", right = "\u{e0b0}" },
            padding = 0,
          },
          { "mode" },
        },
      }
    end

    require("lualine").setup({
      options = {
        theme = theme,
        -- 画面全体で1本のステータスライン (Neo-tree 等にフォーカスしても
        -- ウィンドウごとに分割されず、常に最下部に表示される)
        globalstatus = true,
        -- Starship と同じ鋭角 powerline 矢印
        section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
        component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
      },
      sections = sections,
    })
  end,
}
