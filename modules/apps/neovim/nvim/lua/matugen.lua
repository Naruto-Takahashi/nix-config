-- ==========================================================================
--  matugen 配色モジュール
--  matugen-apply (WSL) が壁紙から生成する ~/.cache/matugen/colors.lua を読み込む。
--  ファイルが無い環境 (Linuxデスクトップ/mac 等) ではフォールバック値を使う。
-- ==========================================================================
-- フォールバック配色は kanagawa-dragon (rebelot/kanagawa.nvim) パレットに準拠．
local M = {
  accent = "#e6c384",     -- carpYellow
  tertiary = "#7aa89f",   -- waveAqua2
  secondary = "#a292a3",  -- oniViolet
  complement = "#7fb4ca", -- oldWhite
  triad = "#8a9a7b",      -- springGreen
  text = "#c5c9c5",       -- fujiWhite
  muted = "#a6a69c",      -- fujiGray
  surface = "#181616",    -- sumiInk3
  on_accent = "#000000",
  error = "#c4746e",
  accent_pale = "#f0dbb5",      -- autumnRed
}

local f = (os.getenv("HOME") or "") .. "/.cache/matugen/colors.lua"
if vim.fn.filereadable(f) == 1 then
  local ok, t = pcall(dofile, f)
  if ok and type(t) == "table" then
    for k, v in pairs(t) do
      M[k] = v
    end
  end
end

return M
