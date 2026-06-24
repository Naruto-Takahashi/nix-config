return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    -- Windows環境用コンパイラ設定
    if vim.fn.has("win32") == 1 then
      require("nvim-treesitter.install").compilers = { "gcc" }
    end

    -- nvim-treesitterの設定
    require("nvim-treesitter.configs").setup({
      ensure_installed = { 
        "rust", "c", "cpp", "lua", "vim", "vimdoc", "query", 
        "python", "javascript", "typescript", "markdown", "markdown_inline" 
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      -- テキストオブジェクトの設定 (移動・選択)
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- カーソルが対象より前にある場合、自動的にジャンプして選択
          keymaps = {
            ["af"] = "@function.outer", -- 関数全体を選択
            ["if"] = "@function.inner", -- 関数の中身を選択
            ["ac"] = "@class.outer",    -- クラス全体を選択
            ["ic"] = "@class.inner",    -- クラスの中身を選択
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- 移動履歴(jumplist)に残す
          goto_next_start = {
            ["]m"] = "@function.outer", -- 次の関数の先頭へ
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer", -- 次の関数の末尾へ
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer", -- 前の関数の先頭へ
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer", -- 前の関数の末尾へ
            ["[]"] = "@class.outer",
          },
        },
      },
    })
  end
}