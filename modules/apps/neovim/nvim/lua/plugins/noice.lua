return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    -- 通知(vim.notify)は snacks.nvim の notifier が既に担当しているため、
    -- noice 側では奪わない (両方が vim.notify を取り合うと二重表示や
    -- ちらつきの原因になる)。noice はコマンドライン・検索・popupmenu の
    -- 見た目改善だけに専念させる
    notify = { enabled = false },
    lsp = {
      -- hover/signature も noice に乗せると snacks 由来の他の float と
      -- 干渉しやすいため、ひとまず素の挙動のままにする
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
        ["vim.lsp.util.stylize_markdown"] = false,
        ["cmp.entry.get_documentation"] = false,
      },
    },
    presets = {
      command_palette = true, -- コマンドラインと検索を画面上部にまとめて表示
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    -- starship のプロンプト記号 (❯) に統一
    cmdline = {
      format = {
        cmdline = { icon = "❯" },
        search_down = { icon = "❯" },
        search_up = { icon = "❯" },
      },
    },
  },
}
