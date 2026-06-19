return {
  -- Core Copilot engine
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("copilot").setup({
        copilot_node_command = vim.fn.expand("~/.nix-profile/bin/node"),
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>", -- Alt + l で補完確定
          },
        },
        panel = { enabled = false },
      })
    end,
  },

  -- Chat UI (Sidebar)
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      window = {
        layout = "vertical", -- 縦分割
        side = "right",      -- 右側に表示
        width = 0.4,         -- 画面の30%を占有
        relative = "editor",
      },
      show_help = true,
      mappings = {
        -- チャットウィンドウ内での移動設定
        reset = {
          normal = "<C-l>", -- デフォルトの reset と衝突を避けるため変更（任意）
          insert = "<C-l>",
        },
      },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      -- チャットウィンドウが開いたときに Ctrl-h/j/k/l を有効化する
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "copilot-chat",
        callback = function()
          vim.keymap.set("n", "<C-h>", "<C-w>h", { remap = true, buffer = true })
          vim.keymap.set("n", "<C-j>", "<C-w>j", { remap = true, buffer = true })
          vim.keymap.set("n", "<C-k>", "<C-w>k", { remap = true, buffer = true })
          vim.keymap.set("n", "<C-l>", "<C-w>l", { remap = true, buffer = true })
        end,
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Copilot Chat Toggle" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "Explain Code" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", desc = "Fix Code" },
    },
  },
}
