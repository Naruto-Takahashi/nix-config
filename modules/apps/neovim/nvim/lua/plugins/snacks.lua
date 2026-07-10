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
      preset = {},
      -- sections は config 関数内で強制上書きします
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    gitbrowse = { enabled = true },
    lazygit = {
      enabled = true,
      theme = {
        [ "activeBorderColor" ] = { fg = "LazygitActiveBorder", bold = true },
      },
    },
  },
  keys = {
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "x" } },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>lf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>ll", function() Snacks.lazygit.log() end, desc = "Lazygit Log (CWD)" },
    { "<leader>zn", function() Snacks.terminal("npx zenn new:article", { win = { position = "float" } }) end, desc = "Zenn New Article" },
    { "<leader>zp", function() Snacks.terminal("npx zenn preview", { win = { position = "right" } }) end, desc = "Zenn Preview" },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore", mode = { "n", "t" } },
  },
  config = function(_, opts)
    -- メニュー構成を上書き定義 (全体が中央に揃うように align = "center" を使用)
    opts.dashboard.sections = {
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
      { section = "keys", gap = 1, padding = 1, align = "center" }, -- 両端揃えしたメニューを全体として中央寄せに
      { section = "startup", icon = "" }, -- 起動メッセージから稲妻（⚡）絵文字を削除
    }

    -- 各メニュー項目の表示幅を「44」に統一し，アイコン色を戻しつつキーバインドを右端に配置
    opts.dashboard.preset.keys = {
      { action = ":lua Snacks.dashboard.pick('files')",           key = "f", text = { { " ", hl = "SnacksDashboardIcon" }, { "Find File", hl = "SnacksDashboardWhite" }, { string.rep(" ", 31) }, { "f", hl = "SnacksDashboardKeyHint" } } },
      { action = ":lua Snacks.dashboard.pick('oldfiles')",        key = "r", text = { { " ", hl = "SnacksDashboardIcon" }, { "Recent Files", hl = "SnacksDashboardWhite" }, { string.rep(" ", 28) }, { "r", hl = "SnacksDashboardKeyHint" } } },
      { action = ":lua Snacks.dashboard.pick('live_grep')",       key = "g", text = { { " ", hl = "SnacksDashboardIcon" }, { "Find Text", hl = "SnacksDashboardWhite" }, { string.rep(" ", 31) }, { "g", hl = "SnacksDashboardKeyHint" } } },
      { action = ":ene | startinsert",                            key = "n", text = { { " ", hl = "SnacksDashboardIcon" }, { "New File", hl = "SnacksDashboardWhite" }, { string.rep(" ", 32) }, { "n", hl = "SnacksDashboardKeyHint" } } },
      { action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})", key = "c", text = { { " ", hl = "SnacksDashboardIcon" }, { "Config", hl = "SnacksDashboardWhite" }, { string.rep(" ", 34) }, { "c", hl = "SnacksDashboardKeyHint" } } },
      { action = ":Lazy",                                         key = "l", text = { { "󰒲 ", hl = "SnacksDashboardIcon" }, { "Lazy", hl = "SnacksDashboardWhite" }, { string.rep(" ", 36) }, { "l", hl = "SnacksDashboardKeyHint" } } },
      { action = ":lua require('persistence').load()",            key = "s", text = { { " ", hl = "SnacksDashboardIcon" }, { "Restore Session", hl = "SnacksDashboardWhite" }, { string.rep(" ", 25) }, { "s", hl = "SnacksDashboardKeyHint" } } },
      { action = ":qa",                                           key = "q", text = { { " ", hl = "SnacksDashboardIconRed" }, { "Quit", hl = "SnacksDashboardIconRed" }, { string.rep(" ", 36) }, { "q", hl = "SnacksDashboardIconRed" } } },
    }

    require("snacks").setup(opts)
  end,
}