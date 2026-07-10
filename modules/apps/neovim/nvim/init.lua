-- ==========================================================================
--  NeoVim Configuration (Modularized)
-- ==========================================================================

-- 1. 基本設定を読み込む
require("vim-options")

-- 2. Lazy.nvim の準備 (ブートストラップ)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. プラグインのセットアップ
-- "plugins" と指定するだけで、lua/plugins/ フォルダ内の全ファイルを読み込みます
local config_dir = vim.fn.stdpath("config")
local lockfile_path = config_dir .. "/lazy-lock.json"
-- Nix store環境など設定フォルダが書き込み不可能な場合、書き込み可能なデータディレクトリに回避する
if vim.fn.filewritable(config_dir) == 0 then
  lockfile_path = vim.fn.stdpath("data") .. "/lazy-lock.json"
  -- リポジトリ(Nixストア)側の lazy-lock.json を正として同期する．
  -- これがないと、ローカル側の古いピンが残り続け、設定側でブランチを
  -- 変更してもプラグインが古いコミットに復元されてしまう．
  local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
  end
  local want = read_file(config_dir .. "/lazy-lock.json")
  if want and want ~= read_file(lockfile_path) then
    local f = io.open(lockfile_path, "w")
    if f then
      f:write(want)
      f:close()
    end
  end
end

require("lazy").setup("plugins", {
  lockfile = lockfile_path,
})