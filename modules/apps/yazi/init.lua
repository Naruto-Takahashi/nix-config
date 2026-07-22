---@diagnostic disable: undefined-global

-- matugen配色（このファイルを更新した時点の実際の壁紙色をフォールバックとして焼き込み）．
-- io.open + パターンマッチで読み込みます (動作実績のある既存実装のまま維持)．
-- キャッシュファイルは1回だけ読み，以降は全箇所でこの pal を参照します．
local pal = {
  accent = "#86d1e9",
  tertiary = "#c1c4eb",
  secondary = "#b2cad3",
  complement = "#dda492",
  triad = "#dd92cb",
  text = "#dee3e6",
  muted = "#bfc8cc",
  surface = "#252b2d",
  on_accent = "#0f1416",
  error = "#ffb4ab",
  accent_pale = "#b6e3f2",
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

-- ステータスバー: Starship プロンプト / nvim lualine と同じデザイン．
--   モードセグメント = matugen accent 系 + Bold，鋭角 powerline 矢印で接続
if pal.accent and pal.on_accent and pal.surface then
  pcall(function()
    -- Normal = accent / Select = complement / Unset = muted (lualine と同じ割当)
    th.mode.normal_main = ui.Style():fg(pal.on_accent):bg(pal.accent):bold()
    th.mode.normal_alt  = ui.Style():fg(pal.accent):bg(pal.surface)
    local vis = pal.complement or pal.tertiary
    th.mode.select_main = ui.Style():fg(pal.on_accent):bg(vis):bold()
    th.mode.select_alt  = ui.Style():fg(vis):bg(pal.surface)
    th.mode.unset_main  = ui.Style():fg(pal.on_accent):bg(pal.muted):bold()
    th.mode.unset_alt   = ui.Style():fg(pal.muted):bg(pal.surface)
    -- 丸型ではなく Starship と同じ鋭角矢印
    th.status.sep_left  = { open = "", close = "\u{e0b0}" }
    th.status.sep_right = { open = "\u{e0b2}", close = "" }
    -- フレーバーがバー全体 (overall) に敷く青背景を無効化し端末地に馴染ませる
    th.status.overall = ui.Style():fg(pal.text)
    -- パーセンテージ (progress) セグメントもフレーバーの青からパレット色へ
    th.status.progress_label  = ui.Style():fg(pal.text):bold()
    th.status.progress_normal = ui.Style():fg(pal.accent):bg(pal.surface)
    th.status.progress_error  = ui.Style():fg(pal.error):bg(pal.surface)
  end)

  -- Starship の左端と同じ装飾ブロックをモードセグメントの前に追加。
  -- Normal は secondary、他モードはモード色を白側に寄せたパステル版
  pcall(function()
    Status:children_add(function()
      local mode = tostring(cx.active.mode)
      local mode_bg = pal.accent
      local block_bg = pal.secondary
      if mode == "select" then
        mode_bg = pal.complement or pal.tertiary
        block_bg = blend(mode_bg, "#ffffff", 0.4)
      elseif mode == "unset" then
        mode_bg = pal.muted
        block_bg = blend(mode_bg, "#ffffff", 0.4)
      end
      return ui.Line {
        ui.Span(" "):style(ui.Style():bg(block_bg)),
        ui.Span("\u{e0b0}"):style(ui.Style():fg(block_bg):bg(mode_bg)),
      }
    end, 100, Status.LEFT)
  end)

  -- 既定のモード表示は3文字略記 (NOR/SEL/UNS) のため、フル表記に置き換える
  pcall(function()
    -- 既定コンポーネントの id は登録順 (mode=1, size=2, name=3)
    Status:children_remove(1, Status.LEFT)
    Status:children_add(function()
      local mode = tostring(cx.active.mode)
      local bg = pal.accent
      if mode == "select" then bg = pal.complement or pal.tertiary
      elseif mode == "unset" then bg = pal.muted end
      return ui.Line {
        ui.Span(" " .. mode:upper() .. " "):style(ui.Style():fg(pal.on_accent):bg(bg):bold()),
        ui.Span("\u{e0b0}"):style(ui.Style():fg(bg):bg(pal.surface)),
      }
    end, 1000, Status.LEFT)
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
