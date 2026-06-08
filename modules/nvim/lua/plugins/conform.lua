return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    -- ここに言語ごとのフォーマッターを指定します
    -- 未指定の場合は lsp_format = "fallback" により、LSP のフォーマッターが自動的に使われます
    formatters_by_ft = {
      -- デフォルトでは LSP によるフォーマットを優先・使用します
      -- 必要に応じて言語ごとのフォーマッター（例: python = { "isort", "black" }）を追加できます
    },
    -- 保存時の自動フォーマット設定
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = "fallback",
    },
  },
}
