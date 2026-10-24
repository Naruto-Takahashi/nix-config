return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  opts = {},
  keys = {
    { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "PR List" },
    { "<leader>go", "<cmd>Octo pr create<cr>", desc = "PR Create" },
    { "<leader>gr", "<cmd>Octo review start<cr>", desc = "PR Review Start" },
    { "<leader>gi", "<cmd>Octo issue list<cr>", desc = "Issue List" },
    { "<leader>gc", "<cmd>Octo issue create<cr>", desc = "Issue Create" },
    { "<leader>gs", "<cmd>Octo pr checkout<cr>", desc = "PR Checkout" },
  },
}
