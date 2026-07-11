local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- 配色：フォールバック値．matugen-colors.luaがあれば上書きします（yasb-themeが生成します）．
-- 他環境（Linuxデスクトップ/mac）ではファイルがなく，フォールバックがそのまま使われます．
local colors = {
  accent = "#ffc20d",
  tertiary = "#8ea4a2",
  secondary = "#d08770",
  text = "#c5c9c5",
  muted = "#a0a9cb",
  surface = "#333333",
  on_accent = "#ffffff",
}
local ok, m = pcall(require, "matugen-colors")
if ok and type(m) == "table" then
  for k, v in pairs(m) do colors[k] = v end
end

config.automatically_reload_config = true
config.scrollback_lines = 3000
config.font = wezterm.font 'HackGen Console NF'
config.adjust_window_size_when_changing_font_size = false

-- OS判定（macOSおよびWindowsかどうか）．
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- リモート接続時（DISPLAY番号が10以上）はフォントを小さくします．
local display = os.getenv("DISPLAY") or ""
local is_remote = display:match(":[1-9]%d") ~= nil
config.font_size = is_remote and 10.0 or (is_darwin and 20.0 or 12.0)

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
config.window_background_opacity = 0.85
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
config.window_decorations = (is_darwin or is_windows) and "RESIZE" or "NONE"
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.tab_max_width = 24
-- fancy タブバーはウィンドウ透過の外側で描画されアルファが黒に潰れるため，
-- 本体と同じ透過にできるレトロタブバー（ターミナル面と同レイヤー）を使います．
config.use_fancy_tab_bar = false

-- タブバーの配色（メイン表示領域との溶け込みが最優先）．
--   本体 = デフォルト黒背景 × window_background_opacity 0.85
--   バー地も同じ「黒 0.85」で塗ると境目なく馴染みます．
--   ("none" 指定は素通し=完全透過になるため使いません)
local BAR_BG = "rgba(0, 0, 0, 0.85)"

config.colors = {
  tab_bar = {
    background = BAR_BG,
    -- 実際のタブ描画は下の format-tab-title が行うため，ここは保険の既定値
    active_tab = { bg_color = colors.accent, fg_color = colors.on_accent },
    inactive_tab = { bg_color = BAR_BG, fg_color = colors.muted },
    inactive_tab_hover = { bg_color = BAR_BG, fg_color = colors.text },
    new_tab = { bg_color = BAR_BG, fg_color = colors.text },
    new_tab_hover = { bg_color = colors.accent, fg_color = colors.on_accent },
    inactive_tab_edge = "none",
  },
  cursor_bg = colors.tertiary,
  cursor_fg = 'white',
  cursor_border = colors.tertiary,
}

-- タブの形状: 平行四辺形 (左下三角 + 本体 + 右上三角)．
--   アクティブ = accent、非アクティブ = surface のグレーブロック
local LEFT_TRI = wezterm.nerdfonts.ple_lower_right_triangle
local RIGHT_TRI = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  -- プロセス名からタブ名を決めます．
  local title_text = tab.active_pane.title
  local process = tab.active_pane.foreground_process_name or ""

  if title_text:find("^✳") or title_text:lower():find("claude") then
    title_text = "Claude"
  elseif process:find("nvim") or title_text == "nvim" then
    title_text = "Neovim"
  elseif process:find("cmd.exe") then
    title_text = "CMD"
  elseif process:find("powershell.exe") or process:find("pwsh.exe") then
    title_text = "PowerShell"
  elseif process:find("wsl.exe") or process:find("wslhost.exe") then
    title_text = "Ubuntu"
  end

  local title = " " .. wezterm.truncate_right(title_text, max_width) .. " "

  local bg = colors.surface
  local fg = hover and colors.text or colors.muted
  local bold = "Normal"
  if tab.is_active then
    bg = colors.accent
    fg = colors.on_accent
    bold = "Bold"
  end

  return {
    -- 左下三角
    { Background = { Color = BAR_BG } },
    { Foreground = { Color = bg } },
    { Text = LEFT_TRI },
    -- 本体
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = bold } },
    { Text = title },
    { Attribute = { Intensity = "Normal" } },
    -- 右上三角
    { Background = { Color = BAR_BG } },
    { Foreground = { Color = bg } },
    { Text = RIGHT_TRI },
  }
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
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }

return config
