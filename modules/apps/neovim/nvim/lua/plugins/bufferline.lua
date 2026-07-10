return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  config = function()
    local mc = require("matugen")

    -- 透過地 + matugen 配色 (lualine / Starship / WezTerm タブと同じ語彙)
    local none = "none"
    require("bufferline").setup({
      options = {
        mode = "buffers", -- 開いているファイルをタブ状に表示
        -- 矢印セパレータは bufferline では色制御できないため矩形スタイル
        separator_style = { "", "" },
        always_show_bufferline = false, -- 1枚だけのときは非表示 (WezTermと同じ挙動)
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
      },
      highlights = {
        fill = { bg = none },
        background = { fg = mc.muted, bg = none },
        buffer_visible = { fg = mc.muted, bg = none },
        buffer_selected = { fg = mc.on_accent, bg = mc.accent, bold = true, italic = false },
        separator = { fg = none, bg = none },
        separator_visible = { fg = none, bg = none },
        separator_selected = { fg = none, bg = none },
        modified = { fg = mc.accent_sub, bg = none },
        modified_visible = { fg = mc.accent_sub, bg = none },
        modified_selected = { fg = mc.on_accent, bg = mc.accent },
        duplicate = { fg = mc.muted, bg = none, italic = true },
        duplicate_visible = { fg = mc.muted, bg = none, italic = true },
        duplicate_selected = { fg = mc.on_accent, bg = mc.accent, italic = true },
        indicator_selected = { fg = mc.accent, bg = mc.accent },
        tab = { fg = mc.muted, bg = none },
        tab_selected = { fg = mc.on_accent, bg = mc.accent, bold = true },
      },
    })

    -- タブ操作キーマップ
    vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer tab" })
    vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Prev buffer tab" })
    vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
    vim.keymap.set("n", "<leader>bp", ":BufferLineTogglePin<CR>", { silent = true, desc = "Pin buffer" })
  end,
}
