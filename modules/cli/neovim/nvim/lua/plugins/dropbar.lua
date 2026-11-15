-- パンくず (dropbar.nvim): ウィンドウ上部 (winbar) に、
-- 「ディレクトリ › ファイル › 関数 › …」の形で、今いる場所を出す。
--   ・パス: cwd (プロジェクト) からの相対パス
--   ・その右: LSP / treesitter のシンボル (関数・クラス・見出しなど)
--   ・マウスでクリックすると、その階層のメニューが開く (同じ階層のファイル・兄弟のシンボル)
-- Neovim 0.10 以上が必要。配色は vim-options.lua の ColorScheme フックで当てる
return {
  "Bekaboo/dropbar.nvim",
  -- keys を指定すると lazy.nvim が「キーを押すまで読み込まない」扱いにするため、
  -- 起動時に読み込む (winbar を、最初から出しておきたい)
  lazy = false,
  opts = {
    icons = {
      ui = {
        bar = {
          separator = " \u{203a} ", -- ›
          extends = "\u{2026}",
        },
      },
    },
  },
  keys = {
    {
      "<leader>;",
      function() require("dropbar.api").pick() end,
      desc = "Breadcrumb: pick a level",
    },
  },
}
