---@diagnostic disable: undefined-global

-- matugen配色（このファイルを更新した時点の実際の壁紙色をフォールバックとして焼き込み）．
-- io.open + パターンマッチで読み込みます (動作実績のある既存実装のまま維持)．
-- キャッシュファイルは1回だけ読み，以降は全箇所でこの pal を参照します．
local pal = {
  accent = "#a2c9fd",
  tertiary = "#d7bde4",
  secondary = "#bbc7db",
  complement = "#f2d4ad",
  triad = "#f2adcb",
  text = "#e1e2e8",
  muted = "#c3c6cf",
  surface = "#272a2f",
  on_accent = "#111418",
  error = "#ffb4ab",
  accent_pale = "#c7dffe",
}
do
  local fh = io.open((os.getenv("HOME") or "") .. "/.cache/matugen/colors.lua", "r")
  if fh then
    local s = fh:read("*a")
    fh:close()
    for k, v in s:gmatch('([%w_]+)%s*=%s*"(#%x+)"') do pal[k] = v end
  end
end

-- 2色を t:0..1 で混ぜる (「薄め色」計算用)。nvim (lualine.lua) と共有。
local blend = dofile((os.getenv("HOME") or "") .. "/.config/yazi/blend.lua")

-- yazi 26+ ではコンポーネントのrender差し替えが効かないため，
-- テーマ（th.mgr.cwd）を直接上書きしてヘッダーのパス色を変更します．
pcall(function()
  th.mgr.cwd = ui.Style():fg(pal.accent)
end)

-- ステータスバー: nvim lualine と同じ配色 (一点集中)。
--   塗りは「モード」(モード色のソリッド) と「位置」(淡い accent) の2か所だけ。
--   ほかは本文と同じ地 (端末の背景 = "reset") の上の文字だけ。区切りは斜め「/」
if pal.accent and pal.on_accent and pal.surface then
  local vis = pal.complement or pal.tertiary
  -- モード色: Normal = accent / Select = complement / Unset = muted (lualine と同じ割当)
  local function mode_bg()
    local mode = tostring(cx.active.mode)
    if mode == "select" then return vis
    elseif mode == "unset" then return pal.muted end
    return pal.accent
  end

  -- サイズ・割合などの副次情報: 地の上の muted の文字だけ (塗らない)
  local plain = ui.Style():fg(pal.muted):bg("reset")

  pcall(function()
    th.mode.normal_main = ui.Style():fg(pal.on_accent):bg(pal.accent):bold()
    th.mode.select_main = ui.Style():fg(pal.on_accent):bg(vis):bold()
    th.mode.unset_main  = ui.Style():fg(pal.on_accent):bg(pal.muted):bold()
    th.mode.normal_alt = plain
    th.mode.select_alt = plain
    th.mode.unset_alt  = plain
    -- 区切りは自前で描くので、既定の区切りは空にする
    th.status.sep_left  = { open = "", close = "" }
    th.status.sep_right = { open = "", close = "" }
    th.status.overall = ui.Style():fg(pal.text)
    -- パーセンテージ (progress) セグメントもフレーバーの青からパレット色へ
    th.status.progress_label  = ui.Style():fg(pal.text):bold()
    th.status.progress_normal = ui.Style():fg(pal.accent):bg("reset")
    th.status.progress_error  = ui.Style():fg(pal.error):bg("reset")
  end)

  -- ステータスバーの地: th.status.overall は効かず、フレーバー由来の青みの黒が
  -- 出てしまうため、描画関数を包んで、先頭に「端末の背景」の空白の行を敷いて消す
  pcall(function()
    local old_redraw = Status.redraw
    Status.redraw = function(self, ...)
      local els = old_redraw(self, ...)
      -- 元の先頭要素 (全面を塗る地) の直後 = 文字より下・既定の地より上に敷く
      table.insert(els, 2,
        ui.Line(ui.Span(string.rep(" ", self._area.w)):style(ui.Style():bg("reset"))):area(self._area))
      return els
    end
  end)

  -- モード: 既定は3文字略記 (NOR/SEL/UNS) のため、フル表記に置き換える。
  -- 両端は斜辺 (左端 ◢ / 右端 ◤)
  pcall(function()
    -- 既定コンポーネントの id は登録順 (mode=1, size=2, name=3)
    Status:children_remove(1, Status.LEFT)
    Status:children_add(function()
      local bg = mode_bg()
      return ui.Line {
        ui.Span("\u{e0ba}"):style(ui.Style():fg(bg):bg("reset")),
        ui.Span(" " .. tostring(cx.active.mode):upper() .. " "):style(ui.Style():fg(pal.on_accent):bg(bg):bold()),
        ui.Span("\u{e0bc}"):style(ui.Style():fg(bg):bg("reset")),
        ui.Span(" "):style(ui.Style():bg("reset")),
      }
    end, 1000, Status.LEFT)
  end)

  -- サイズ (608B) と割合 (Top): 既定はフレーバー由来の暗い地のブロックで、本文と同じ地
  -- から浮いてしまうため、地なしの文字に置き換える (表示内容は既定と同じ)。
  -- 既定コンポーネントの id: 左 size=2 / 右 percent=5
  pcall(function()
    Status:children_remove(2, Status.LEFT)
    Status:children_add(function()
      local h = cx.active.current.hovered
      if not h then return "" end
      local size = h:size() or h.cha.len
      return ui.Line { ui.Span(" " .. ya.readable_size(size) .. " "):style(plain) }
    end, 2000, Status.LEFT)

    Status:children_remove(5, Status.RIGHT)
    Status:children_add(function()
      local cursor = cx.active.current.cursor
      local length = #cx.active.current.files
      local text = "Top"
      if length > 0 and cursor + 1 == length and cursor ~= 0 then
        text = "Bot"
      elseif cursor ~= 0 and length ~= 0 then
        text = string.format("%2d%%", math.floor((cursor + 1) * 100 / length))
      end
      return ui.Line { ui.Span(" " .. text .. " "):style(plain) }
    end, 2000, Status.RIGHT)
  end)

  -- 右端の位置表示 (1/8): 既定はフレーバー由来の青灰色のブロックでテーマから浮く
  -- ため、lualine の位置表示 (z) と同じ「淡い accent の地 + accent の太字」に置き換える。
  -- 既定コンポーネントの id は左右で通しの登録順 (左: mode=1, size=2, name=3 /
  -- 右: perm=4, percent=5, position=6)。両端は斜辺
  pcall(function()
    Status:children_remove(6, Status.RIGHT)
    Status:children_add(function()
      local mc = mode_bg()
      local tint = blend(pal.surface, mc, 0.22)
      local cursor = cx.active.current.cursor
      local length = #cx.active.current.files
      return ui.Line {
        ui.Span("\u{e0ba}"):style(ui.Style():fg(tint):bg("reset")),
        ui.Span(string.format(" %d/%d ", length == 0 and 0 or cursor + 1, length))
          :style(ui.Style():fg(mc):bg(tint):bold()),
        ui.Span("\u{e0bc}"):style(ui.Style():fg(tint):bg("reset")),
      }
    end, 3000, Status.RIGHT)
  end)
