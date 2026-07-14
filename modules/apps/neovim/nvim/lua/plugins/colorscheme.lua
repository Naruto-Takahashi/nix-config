-- kanagawa-dragon はもともと彩度を落とした落ち着き重視の配色．
-- 同じ Kanagawa Dragon ベースの yazi 側テーマ (kanagawa-dragon.yazi の
-- tmtheme.xml: コードプレビュー専用のシンタックス定義。flavor.toml とは別物)
-- を見ると，comment・keyword・number・identifier・type・parameter など
-- 主要トークンだけ意図的に本家 Kanagawa (wave) 側のより鮮やかな値に
-- 差し替えられていた。同じ値を dragon 側にも当てて見た目を揃える。
local dragon_overrides = {
  dragonAsh = "#a6a69c", -- comment   : 元 #737c73 → tmtheme comment 相当
  dragonPink = "#D27E99", -- number    : 元 #a292a3 → sakuraPink
  dragonYellow = "#E6C384", -- identifier: 元 #c4b28a → carpYellow
  dragonAqua = "#7AA89F", -- type      : 元 #8ea4a2 → waveAqua2
  dragonGray = "#b8b4d0", -- parameter : 元 #a6a69c → oniViolet2 (ANSI bright-black にも影響)
  dragonViolet = "#E46876", -- keyword/statement : 元 #8992a7 → waveRed
  dragonRed = "#E46876", -- operator/preproc/regex : 元 #c4746e → waveRed
}

return {
  "Naruto-Takahashi/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true, -- 背景透過を有効化
    theme = "dragon", -- wave, dragon, lotus
    colors = {
      palette = dragon_overrides,
    },
  },
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd("colorscheme kanagawa-dragon")
  end,
}
