-- バッファタブライン (heirline.nvim)
-- 斜めのバッジ型タブ: 番号の「頭」+ ファイル名の「本体」。斜辺はどれも右上がりの「/」
-- (ステータスライン・WezTerm のタブと同じ形)。matugen パレットで描く。
return {
  "rebelot/heirline.nvim",
  event = "UIEnter",
  config = function()
    local mc = require("matugen")
    local utils = require("heirline.utils")
    local blend = require("blend")

    -- タブラインの地は透過 (本文と同じ)。タブの淡い地は surface から作る

    -- 配色: グレーは使わず、accent (黄色) 1色の濃淡だけで塗り分ける。
    --   本体: 全タブ共通の薄い面 (surface を accent へ 12%)。
    --   頭 (番号): 状態を示す。アクティブ = accent のソリッド / 非アクティブ = 28% の面。
    --   文字: アクティブ = accent の太字 / 非アクティブ = muted。
    -- WezTerm のタブ (wezterm.lua の TAB_ON_BG / TAB_OFF_BG) も、同じ「surface を accent へ
    -- ブレンド」の式 (アクティブ 30% / 非アクティブ 12%) で、色味をそろえている
    -- 斜辺の三角グリフ: ◢ 左端 / ◤ 頭と本体の継ぎ目 / ◤ 右端 (どれも斜辺は "/")
    local SLANT_L, JOINT, SLANT_R = "\u{e0ba}", "\u{e0bc}", "\u{e0bc}"
    local function tonal(t) return blend(mc.surface, mc.accent, t) end
    local c = {
      head_on = { fg = mc.on_accent, bg = mc.accent, bold = true },
      body_on = { fg = mc.accent, bg = tonal(0.12), bold = true },
      head_off = { fg = mc.text, bg = tonal(0.28) },
      body_off = { fg = mc.muted, bg = tonal(0.12) },
    }
    local function pick(self, on, off) return self.is_active and on or off end

    -- listed バッファの何番目か (1 始まり)
    local function buf_index(bufnr)
      local i = 0
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
          i = i + 1
          if b == bufnr then return i end
        end
      end
      return 0
    end

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
      -- タブ間の隙間は2つ目以降の左にだけ置く
      {
        provider = function(self) return buf_index(self.bufnr) > 1 and " " or "" end,
        hl = { bg = "NONE" },
      },
      -- 左端の斜辺 (頭の色)
      {
        provider = SLANT_L,
        hl = function(self) return { fg = pick(self, c.head_on, c.head_off).bg, bg = "NONE" } end,
      },
      -- 頭 (番号)
      {
        provider = function(self) return " " .. buf_index(self.bufnr) .. " " end,
        hl = function(self) return pick(self, c.head_on, c.head_off) end,
      },
      -- 頭と本体の継ぎ目の斜辺 (左上が頭の色、右下が本体の色)
      {
        provider = JOINT,
        hl = function(self)
          return { fg = pick(self, c.head_on, c.head_off).bg, bg = pick(self, c.body_on, c.body_off).bg }
        end,
      },
      -- 本体 (ファイル名 + 変更マーク)
      {
        provider = function(self)
          local name = self.filename == "" and "[No Name]" or vim.fn.fnamemodify(self.filename, ":t")
          local mod = vim.bo[self.bufnr].modified and " \u{25cf}" or ""
          return " " .. name .. mod .. " "
        end,
        hl = function(self) return pick(self, c.body_on, c.body_off) end,
      },
      -- 右端の斜辺 (本体の色)
      {
        provider = SLANT_R,
        hl = function(self) return { fg = pick(self, c.body_on, c.body_off).bg, bg = "NONE" } end,
      },
    }

    -- heirlineのbuflist既定実装(get_bufs)は全タブページ共通のグローバルな
    -- listedバッファを表示する。タブページ単位にスコープしようとBufEnterで
    -- 独自追跡するリファクタを試したが，反映が1テンポ遅れる副作用が出て
    -- 元のバグ(diffview等の別タブに元タブのバッファが混ざる)より体験が
    -- 悪化したため撤回。既定のグローバル一覧に戻す。
    local BufferLine = utils.make_buflist(
      Buffer,
      { provider = " \u{2039} ", hl = { fg = mc.muted, bg = "NONE" } }, -- 左に隠れタブあり
      { provider = " \u{203a} ", hl = { fg = mc.muted, bg = "NONE" } }  -- 右に隠れタブあり
    )
    local function count_listed_buffers()
      return #vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
    end

    -- Vimのタブページ(diffview等が専用タブで開くやつ)一覧 (右寄せ)。バッファタブと同じ
    -- 斜めのバッジの形だが，番号だけで，色相をpale(accent)にしてバッファタブとは
    -- 別種の区切りだと分かるようにする。lualineの`tabs`コンポーネントでは
    -- リスト内の区切り文字がアイテムごとの色を無視して浮いてしまう問題が
    -- あったが，heirlineは各パーツのhlを自分で計算するので破綻しない。
    local pale_accent = blend(mc.accent, "#ffffff", 0.4)
    local page_off_bg = tonal(0.28)

    local TabPage = {
      -- マウス左クリックでそのタブページに切り替え
      on_click = {
        callback = function(_, minwid) vim.schedule(function() vim.api.nvim_set_current_tabpage(minwid) end) end,
        minwid = function(self) return self.tabpage end,
        name = "heirline_tabline_tabpage_callback",
      },
      { provider = function(self) return self.tabnr > 1 and " " or "" end, hl = { bg = "NONE" } },
      {
        provider = SLANT_L,
        hl = function(self) return { fg = self.is_active and pale_accent or page_off_bg, bg = "NONE" } end,
      },
      {
        provider = function(self) return " " .. self.tabnr .. " " end,
        hl = function(self)
          if self.is_active then
            return { fg = mc.on_accent, bg = pale_accent, bold = true }
          end
          return { fg = mc.text, bg = page_off_bg }
        end,
      },
      {
        provider = SLANT_R,
        hl = function(self) return { fg = self.is_active and pale_accent or page_off_bg, bg = "NONE" } end,
      },
    }

    local TabPageList = utils.make_tablist(TabPage)

    require("heirline").setup({
      tabline = {
        BufferLine,
        { provider = "%=", hl = { bg = "NONE" } }, -- 右寄せ (タブページ) 用のフレキシブルスペーサー
        -- タブページが2枚以上の時だけ表示 (diffview等が開いていない通常時は非表示)
        {
          condition = function() return #vim.api.nvim_list_tabpages() > 1 end,
          TabPageList,
        },
      },
    })

    -- タブライン自体の地は "NONE" の帯 (台紙)
    vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

    -- タブラインは常に表示する (バッファが1つでも帯の行を残す)。
    -- 本文の上に必ず帯がある構造にそろえて、画面の枠を崩さないため
    local function update_showtabline()
      vim.o.showtabline = 2
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
