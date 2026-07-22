return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
  },
  config = function(_, opts)
    require("persistence").setup(opts)

    -- persistence.nvimは素の:mksessionを使うため，Neo-treeのサイドバー
    -- (特殊なスクラッチバッファ)もそのままセッションに巻き込まれてしまう。
    -- 復元時にNeo-treeの内部状態までは再現されず，空表示になったり，
    -- heirlineのバッファタブラインに幽霊タブとしてカウントされたりする
    -- ため，保存前に閉じ，復元後に開き直す
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        pcall(vim.cmd, "Neotree close")
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceLoadPost",
      callback = function()
        pcall(vim.cmd, "Neotree show")
      end,
    })
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
