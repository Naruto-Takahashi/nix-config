return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
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
        -- 全体の押し下げ用余白
        { section = "terminal", cmd = "echo $null", height = 5 },
        
        -- 1. ロゴ
        { section = "header", padding = 1, hl = "SnacksDashboardHeader" },
        
        -- 2. 操作メニュー
        { section = "keys", gap = 1, padding = 1 },
        
        -- 3. ギデオンの画像
        {
          section = "terminal",
          cmd = (function()
            if vim.fn.has("win32") == 1 then
              return [[C:/Users/tnaru/AppData/Local/Microsoft/WinGet/Packages/hpjansson.Chafa_Microsoft.WinGet.Source_8wekyb3d8bbwe/chafa-1.18.0-1-x86_64-win/Chafa.exe "C:/Users/tnaru/Tools/Customization/gideon_cursor/gide_pixel.png" --size 60x22 --symbols block+vhalf+quad+hhalf --colors full --dither fs --threshold 0.7 --preprocess false]]
            else
              return [[chafa "/mnt/c/Users/tnaru/Tools/Customization/gideon_cursor/gide_pixel.png" --format symbols --size 60x22 --symbols block+vhalf+quad+hhalf --colors full]]
            end
          end)(),
          height = 25,
          padding = 1,
          indent = 16,
        },
        
        -- 4. 読み込み状況
        { section = "startup", hl = "SnacksDashboardDesc", padding = 1 },
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
    
    local function set_dashboard_colors()
      local brown_light = "#917B62"
      local key_pink    = "#E5A19E"
      local black_logo  = "#756371"
      
      -- ロゴを #756371 に設定
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = black_logo, bold = true })
      
      -- 説明文と統計情報を明るい茶色に
      vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = brown_light })
      vim.api.nvim_set_hl(0, "SnacksDashboardStartup", { fg = brown_light })
      vim.api.nvim_set_hl(0, "SnacksDashboardStats", { fg = brown_light })
      vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = brown_light })

      -- キー部分をピンクで固定
      vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = key_pink, bold = true })

      -- アイコンを茶色に設定
      vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = brown_light })
    end

    -- 描画タイミングに合わせて色を適用
    vim.api.nvim_create_autocmd({ "VimEnter", "User" }, {
      pattern = { "SnacksDashboardOpened" },
      callback = function()
        vim.defer_fn(set_dashboard_colors, 50)
      end,
    })

    set_dashboard_colors()
  end,
}