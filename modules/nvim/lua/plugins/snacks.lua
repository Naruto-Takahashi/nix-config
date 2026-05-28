return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    -- ハイライト定義は vim-options.lua の ColorScheme オートコマンドに移動しました
    -- (カラースキーム変更時に上書きされるのを防ぐため)
  end,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { action = ":lua Snacks.dashboard.pick('files')",           key = "f", text = { { " ", hl = "SnacksDashboardIconCyan" }, { "Find File", hl = "SnacksDashboardWhite" } } },
          { action = ":lua Snacks.dashboard.pick('oldfiles')",        key = "r", text = { { " ", hl = "SnacksDashboardIconGreen" }, { "Recent Files", hl = "SnacksDashboardWhite" } } },
          { action = ":lua Snacks.dashboard.pick('live_grep')",       key = "g", text = { { " ", hl = "SnacksDashboardIconYellow" }, { "Find Text", hl = "SnacksDashboardWhite" } } },
          { action = ":ene | startinsert",                            key = "n", text = { { " ", hl = "SnacksDashboardIconOrange" }, { "New File", hl = "SnacksDashboardWhite" } } },
          { action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})", key = "c", text = { { " ", hl = "SnacksDashboardIconPurple" }, { "Config", hl = "SnacksDashboardWhite" } } },
          { action = ":Lazy",                                         key = "l", text = { { "󰒲 ", hl = "SnacksDashboardIconBlue" }, { "Lazy", hl = "SnacksDashboardWhite" } } },
          { action = "session",                                       key = "s", text = { { " ", hl = "SnacksDashboardIconPink" }, { "Restore Session", hl = "SnacksDashboardWhite" } } },
          { action = ":qa",                                           key = "q", text = { { " ", hl = "SnacksDashboardIconRed" }, { "Quit", hl = "SnacksDashboardIconRed" } } },
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