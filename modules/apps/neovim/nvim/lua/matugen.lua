-- ==========================================================================
--  matugen 配色モジュール
--  yasb-theme (WSL) が壁紙から生成する ~/.cache/matugen/colors.lua を読み込む。
--  ファイルが無い環境 (Linuxデスクトップ/mac 等) ではフォールバック値を使う。
-- ==========================================================================
local M = {
  accent = "#ffc20d",
  tertiary = "#8ea4a2",
  secondary = "#d08770",
  complement = "#7fb4ca",
  triad = "#c8e69a",
  text = "#c5c9c5",
  muted = "#a0a9cb",
  surface = "#333333",
  on_accent = "#000000",
  error = "#c4746e",
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
