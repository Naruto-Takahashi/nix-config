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
    config.scrollback_lines = 10000
    config.font = wezterm.font 'HackGen Console NF'
    config.font_size = 12.0
    config.initial_cols = 120
    config.initial_rows = 35
    config.use_ime = true
    config.ime_preedit_rendering = "Builtin"
    config.warn_about_missing_glyphs = false
    config.window_background_opacity = 0.75
    config.macos_window_background_blur = 20

    ----------------------------------------------------
    -- Tab
    ----------------------------------------------------
    -- タイトルバーを表示し、マウスでのドラッグリサイズを確実に有効化
    config.window_decorations = "TITLE | RESIZE"
    -- タブバーの表示
    config.show_tabs_in_tab_bar = true
    -- タブが一つだけの時はタブバーを非表示にするか
    config.hide_tab_bar_if_only_one_tab = false
    -- falseにするとタブバーの透過が効かなくなる
    -- config.use_fancy_tab_bar = false

    -- タブバーの透過設定 (noneからソリッドカラーに変更することで、本体と同じ75%透過が適用されます)
    config.window_frame = {
      inactive_titlebar_bg = "#1a1b26",
      active_titlebar_bg = "#1a1b26",
    }

    -- タブバーを背景色に合わせる (透過の妨げになるグラデーションはコメントアウト)
    -- config.window_background_gradient = {
    --   colors = { "#000000" },
    -- }

    -- タブの追加ボタンを非表示
    config.show_new_tab_button_in_tab_bar = true
    -- nightlyのみ使用可能
    -- タブの閉じるボタンを非表示
    config.show_close_tab_button_in_tabs = true

    -- タブ同士の境界線を非表示
    config.colors = {
      tab_bar = {
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
    -- Shell Configuration (Updated for WSL Ubuntu)
    -- =============================================================================

    -- 💡 Linux環境での標準シェル（Bash）を指定し、ホームディレクトリで開始させます
    config.default_prog = { '/bin/bash', '-l' }

    -- 「＋」ボタンをクリックしたときのメニュー
    config.launch_menu = {
      {
        label = 'Bash (Default)',
        args = { '/bin/bash', '-l' },
      },
    }

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

        -- コピー & 貼り付け (Ctrl + Shift + C/V)
        { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
        { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

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
