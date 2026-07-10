return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Matugen 由来のパレット (yasb-theme が壁紙変更のたびに生成する)
    -- が読めればステータスバーへ適用し、無ければ従来の "auto" にフォールバック
    local theme = "auto"
    local ok, c = pcall(dofile, vim.fn.expand("~/.cache/matugen/colors.lua"))
    if ok and type(c) == "table" then
      -- Starship プロンプトと同じ文法: 明色セグメント → 暗色セグメント(accent 文字) → 無地
      local a = { fg = c.on_accent, bg = c.accent, gui = "bold" }
      local sub = { fg = c.on_accent, bg = c.accent_sub, gui = "bold" }
      local mid = { fg = c.accent, bg = c.surface }
      local plain = { fg = c.muted, bg = "none" }
      theme = {
        normal = { a = a, b = mid, c = plain },
        insert = { a = sub, b = mid, c = plain },
        visual = { a = { fg = c.on_accent, bg = c.muted, gui = "bold" }, b = mid, c = plain },
        replace = { a = { fg = c.on_accent, bg = "#c4746e", gui = "bold" }, b = mid, c = plain },
        command = { a = a, b = mid, c = plain },
        inactive = {
          a = { fg = c.muted, bg = c.surface },
          b = { fg = c.muted, bg = c.surface },
          c = plain,
        },
      }
    end

    -- Starship の左端と同じ「secondary 色のブロック」を先頭に置く
    local sections = nil
    if type(theme) == "table" then
      sections = {
        lualine_a = {
          {
            function() return " " end, -- 無地の装飾ブロック
            color = { fg = c.on_accent, bg = c.secondary, gui = "bold" },
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
        -- Starship と同じ鋭角 powerline 矢印
        section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
        component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
      },
      sections = sections,
    })
  end,
}
