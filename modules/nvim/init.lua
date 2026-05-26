-- ==========================================================================
--  NeoVim Configuration (Modularized)
-- ==========================================================================

-- 1. 基本設定を読み込む
require("vim-options")

-- 2. Lazy.nvim の準備 (ブートストラップ)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
require("lazy").setup("plugins")