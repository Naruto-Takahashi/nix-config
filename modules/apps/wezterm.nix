# =========================================================================
# WezTerm ターミナルエミュレータ宣言的設定モジュール
# =========================================================================
{ config, pkgs, ... }:

{
  # WezTerm パッケージの有効化
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
  };

  # -----------------------------------------------------------------------
  # wezterm.lua 設定ファイルの宣言的自動生成
  # -----------------------------------------------------------------------
  xdg.configFile."wezterm/wezterm.lua".text = ''
    local wezterm = require("wezterm")
    local config = wezterm.config_builder()

    config.automatically_reload_config = true
    config.scrollback_lines = 3000
    config.font = wezterm.font 'HackGen Console NF'
    config.adjust_window_size_when_changing_font_size = false

    -- OS判定（macOSかどうか）
    local is_darwin = wezterm.target_triple:find("darwin") ~= nil

    -- リモート接続時（DISPLAY番号が10以上）はフォントを小さくする
    local display = os.getenv("DISPLAY") or ""
    local is_remote = display:match(":[1-9]%d") ~= nil
    config.font_size = is_remote and 10.0 or (is_darwin and 20.0 or 12.0)

    config.initial_cols = is_darwin and 140 or 120
    config.initial_rows = is_darwin and 40 or 35
    config.use_ime = true
    config.ime_preedit_rendering = "Builtin"
    config.warn_about_missing_glyphs = false
    config.window_close_confirmation = 'NeverPrompt'
    config.window_background_opacity = 0.75
    config.macos_window_background_blur = 20

    ----------------------------------------------------
    -- Tab
    ----------------------------------------------------
    -- タイトルバーを非表示にし、マウスでのドラッグリサイズを有効化
    config.window_decorations = is_darwin and "RESIZE" or "NONE"
    -- タブバーの表示
    config.show_tabs_in_tab_bar = true
    -- タブが一つだけの時はタブバーを非表示にするか
    config.hide_tab_bar_if_only_one_tab = true
    -- falseにするとタブバーの透過が効かなくなる
    -- config.use_fancy_tab_bar = false

    -- タブバーの透過設定
    config.window_frame = {
      inactive_titlebar_bg = "none",
      active_titlebar_bg = "none",
    }

    -- タブバーを背景色に合わせる
    -- config.window_background_gradient = {
    --   colors = { "#000000" },
    -- }

    -- タブの追加ボタンを非表示
    config.show_new_tab_button_in_tab_bar = true
    -- nightlyのみ使用可能
    -- タブの閉じるボタンを非表示
    config.show_close_tab_button_in_tabs = true

    -- タブの配色設定（背景のみを透過させ，タブ名などのテキストをハッキリ表示させます）
    config.colors = {
      tab_bar = {
        background = "none",
        active_tab = {
          bg_color = "#ffc20d",
          fg_color = "#ffffff",
        },
        inactive_tab = {
          bg_color = "#333333",
          fg_color = "#a0a9cb",
        },
        inactive_tab_hover = {
          bg_color = "#444444",
          fg_color = "#ffffff",
        },
        new_tab = {
          bg_color = "#333333",
          fg_color = "#ffffff",
        },
        new_tab_hover = {
          bg_color = "#ffc20d",
          fg_color = "#ffffff",
        },
        inactive_tab_edge = "none",
      },
      cursor_bg = '#ffc20d',
      cursor_fg = 'white',
      cursor_border = '#ffc20d',
    }

    -- タブの形をカスタマイズ
    -- タブの左側の装飾
    local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
    -- タブの右側の装飾
    local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

    wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
      local background = "#333333"
      local foreground = "#f0f0f0"
      local edge_background = "none"
      local edge_foreground = background

      if tab.is_active then
        background = "#ffc20d"
        foreground = "#FFFFFF"
        edge_foreground = background
      end

      -- 1. まずデフォルトのタイトルを取得
      local title_text = tab.active_pane.title

      -- 2. 裏で動いているプログラムのファイル名を取得（例: "C:\Windows\System32\cmd.exe"）
      local process = tab.active_pane.foreground_process_name or ""

      -- 3. プロセス名に含まれる文字でタイトルを強制上書き
      if process:find("cmd.exe") then
        title_text = "CMD"
      elseif process:find("powershell.exe") or process:find("pwsh.exe") then
        title_text = "PowerShell"
      elseif process:find("wsl.exe") or process:find("wslhost.exe") then
        title_text = "Ubuntu"  -- WSLなら「Ubuntu」にする
      elseif process:find("nvim") then
        title_text = "Neovim"  -- ついでにNeovimを開いている時もわかりやすく
      end

      local title = "   " .. wezterm.truncate_right(title_text, max_width - 1) .. "   "

      return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
      }
    end)

    -- =============================================================================
    -- Shell Configuration (Auto-detected for OS platform)
    -- =============================================================================
    local is_windows = wezterm.target_triple:find("windows") ~= nil

    if is_windows then
      -- 起動時に WSL (Ubuntu) を立ち上げる設定 (ホームディレクトリで開始)
      config.default_prog = { 'wsl.exe', '--cd', '~' }

      -- 「＋」ボタンをクリックしたときのメニュー
      config.launch_menu = {
        {
          -- PowerShell Core (pwsh)
          label = 'PowerShell',
          args = { 'pwsh.exe', '-NoLogo' },
        },
        {
          -- WSL Ubuntu の起動
          label = 'WSL (Ubuntu)',
          args = { 'wsl.exe', '--cd', '~' },
        },
      }
    else
      -- Linuxネイティブ環境用のデフォルト設定 (標準ログインシェルを自動取得して立ち上げる)
      -- デフォルトのZshがあればそれを利用し、無ければ規定の動作にします
      config.default_prog = { 'zsh' }
      config.launch_menu = {}
    end

    ----------------------------------------------------
    -- keybinds
    ----------------------------------------------------
    config.disable_default_key_bindings = true
    config.keys = require("keybinds").keys
    config.key_tables = require("keybinds").key_tables
    config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }

    return config
  '';

  # -----------------------------------------------------------------------
  # keybinds.lua 設定ファイルの宣言的自動生成
  # -----------------------------------------------------------------------
  xdg.configFile."wezterm/keybinds.lua".text = ''
    local wezterm = require("wezterm")
    local act = wezterm.action

    -- WSLを使用している場合はWSLで、そうでなければデフォルトで分割する関数
    local function split_pane(direction)
      return wezterm.action_callback(function(window, pane)
        local dim = { direction = direction }
        local proc = pane:get_foreground_process_name()
        local cwd_uri = pane:get_current_working_dir()

        -- プロセス名に "wsl" が含まれていれば wsl.exe を起動
        if proc and (proc:find("wsl.exe") or proc:find("wslhost.exe")) then
          if cwd_uri then
            -- WSLの場合は file_path をそのまま使う (/home/nalt/...)
            dim.command = { args = { "wsl.exe", "--cd", cwd_uri.file_path } }
          else
            dim.command = { args = { "wsl.exe" } }
          end
        elseif proc and (proc:find("powershell.exe") or proc:find("pwsh.exe")) then
          dim.command = { args = { "powershell.exe", "-NoLogo" } }
        end
        -- PowerShellなどの場合は dim.cwd を指定せずデフォルトの挙動に任せる

        window:perform_action(act.SplitPane(dim), pane)
      end)
    end

    -- Show which key table is active in the status area
    wezterm.on("update-right-status", function(window, pane)
      local name = window:active_key_table()
      if name then
        name = "TABLE: " .. name
      end
      window:set_right_status(name or "")
    end)

    return {
      keys = {
        -- ============================================================
        -- Leader Key (Ctrl+Space) -> Tab操作
        -- ============================================================

        -- Leader + t で新しいタブを作成 (Tab)
        { key = "t", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },

        -- Leader + T (Shift+t) で PowerShell を新しいタブで開く
        { key = "T", mods = "LEADER|SHIFT", action = act.SpawnCommandInNewTab { args = { "pwsh.exe", "-NoLogo" } } },

        -- Leader + w でタブを閉じる (Close Window)
        { key = "w", mods = "LEADER", action = act({ CloseCurrentTab = { confirm = true } }) },

        -- ============================================================
        -- ワークスペース関連 (W に変更)
        -- ============================================================

        -- Leader + Shift + w (大文字W) でワークスペース選択
        { key = "W", mods = "LEADER|SHIFT", action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }), },

        -- ワークスペース名変更
        {
          key = "$", mods = "LEADER",
          action = act.PromptInputLine({
            description = "(wezterm) Set workspace title:",
            action = wezterm.action_callback(function(win, pane, line)
              if line then wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line) end
            end),
          }),
        },

        -- ============================================================
        -- その他の便利なショートカット
        -- ============================================================

        -- タブの移動 (Leader + n / p) next/previous
        { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
        { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

        -- タブの入れ替え
        { key = "{", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = -1 }) },
        { key = "}", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = 1 }) },

        -- 数字キーでの移動 (Alt + 数字)
        { key = "1", mods = "ALT", action = act.ActivateTab(0) },
        { key = "2", mods = "ALT", action = act.ActivateTab(1) },
        { key = "3", mods = "ALT", action = act.ActivateTab(2) },
        { key = "4", mods = "ALT", action = act.ActivateTab(3) },
        { key = "5", mods = "ALT", action = act.ActivateTab(4) },
        { key = "6", mods = "ALT", action = act.ActivateTab(5) },
        { key = "7", mods = "ALT", action = act.ActivateTab(6) },
        { key = "8", mods = "ALT", action = act.ActivateTab(7) },
        { key = "9", mods = "ALT", action = act.ActivateTab(-1) },

        -- ペイン操作 (分割・移動)
        { key = "d", mods = "LEADER", action = split_pane("Down") },
        { key = "r", mods = "LEADER", action = split_pane("Right") },
        { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
        { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
        { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
        { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
        { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
        { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

        -- コピーモード (Leader + [ )
        { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

        -- コマンドパレット (Ctrl + Shift + P)
        { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

        -- コピー & 貼り付け (Ctrl + Shift + C/V 及び CMD + C/V)
        { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
        { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
        {
          key = "c",
          mods = "CMD",
          action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
              window:perform_action(act.CopyTo("Clipboard"), pane)
            else
              window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
            end
          end),
        },
        { key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },

        -- フォントサイズ
        { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
        { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
        { key = "0", mods = "CTRL", action = act.ResetFontSize },

        -- 設定リロード
        { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

        -- キーテーブル
        { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
        { key = "a", mods = "LEADER", action = act.ActivateKeyTable({ name = "activate_pane", timeout_milliseconds = 1000 }) },

        -- キーバインド一覧
        {
          key = "m",
          mods = "LEADER",
          action = act.OpenUri("https://github.com/Naruto-Takahashi/dotfiles/blob/main/wezterm/KEYBINDINGS.md"),
        },
      },

      -- キーテーブル設定
      key_tables = {
        resize_pane = {
          { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
          { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
          { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
          { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
          { key = "Enter", action = "PopKeyTable" },
          { key = "Escape", action = "PopKeyTable" },
        },
        activate_pane = {
          { key = "h", action = act.ActivatePaneDirection("Left") },
          { key = "l", action = act.ActivatePaneDirection("Right") },
          { key = "k", action = act.ActivatePaneDirection("Up") },
          { key = "j", action = act.ActivatePaneDirection("Down") },
        },
        copy_mode = {
          { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
          { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
          { key = "q", mods = "NONE", action = act.CopyMode("Close") },
          { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
          { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
          { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
          { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
          { key = "y", mods = "NONE", action = act.CopyTo("Clipboard") },
          { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
          { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
          { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
          { key = "Enter", mods = "NONE", action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },
        },
      },
    }
  '';
}
