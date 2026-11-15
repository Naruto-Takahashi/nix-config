local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 配色：フォールバック値．matugen-colors.luaがあれば上書きします（matugen-applyが生成します）．
-- 他環境（Linuxデスクトップ/mac）ではファイルがなく，フォールバックがそのまま使われます．
-- このファイルを更新した時点の実際の壁紙色を焼き込んだもの
-- (nvim の lua/matugen.lua フォールバックと同じ値)
local colors = {
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
local ok, m = pcall(require, "matugen-colors")
if ok and type(m) == "table" then
  for k, v in pairs(m) do colors[k] = v end
end

config.automatically_reload_config = true
config.scrollback_lines = 3000
-- SSH切断時にbroken pipeで書き込みが繰り返し失敗すると、既定の
-- audible_bellがBEL文字を律儀に毎回鳴らし続けてしまう。無効化しておく
-- (根本対策は ~/.ssh/config の ServerAliveInterval/ServerAliveCountMax)
config.audible_bell = "Disabled"
-- ANSI 16色パレット。既定だと黄色が濁ったオレンジ寄りで、questionary(cz commit等)の
-- 選択カーソル表示などが見づらい。Matugenの役割色から個別に組むと破綻しやすいので、
-- WezTerm組み込みのkanagawa系スキーム(存在すれば)をそのまま採用する。
-- 見つからない場合は何もしない(デフォルトのまま)ので設定が壊れることはない。
-- config.color_scheme (名前指定) とconfig.colorsを併用すると、
-- selection_bg/selection_fgだけはWezTerm側の既知の癖でスキームの値が
-- 優先されてしまい、cursor_bg等は正しく上書きされるのに選択ハイライト
-- だけMatugen配色から浮いて見える不具合になっていた (実機で確認済み)。
-- 本来ANSI16色パレットだけを拝借したいので、color_schemeとしては
-- 設定せず、ansi/brightsだけ抜き出してconfig.colorsに直接統合する
-- (これで selection_bg/fg を含め全キーがMatugen色で確実に上書きされる)
local scheme_ansi = nil
local scheme_brights = nil
do
  local ok_schemes, schemes = pcall(function() return wezterm.color.get_builtin_schemes() end)
  if ok_schemes and schemes then
    local candidates = { "Kanagawa Dragon (Gogh)", "Kanagawa (Gogh)", "kanagawabones" }
    for _, name in ipairs(candidates) do
      if schemes[name] then
        scheme_ansi = schemes[name].ansi
        scheme_brights = schemes[name].brights
        break
      end
    end
  end
end
-- サブモニターで3枚目のウィンドウを開くとモザイク状に描画が崩れる問題への対処．
-- WebGpuに固定することで解消することを確認済み．
-- front_endはホットリロードでは反映されないため、変更後はWezTermの
-- プロセスを完全終了して再起動すること．
config.front_end = "WebGpu"
config.font = wezterm.font 'HackGen Console NF'
config.adjust_window_size_when_changing_font_size = false

-- OS判定（macOSおよびWindowsかどうか）．
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- リモート接続時（DISPLAY番号が10以上）はフォントを小さくします．
local display = os.getenv("DISPLAY") or ""
local is_remote = display:match(":[1-9]%d") ~= nil
config.font_size = is_remote and 10.0 or (is_darwin and 13.0 or 11.0)

config.initial_cols = is_darwin and 140 or 120
config.initial_rows = is_darwin and 40 or 35
config.use_ime = true
config.ime_preedit_rendering = "Builtin"
config.warn_about_missing_glyphs = false
config.window_close_confirmation = 'NeverPrompt'
config.skip_close_confirmation_for_processes_named = {
  "bash", "zsh", "fish", "sh", "tmux",
  "wsl.exe", "wslhost.exe", "conhost.exe",
  "powershell.exe", "pwsh.exe", "cmd.exe"
}
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
-- 本文の上下に控えめな余白 (タブバー自体は仕様上、常に上端に張り付く)
config.window_padding = { left = "1cell", right = "1cell", top = 6, bottom = 6 }
-- 本文はタブバー直下に固定 (間隔が常に一定になる)。
-- セル高の端数ピクセルはすべて下端に落ちる (ウィンドウ高さ次第で 0〜1行弱)
pcall(function()
  config.window_content_alignment = { horizontal = "Left", vertical = "Top" }
end)

if is_windows then
  config.tiling_desktop_environments = { "komorebi" }
end

----------------------------------------------------
-- タブバー設定
----------------------------------------------------
-- タイトルバーを非表示にし，マウスでのドラッグリサイズを有効化します．
-- 信号ボタンの統合 (INTEGRATED_BUTTONS) は試したが、他のエディタから開いたターミナルと
-- 見た目が変わってしまう (ボタンの分の空きなど) ため使わない
config.window_decorations = (is_darwin or is_windows) and "RESIZE" or "NONE"
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
-- + (新規タブ) と × (閉じる) のボタンは表示しない。タブは Cmd+T / Cmd+W などで開閉する。
-- (× は自前描画のレトロタブバーでは出ない。fancy タブバー専用の設定)
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
-- タブは全幅を等分して使う (format-tab-title が max_width ちょうどの幅で描く。
-- max_width は + ボタンの予約分を引いた、使える幅の等分)。
-- 既定の上限 (24) だと幅が頭打ちになるので、実質無制限にする
config.tab_max_width = 400
-- タブバーの右側は、ボタン (+ やウィンドウボタン) 用に幅が予約される。ボタンは使わないので
-- 文字を空にして、予約を減らす (右端は、Leader キーを押したときのモード表示
-- (keybinds.lua の update-right-status) の領域として使われる)
config.tab_bar_style = {
  new_tab = "", new_tab_hover = "",
  window_hide = "", window_hide_hover = "",
  window_maximize = "", window_maximize_hover = "",
  window_close = "", window_close_hover = "",
}
-- fancyタブバーを試したが、タブ形状(角丸/影)が固定でconfigから
-- 調整できず、縦線セパレータとも噛み合わなかったためレトロに戻す。
-- レトロタブバーはウィンドウ上端に常に張り付く仕様で、window_padding
-- (本文用) では余白を作れない。window_frame.border_top_height を試したが
-- Windowsでは効果なし (公式ドキュメント通りWayland向けの機能だった。
-- 実機で確認済み)。RESIZEのみのdecorationsでは上端に余白を作る手段が
-- WezTermに用意されていないため、この張り付きは受け入れる
config.use_fancy_tab_bar = false

-- タブバーの配色（メイン表示領域との溶け込みが最優先）．
--   alpha=1.0だと本体より明らかに濃い帯になり、逆にalpha=0.85でも
--   微妙な差が残る (実機で確認済み・原因未特定。タブバーの背景色
--   描画がwindow_background_opacityの合成パスと同じ扱いを受けて
--   いない可能性がある)。ひとまずwindow_background_opacityと同じ
--   0.95で妥協する。
--   色そのものはKanagawaスキームの背景(黒固定)ではなくMatugenの
--   colors.surface (画面本体の背景色と同じロール) から取る
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function blend_hex(h1, h2, t)
  local r1, g1, b1 = hex_to_rgb(h1)
  local r2, g2, b2 = hex_to_rgb(h2)
  return string.format("#%02x%02x%02x",
    math.floor(r1 + (r2 - r1) * t + 0.5),
    math.floor(g1 + (g2 - g1) * t + 0.5),
    math.floor(b1 + (b2 - b1) * t + 0.5))
end
-- タブバーの地: 帯の色はやめて、本文と同じ地 (surface + 同じ透過度) にする
local bg_r, bg_g, bg_b = hex_to_rgb(colors.surface)
local BAR_BG = string.format("rgba(%d, %d, %d, %s)", bg_r, bg_g, bg_b, tostring(config.window_background_opacity))

config.colors = {
  ansi = scheme_ansi,
  brights = scheme_brights,
  -- 画面本体の背景色。以前はどこにも明示指定しておらずWezTerm組み込みの
  -- 既定色(Matugenと無関係)のままだった。YASBバーの--baseと同じ
  -- Matugenの"surface"ロールに揃える (colors.surfaceはmatugen-colors.luaが
  -- あれば壁紙由来の値、無ければファイル先頭のフォールバック値になる)
  background = colors.surface,
  tab_bar = {
    background = BAR_BG,
    -- 実際のタブ描画は下の format-tab-title が行うため，ここは保険の既定値
    active_tab = { bg_color = BAR_BG, fg_color = colors.accent },
    inactive_tab = { bg_color = BAR_BG, fg_color = colors.muted },
    inactive_tab_hover = { bg_color = BAR_BG, fg_color = colors.text },
    new_tab = { bg_color = BAR_BG, fg_color = colors.text },
    new_tab_hover = { bg_color = colors.accent, fg_color = colors.on_accent },
    inactive_tab_edge = "none",
  },
  cursor_bg = colors.tertiary,
  cursor_fg = colors.surface,
  cursor_border = colors.tertiary,
  -- selection_bg/fgが未指定だとWezTerm組み込みの既定色にフォールバックし、
  -- 行選択時だけMatugen由来の配色から浮いて見えていた。カーソルと同じ
  -- 配色 (tertiary/surface) に揃える
  selection_bg = colors.tertiary,
  selection_fg = colors.surface,
}

-- タブの形状: 全幅を開いているタブで等分する (バッジなし)。文字は各タブの中央。
--   タブの境目は、右上がりの斜辺「/」 (nvim のタブ・ステータスと同じ向き) の平行四辺形。
--   アクティブ = 淡い accent の地 (30%) + accent の太字 / 非アクティブ = さらに薄い accent の地 (12%)。
--   タブバーは画面の一番上。切り替えは tab_bar_at_bottom (true で下)。
config.tab_bar_at_bottom = false

local SLANT_L = "\u{e0ba}" -- ◢ 先頭タブの左端の斜辺 "/"
local SLANT = "\u{e0bc}"   -- ◤ タブ同士の境目 / 最後のタブの右端の斜辺 "/"

-- グレーは使わず、accent (黄色) 1色の濃淡だけで塗り分ける。
-- アクティブ = surface を accent へ 30% の面 + accent の太字 / 非アクティブ = 12% の面 + muted。
-- nvim のバッファタブ (heirline-tabline.lua) も同じ式 (本体 12%・頭 28%) で、色味をそろえている
local TAB_ON_BG, TAB_ON_FG = blend_hex(colors.surface, colors.accent, 0.30), colors.accent
local TAB_OFF_BG, TAB_OFF_FG = blend_hex(colors.surface, colors.accent, 0.12), colors.muted

-- プロセス名からタブ名を決めます．
local function resolve_title(title_text, process)
  title_text = title_text or ""
  process = process or ""
  if title_text:find("^✳") or title_text:lower():find("claude") then
    return "Claude"
  elseif process:find("nvim") or title_text == "nvim" then
    return "Neovim"
  elseif process:find("cmd.exe") then
    return "CMD"
  elseif process:find("powershell.exe") or process:find("pwsh.exe") then
    return "PowerShell"
  elseif process:find("wsl.exe") or process:find("wslhost.exe") then
    return "Ubuntu"
  end
  -- ペインのタイトルが空のとき (プログラム終了直後など) はプロセス名で補う
  if title_text == "" then
    return process:match("([^/\\]+)$") or ""
  end
  return title_text
end

-- 文字列を幅 w のセルの中央に置く (左右は空白で埋める。日本語など全角の幅も考慮)
local function center(text, w)
  local tw = wezterm.column_width(text)
  if tw >= w then return wezterm.truncate_right(text, w) .. string.rep(" ", w - wezterm.column_width(wezterm.truncate_right(text, w))) end
  local left = math.floor((w - tw) / 2)
  return string.rep(" ", left) .. text .. string.rep(" ", w - tw - left)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title_text = resolve_title(tab.active_pane.title, tab.active_pane.foreground_process_name)
  local is_first = tab.tab_index == 0
  local is_last = tab.tab_index == #tabs - 1

  local bg, fg
  if tab.is_active then
    bg, fg = TAB_ON_BG, TAB_ON_FG
  else
    bg, fg = TAB_OFF_BG, TAB_OFF_FG
    if hover then fg = colors.text end
  end

  -- 右端の斜辺の背景 = 隣のタブの地の色 (最後のタブは帯の地)
  local next_bg = BAR_BG
  if not is_last then
    local nxt = tabs[tab.tab_index + 2]
    next_bg = (nxt and nxt.is_active) and TAB_ON_BG or TAB_OFF_BG
  end

  -- 使える幅を等分する (max_width は、予約分を引いた、タブ1枚あたりの幅)。
  -- Leader キーなどのモード表示 (右ステータス) が出ているときは、その幅の分だけ縮めて、
  -- 表示の場所を空ける (そうしないと、タブが全幅を使い切って、モード表示が見切れる)
  local slot = max_width
  local status_w = wezterm.GLOBAL["right_status_w_" .. tostring(tab.window_id)] or 0
  if status_w > 0 and #tabs > 0 then
    slot = math.floor((max_width * #tabs - status_w) / #tabs)
  end
  -- 1タブの幅 = slot。右端の斜辺(1)を引いた残りが、文字を中央に置く本体の幅。
  -- 先頭の左 (余白1 + 斜辺1) と最後の右 (余白1) は、ウィンドウの角丸との距離
  local body_w = slot - 1
  if is_first then body_w = body_w - 2 end
  if is_last then body_w = body_w - 1 end
  body_w = math.max(body_w, 1)

  local elements = {}
  if is_first then
    table.insert(elements, { Background = { Color = BAR_BG } })
    table.insert(elements, { Text = " " })
    table.insert(elements, { Foreground = { Color = bg } })
    table.insert(elements, { Text = SLANT_L })
  end
  table.insert(elements, { Background = { Color = bg } })
  table.insert(elements, { Foreground = { Color = fg } })
  if tab.is_active then
    table.insert(elements, { Attribute = { Intensity = "Bold" } })
  end
  table.insert(elements, { Text = center(title_text, body_w) })
  table.insert(elements, { Attribute = { Intensity = "Normal" } })
  -- 右端の斜辺 (左上がこのタブの地、右下が隣のタブの地)
  table.insert(elements, { Background = { Color = next_bg } })
  table.insert(elements, { Foreground = { Color = bg } })
  table.insert(elements, { Text = SLANT })
  if is_last then
    table.insert(elements, { Background = { Color = BAR_BG } })
    table.insert(elements, { Text = " " })
  end
  return elements
end)

----------------------------------------------------
-- シェル設定 (OS 別)
----------------------------------------------------
if is_windows then
  -- 起動時にWSL (Ubuntu) を立ち上げる設定です（ホームディレクトリで開始します）．
  config.default_prog = { 'wsl.exe', '--cd', '~' }

  -- 「＋」ボタンをクリックしたときのメニューです．
  config.launch_menu = {
    {
      -- PowerShell Core (pwsh) の設定です．
      label = 'PowerShell',
      args = { 'pwsh.exe', '-NoLogo' },
    },
    {
      -- WSL Ubuntuの起動設定です．
      label = 'WSL (Ubuntu)',
      args = { 'wsl.exe', '--cd', '~' },
    },
  }
else
  -- Linuxネイティブ環境用のデフォルト設定です（標準ログインシェルを自動取得して立ち上げます）．
  -- デフォルトのZshがあればそれを利用し，なければ規定の動作にします．
  config.default_prog = { 'zsh' }
  config.launch_menu = {}
end

----------------------------------------------------
-- キーバインド設定
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
-- Leaderキーはconfig.leader(1つしか設定できない)ではなく、Ctrl+;/Ctrl+Space
-- 両方から入れる自作key_table (keybinds.luaのleader_mode) として実装している。
-- CapsLock を Ctrl にしている都合上、Ctrl+Space は左手ホームポジションから
-- 遠く同指干渉も起きやすいため、右手小指で押せる Ctrl+; をメインに使い、
-- Ctrl+Space はサブとして併用できるようにしている

-- モニタをまたぐ起動位置指定 (Alt+Enter等でカーソルのあるモニタに開く) は
-- komorebi.ahk側で `wezterm-gui start --position screen:X,Y` のCLI引数として
-- 直接渡している (modules/wm/komorebi/komorebi.ahk 参照)。gui-startupイベント
-- 経由でspawn_windowにpositionを渡す方式も試したが実機で効果がなかったため、
-- こちらのCLI引数方式を採用している

return config
