return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- 透過設定
    transparent = true,
    
    -- 背景透過時のボーダー透過設定
    -- trueにするとボーダーの背景も透過されます
    transparent_sidebar_bg = true,

    -- イタリック等の設定
    italic_comments = true,
    hide_fillchars = true,
    borderless_telescope = false,
    
    -- 拡張機能との連携
    extensions = {
        telescope = true,
        notify = true,
        mini = true,
        cmp = true,
        gitsigns = true,
        treesitter = true,
        whichkey = true,
        indentblankline = true,
        dashboard = true,
        snacks = true,
        lazy = true,
    },
    
    -- カスタムハイライト (必要に応じて微調整可能)
    overrides = function(colors) 
      return {
        -- ここで特定の色を上書きできます
        -- 例: LineNr = { fg = colors.grey },
      }
    end,
  },
  config = function(_, opts)
    require("cyberdream").setup(opts)
    vim.cmd("colorscheme cyberdream")
  end,
}