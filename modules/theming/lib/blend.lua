-- 2つの16進カラー(#rrggbb)を t:0..1 で線形補間する。
-- nvim (lualine) と yazi の両方から、この1ファイルを別々の場所に
-- 配置して使う (require/dofile どちらでも使えるよう関数を直接返す)。
return function(h1, h2, t)
  local r1, g1, b1 = tonumber(h1:sub(2, 3), 16), tonumber(h1:sub(4, 5), 16), tonumber(h1:sub(6, 7), 16)
  local r2, g2, b2 = tonumber(h2:sub(2, 3), 16), tonumber(h2:sub(4, 5), 16), tonumber(h2:sub(6, 7), 16)
  return string.format("#%02x%02x%02x",
    math.floor(r1 + (r2 - r1) * t + 0.5),
    math.floor(g1 + (g2 - g1) * t + 0.5),
    math.floor(b1 + (b2 - b1) * t + 0.5))
end
