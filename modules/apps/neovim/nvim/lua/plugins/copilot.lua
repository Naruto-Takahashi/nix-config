return {
  -- Core Copilot engine
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy", -- LSP を nvim 起動直後に初期化し，InsertEnter 前に接続完了させる
    config = function()
      require("copilot").setup({
        copilot_node_command = vim.fn.exepath("node"),
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = false, -- nvim-cmp と共存させるため明示的に false に設定
          keymap = {
            accept = false, -- completions.luaでTabキーハンドラをマージして対応するため無効化
          },
        },
        panel = { enabled = false },
        logger = {
          file_log_level = vim.log.levels.TRACE, -- デバッグ用：動作確認後は OFF に戻す
        },
      })

      -- 提案テキストの色を黄色 (#ffc20d) に設定
      vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#ffc20d" })

      -- カラースキーマの再読み込み時にも色を維持
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#ffc20d" })
        end,
      })
    end,
  },
}
