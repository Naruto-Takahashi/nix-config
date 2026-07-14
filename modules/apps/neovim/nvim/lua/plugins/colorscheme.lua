-- kanagawa-dragon はもともと彩度を落とした落ち着き重視の配色のため，
-- 色相はデフォルトのまま，アクセント色だけ彩度・明度を底上げする．
-- (背景の sumiInk / dragonBlack 系はそのまま暗く保つ)

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

local function rgb_to_hex(r, g, b)
  return string.format(
    "#%02x%02x%02x",
    math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5)
  )
end

local function rgb_to_hsl(r, g, b)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2
  local d = max - min
  if d ~= 0 then
    s = d / (1 - math.abs(2 * l - 1))
    if max == r then
      h = ((g - b) / d) % 6
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h * 60
  end
  return h, s, l
end

local function hsl_to_rgb(h, s, l)
  local c = (1 - math.abs(2 * l - 1)) * s
  local x = c * (1 - math.abs((h / 60) % 2 - 1))
  local m = l - c / 2
  local r, g, b
  if h < 60 then
    r, g, b = c, x, 0
  elseif h < 120 then
    r, g, b = x, c, 0
  elseif h < 180 then
    r, g, b = 0, c, x
  elseif h < 240 then
    r, g, b = 0, x, c
  elseif h < 300 then
    r, g, b = x, 0, c
  else
    r, g, b = c, 0, x
  end
  return r + m, g + m, b + m
end

local function brighten(hex, sat_boost, light_boost, hue_shift)
  local r, g, b = hex_to_rgb(hex)
  local h, s, l = rgb_to_hsl(r, g, b)
  h = (h + (hue_shift or 0)) % 360
  s = math.min(1, s * sat_boost)
  l = math.min(0.92, l * light_boost)
  local nr, ng, nb = hsl_to_rgb(h, s, l)
  return rgb_to_hex(nr, ng, nb)
end

-- lua/kanagawa/colors.lua の dragon* パレット値 (文字色・アクセント色のみ抜粋)
local dragon_accent_colors = {
  dragonWhite = "#c5c9c5",
  dragonGreen = "#87a987",
  dragonGreen2 = "#8a9a7b",
  dragonPink = "#a292a3",
  dragonOrange = "#b6927b",
  dragonOrange2 = "#b98d7b",
  dragonGray = "#a6a69c",
  dragonGray2 = "#9e9b93",
  dragonGray3 = "#7a8382",
  dragonBlue2 = "#8ba4b0",
  dragonViolet = "#8992a7",
  dragonRed = "#c4746e",
  dragonAqua = "#8ea4a2",
  dragonAsh = "#737c73",
  dragonTeal = "#949fb5",
  dragonYellow = "#c4b28a",
}

-- dragonBlue2 (関数名, h≈200°) と dragonViolet (キーワード, h≈222°) は
-- 色相差がわずか22度しかなく，彩度・明度を底上げしただけでは見分けづらい．
-- dragonViolet だけ色相を紫寄り (+45°) に回し，はっきり離す．
local hue_shifts = {
  dragonViolet = 45,
}

local brightened_palette = {}
for key, hex in pairs(dragon_accent_colors) do
  brightened_palette[key] = brighten(hex, 1.4, 1.3, hue_shifts[key])
end

return {
  "Naruto-Takahashi/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true, -- 背景透過を有効化
    theme = "dragon", -- wave, dragon, lotus
    colors = {
      palette = brightened_palette,
    },
  },
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd("colorscheme kanagawa-dragon")
  end,
}
