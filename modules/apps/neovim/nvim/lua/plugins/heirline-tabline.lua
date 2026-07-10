-- バッファタブライン (heirline.nvim)
-- WezTerm のタブ / Starship プロンプトと同じ「accent 色ブロック + ▶」意匠を
-- matugen パレットで描く。bufferline では ▶ の色連鎖が制御できないため自作する。
return {
  "rebelot/heirline.nvim",
  event = "UIEnter",
  config = function()
    local mc = require("matugen")
    local utils = require("heirline.utils")

    -- 1つのバッファタブ: [ name ●]▶ (アクティブのみ accent ブロック + ▶)
    local Buffer = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
      end,
      -- タブ本体
      {
        provider = function(self)
          local name = self.filename == "" and "[No Name]" or vim.fn.fnamemodify(self.filename, ":t")
          local mod = vim.bo[self.bufnr].modified and " \u{25cf}" or ""
          return "  " .. name .. mod .. "  "
        end,
        hl = function(self)
          if self.is_active then
            return { fg = mc.on_accent, bg = mc.accent, bold = true }
          end
          return { fg = mc.muted }
        end,
      },
      -- アクティブタブの右にだけ accent 色の ▶ を出す (背景は透過)
      {
        provider = function(self)
          return self.is_active and "\u{e0b0}" or " "
        end,
        hl = function(self)
          if self.is_active then
            return { fg = mc.accent }
          end
          return {}
        end,
      },
    }

    local BufferLine = utils.make_buflist(
      Buffer,
      { provider = " \u{e0b3} ", hl = { fg = mc.muted } }, -- 左に隠れタブあり
      { provider = " \u{e0b1} ", hl = { fg = mc.muted } }  -- 右に隠れタブあり
    )

    -- Starship / lualine / yazi と同じ左端の secondary 装飾ブロック
    local LeadBlock = {
      { provider = " ", hl = { bg = mc.secondary } },
      { provider = "\u{e0b0}", hl = { fg = mc.secondary } },
      { provider = " " },
    }

    require("heirline").setup({ tabline = { LeadBlock, BufferLine } })

    -- タブライン自体の地を透過させる
    vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })

    -- バッファが2つ以上のときだけタブラインを表示 (WezTerm と同じ挙動)
    local function update_showtabline()
      local listed = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
      end, vim.api.nvim_list_bufs())
      vim.o.showtabline = #listed > 1 and 2 or 0
    end
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter" }, {
      callback = function() vim.schedule(update_showtabline) end,
    })
    update_showtabline()

    -- タブ操作キーマップ (bufferline 時代と同じ)
    vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true, desc = "Next buffer tab" })
    vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Prev buffer tab" })
    vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
  end,
}
