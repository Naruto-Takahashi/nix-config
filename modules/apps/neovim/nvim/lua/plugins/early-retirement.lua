-- 一定時間触っていない未編集バッファを自動で閉じる (タブの溜まりすぎ防止)
return {
  "chrisgrieser/nvim-early-retirement",
  event = "VeryLazy",
  opts = {
    -- 20分アクセスが無く、かつ未編集のバッファだけを静かに閉じる
    retirementAgeMins = 20,
    notificationOnAutoClose = false,
  },
}
