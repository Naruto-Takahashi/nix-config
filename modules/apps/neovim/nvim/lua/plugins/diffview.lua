return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>ld", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>lh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History" },
    { "<leader>lc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
  },
}
