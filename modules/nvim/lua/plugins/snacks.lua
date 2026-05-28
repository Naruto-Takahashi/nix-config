return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    -- プレミアムなレインボーグラデーション用ハイライトグループの定義
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader1", { fg = "#89b4fa" }) -- ブルー
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader2", { fg = "#cba6f7" }) -- ラベンダー
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader3", { fg = "#f38ba8" }) -- レッド/ピンク
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader4", { fg = "#fab387" }) -- オレンジ
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader5", { fg = "#f9e2af" }) -- イエロー
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader6", { fg = "#a6e3a1" }) -- グリーン
  end,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        {
          section = "header",
          val = {
            { type = "text", val = [[███╗   ██╗███████╗██╗██╗   ██╗██╗███╗   ███╗]], opts = { hl = "SnacksDashboardHeader1", position = "center" } },
            { type = "text", val = [[████╗  ██║██╔════╝██║██║   ██║██║████╗ ████║]], opts = { hl = "SnacksDashboardHeader2", position = "center" } },
            { type = "text", val = [[██╔██╗ ██║█████╗  ██║██║   ██║██║██╔████╔██║]], opts = { hl = "SnacksDashboardHeader3", position = "center" } },
            { type = "text", val = [[██║╚██╗██║██╔══╝  ██║╚██╗ ██╔╝██║██║╚██╔╝██║]], opts = { hl = "SnacksDashboardHeader4", position = "center" } },
            { type = "text", val = [[██║ ╚████║███████╗██║ ╚████╔╝ ██║██║ ╚═╝ ██║]], opts = { hl = "SnacksDashboardHeader5", position = "center" } },
            { type = "text", val = [[╚═╝  ╚═══╝╚══════╝╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]], opts = { hl = "SnacksDashboardHeader6", position = "center" } },
          },
        },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    lazygit = { enabled = true },
  },
  keys = {
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>lf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>ll", function() Snacks.lazygit.log() end, desc = "Lazygit Log (CWD)" },
    { "<leader>zn", function() Snacks.terminal("npx zenn new:article", { win = { position = "float" } }) end, desc = "Zenn New Article" },
    { "<leader>zp", function() Snacks.terminal("npx zenn preview", { win = { position = "right" } }) end, desc = "Zenn Preview" },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore", mode = { "n", "t" } },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
  end,
}