end

-- フルボーダー（yazi 26 API / 公式 full-borderプラグイン相当）．
pcall(function()
  -- ボーダー色は matugen の muted と surface の中間 (控えめなグレー)
  local border = blend(pal.muted, pal.surface, 0.5)
  th.mgr.border_style = ui.Style():fg(border)
  local old_build = Tab.build

  Tab.build = function(self, ...)
    local bar = function(c, x, y)
      if x <= 0 or x == self._area.w - 1 or th.mgr.border_symbol ~= "│" then
        return ui.Bar(ui.Edge.TOP)
      end

      return ui.Bar(ui.Edge.TOP)
        :area(ui.Rect {
          x = x,
          y = math.max(0, y),
          w = ya.clamp(0, self._area.w - x, 1),
          h = math.min(1, self._area.h),
        })
        :symbol(c)
    end

    local c = self._chunks
    self._chunks = {
      c[1]:pad(ui.Pad.y(1)),
      c[2]:pad(ui.Pad.y(1)),
      c[3]:pad(ui.Pad.y(1)),
    }

    local style = th.mgr.border_style
    self._base = ya.list_merge(self._base or {}, {
      ui.Border(ui.Edge.ALL):area(self._area):type(ui.Border.ROUNDED):style(style),

      bar("┬", c[2].x, c[1].y),
      bar("┴", c[2].x, c[1].bottom - 1),
      bar("┬", c[2].right - 1, c[2].y),
      bar("┴", c[2].right - 1, c[2].bottom - 1),
    })

    old_build(self, ...)
  end
end)
