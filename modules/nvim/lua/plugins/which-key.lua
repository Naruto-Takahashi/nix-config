return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- キーバインドのグループ化とアイコン設定
    spec = {
      { "<leader>f", group = "Find (Telescope)", icon = " " },
      { "<leader>l", group = "Lazygit / Log", icon = "󰊢 " },
      { "<leader>c", group = "Code (LSP)", icon = " " },
      { "<leader>d", group = "Debug / Diagnostics", icon = " " },
      { "<leader>q", group = "Session / Quit", icon = " " },
      { "<leader>s", group = "Search / Flash", icon = " " },
    },
  }
}
