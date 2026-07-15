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

      -- 2色を t:0..1 で混ぜる (「薄め色」計算用)。yazi (init.lua) と共有。
      local blend = require("blend")

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
