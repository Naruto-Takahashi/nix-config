-- kanagawa-dragon はもともと彩度を落とした落ち着き重視の配色．
-- 同じ Kanagawa Dragon をベースにした yazi 側テーマ (kanagawa-dragon.yazi の
-- flavor.toml) は，ほとんどの色は dragon 本来の値のまま使いつつ，黄色と赤だけ
-- 本家 Kanagawa (wave) 側のより鮮やかな値に差し替えていた．見やすいと感じたのは
-- この2色の差し替えが効いていたためなので，同じ値を dragon 側にも当てる．
local dragon_overrides = {
  dragonYellow = "#e6c384", -- carpYellow (wave) : 元は dragonYellow #c4b28a
  dragonRed = "#e46876", -- waveRed (wave)     : 元は dragonRed #c4746e
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
