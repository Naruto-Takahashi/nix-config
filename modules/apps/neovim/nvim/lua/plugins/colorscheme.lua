return {
  "Naruto-Takahashi/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true, -- 背景透過を有効化
    theme = "dragon", -- wave, dragon, lotus
  },
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd("colorscheme kanagawa-dragon")
  end,
}
