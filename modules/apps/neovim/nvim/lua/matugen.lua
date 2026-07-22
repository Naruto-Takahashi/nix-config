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
  accent = "#86d1e9",
  tertiary = "#c1c4eb",
  secondary = "#b2cad3",
  complement = "#dda492",
  triad = "#dd92cb",
  text = "#dee3e6",
  muted = "#bfc8cc",
  surface = "#252b2d",
  on_accent = "#0f1416",
  accent_pale = "#b6e3f2",
  error = "#ffb4ab",
  selection_bg = "#252b2d",
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
