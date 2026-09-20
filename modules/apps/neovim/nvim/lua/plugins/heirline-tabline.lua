-- バッファタブライン (heirline.nvim)
-- WezTerm のタブと同じ平行四辺形タブを matugen パレットで描く。
-- (bufferline では三角キャップの色連鎖が制御できないため自作している)
return {
  "rebelot/heirline.nvim",
  event = "UIEnter",
  config = function()
    local mc = require("matugen")
    local utils = require("heirline.utils")

    -- 1つのバッファタブ: 平行四辺形 (左下三角 + 本体 + 右上三角)。
    -- アクティブ = accent、非アクティブ = surface (WezTerm タブと同じ)
    local LEFT_TRI = "\u{e0ba}"
    local RIGHT_TRI = "\u{e0bc}"

    local Buffer = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      end,
      -- マウス左クリックでそのバッファに切り替え
      on_click = {
        callback = function(_, minwid)
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(minwid) then
              vim.api.nvim_set_current_buf(minwid)
            end
          end)
        end,
        minwid = function(self) return self.bufnr end,
        name = "heirline_tabline_buffer_callback",
      },
      -- 左下三角
      {
        provider = LEFT_TRI,
        hl = function(self)
          return { fg = self.is_active and mc.accent or mc.surface }
        end,
      },
      -- タブ本体
      {
        provider = function(self)
          local name = self.filename == "" and "[No Name]" or vim.fn.fnamemodify(self.filename, ":t")
          local mod = vim.bo[self.bufnr].modified and " \u{25cf}" or ""
          return " " .. name .. mod .. " "
        end,
        hl = function(self)
          if self.is_active then
            return { fg = mc.on_accent, bg = mc.accent, bold = true }
          end
          -- 非アクティブ: WezTerm の非アクティブタブと同じ surface ブロック
          return { fg = mc.muted, bg = mc.surface }
        end,
      },
      -- 右上三角
      {
        provider = RIGHT_TRI,
        hl = function(self)
          return { fg = self.is_active and mc.accent or mc.surface }
        end,
      },
    }

    -- heirlineのbuflist既定実装(get_bufs)は全タブページ共通のグローバルな
    -- listedバッファを表示する。タブページ単位にスコープしようとBufEnterで
    -- 独自追跡するリファクタを試したが，反映が1テンポ遅れる副作用が出て
    -- 元のバグ(diffview等の別タブに元タブのバッファが混ざる)より体験が
    -- 悪化したため撤回。既定のグローバル一覧に戻す。
    local BufferLine = utils.make_buflist(
      Buffer,
      { provider = " \u{e0b3} ", hl = { fg = mc.muted } }, -- 左に隠れタブあり
      { provider = " \u{e0b1} ", hl = { fg = mc.muted } }  -- 右に隠れタブあり
    )
    local function count_listed_buffers()
      return #vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
    end

    -- Vimのタブページ(diffview等が専用タブで開くやつ)一覧。バッファタブと
    -- 同じ平行四辺形デザインだが，色相をpale(accent)にしてバッファタブとは
    -- 別種の区切りだと分かるようにする。lualineの`tabs`コンポーネントでは
    -- リスト内の区切り文字がアイテムごとの色を無視して浮いてしまう問題が
    -- あったが，heirlineは各パーツのhlを自分で計算するので破綻しない。
    local blend = require("blend")
    local pale_accent = blend(mc.accent, "#ffffff", 0.4)

    local TabPage = {
      -- マウス左クリックでそのタブページに切り替え
      on_click = {
        callback = function(_, minwid) vim.schedule(function() vim.api.nvim_set_current_tabpage(minwid) end) end,
        minwid = function(self) return self.tabpage end,
        name = "heirline_tabline_tabpage_callback",
      },
      {
        provider = LEFT_TRI,
        hl = function(self)
          return { fg = self.is_active and pale_accent or mc.surface }
        end,
      },
      {
        provider = function(self)
          return " " .. self.tabnr .. " "
        end,
        hl = function(self)
          if self.is_active then
            return { fg = mc.on_accent, bg = pale_accent, bold = true }
          end
          return { fg = mc.muted, bg = mc.surface }
        end,
      },
      {
        provider = RIGHT_TRI,
        hl = function(self)
          return { fg = self.is_active and pale_accent or mc.surface }
        end,
      },
    }

    local TabPageList = utils.make_tablist(TabPage)

    require("heirline").setup({
      tabline = {
        {
          condition = function() return count_listed_buffers() > 1 end,
          BufferLine,
        },
        { provider = "%=" }, -- 以降を右寄せにするフレキシブルスペーサー
        -- タブページが2枚以上の時だけ表示 (diffview等が開いていない通常時は非表示)
        {
          condition = function() return #vim.api.nvim_list_tabpages() > 1 end,
          TabPageList,
        },
      },
    })

    -- タブライン自体の地を透過させる
    vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })

    -- バッファ or タブページのどちらかが2つ以上のときだけタブラインを表示
    local function update_showtabline()
      local multi_tabpage = #vim.api.nvim_list_tabpages() > 1
      vim.o.showtabline = (count_listed_buffers() > 1 or multi_tabpage) and 2 or 0
    end
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter", "TabNew", "TabClosed", "TabEnter" }, {
      callback = function()
        update_showtabline()
        -- フォーカス移動で先頭矢印のハイライトが取り残されないよう明示再描画
        vim.cmd("redrawtabline")
      end,
    })
    update_showtabline()

    -- タブ操作キーマップ (bufferline 時代と同じ)
    vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true, desc = "Next buffer tab" })
    vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Prev buffer tab" })
    vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
    -- Q 1キーでも閉じられるようにする (標準の Q = マクロ再生は使用頻度が低いため転用)
    vim.keymap.set("n", "Q", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
    -- 現在のバッファ以外をまとめて閉じる
    vim.keymap.set("n", "<leader>bo", function()
      local cur = vim.api.nvim_get_current_buf()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if b ~= cur and vim.bo[b].buflisted and not vim.bo[b].modified then
          vim.api.nvim_buf_delete(b, {})
        end
      end
    end, { silent = true, desc = "Close other buffers" })
  end,
}
