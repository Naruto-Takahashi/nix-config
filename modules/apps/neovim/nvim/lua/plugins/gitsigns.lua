return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- hunk間ジャンプ ( [c / ]c は差分モード中の標準マップと衝突するため vim.wo.diff で分岐 )
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, "次のHunkへ")
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, "前のHunkへ")

        map("n", "<leader>hs", gs.stage_hunk, "Hunkをステージ")
        map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "選択範囲をステージ")
        map("n", "<leader>hr", gs.reset_hunk, "Hunkをリセット")
        map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "選択範囲をリセット")
        map("n", "<leader>hu", gs.undo_stage_hunk, "ステージ取り消し")
        map("n", "<leader>hp", gs.preview_hunk, "Hunkをプレビュー")
        map("n", "<leader>hb", gs.blame_line, "この行をBlame")
        map("n", "<leader>hS", gs.stage_buffer, "バッファ全体をステージ")
        map("n", "<leader>hR", gs.reset_buffer, "バッファ全体をリセット")
        map("n", "<leader>htb", gs.toggle_current_line_blame, "行末インラインBlameの切替")
        map("n", "<leader>htd", gs.toggle_deleted, "削除行の表示切替")
      end,
    })
  end
}