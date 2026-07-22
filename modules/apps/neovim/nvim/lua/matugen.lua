-- ==========================================================================
--  matugen 配色モジュール
--  matugen-apply (WSL) が壁紙から生成する ~/.cache/matugen/colors.lua を読み込む。
--  ファイルが無い環境 (Linuxデスクトップ/mac 等) ではフォールバック値を使う。
-- ==========================================================================
-- フォールバック配色は，このファイルを更新した時点の実際の壁紙
-- (matugen-apply が生成した ~/.cache/matugen/colors.lua) をそのまま焼き込んだもの。
-- 壁紙をまた変えても，matugenキャッシュがある環境では常にキャッシュ側が
-- 優先されるためフォールバックの古さは実害が無い。
local M = {
  accent = "#a2c9fd",
  tertiary = "#d7bde4",
  secondary = "#bbc7db",
  complement = "#f2d4ad",
  triad = "#f2adcb",
  text = "#e1e2e8",
  muted = "#c3c6cf",
  surface = "#272a2f",
  on_accent = "#111418",
  accent_pale = "#c7dffe",
  error = "#ffb4ab",
  selection_bg = "#272a2f",
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
