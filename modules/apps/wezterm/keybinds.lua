local wezterm = require("wezterm")
local act = wezterm.action

-- WSLを使用している場合はWSLで，そうでなければデフォルトで分割する関数です．
local function split_pane(direction)
  return wezterm.action_callback(function(window, pane)
    local dim = { direction = direction }
    local proc = pane:get_foreground_process_name()
    local cwd_uri = pane:get_current_working_dir()

    -- プロセス名に "wsl" が含まれていれば wsl.exe を起動します．
    if proc and (proc:find("wsl.exe") or proc:find("wslhost.exe")) then
      if cwd_uri then
        -- WSLの場合は file_path をそのまま使います (/home/nalt/...)．
        dim.command = { args = { "wsl.exe", "--cd", cwd_uri.file_path } }
      else
        dim.command = { args = { "wsl.exe" } }
      end
    elseif proc and (proc:find("powershell.exe") or proc:find("pwsh.exe")) then
      dim.command = { args = { "powershell.exe", "-NoLogo" } }
    end
    -- PowerShellなどの場合は dim.cwd を指定せず，デフォルトの挙動に任せます．

    window:perform_action(act.SplitPane(dim), pane)
  end)
end

-- ステータスバーへのアクティブなキーテーブル表示設定を行います．
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

    -- Leader + t で新しいタブを作成（Tab）．
    { key = "t", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },

    -- Leader + T (Shift+t) でPowerShellを新しいタブで開きます．
    { key = "T", mods = "LEADER|SHIFT", action = act.SpawnCommandInNewTab { args = { "pwsh.exe", "-NoLogo" } } },

    -- Leader + w でタブを閉じます（確認ダイアログなし）．
    { key = "w", mods = "LEADER", action = act.CloseCurrentTab { confirm = false } },

    -- ============================================================
    -- ワークスペース関連（W に変更）
    -- ============================================================

    -- Leader + Shift + w（大文字W）でワークスペース選択を行います．
    { key = "W", mods = "LEADER|SHIFT", action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }), },

    -- ワークスペース名の変更を行います．
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

    -- タブの移動（Leader + n / p）next/previous
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

    -- タブの入れ替えを行います．
    { key = "{", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = -1 }) },
    { key = "}", mods = "LEADER|SHIFT", action = act({ MoveTabRelative = 1 }) },

    -- 数字キーでの移動（Alt + 数字）．
    { key = "1", mods = "ALT", action = act.ActivateTab(0) },
    { key = "2", mods = "ALT", action = act.ActivateTab(1) },
    { key = "3", mods = "ALT", action = act.ActivateTab(2) },
    { key = "4", mods = "ALT", action = act.ActivateTab(3) },
    { key = "5", mods = "ALT", action = act.ActivateTab(4) },
    { key = "6", mods = "ALT", action = act.ActivateTab(5) },
    { key = "7", mods = "ALT", action = act.ActivateTab(6) },
    { key = "8", mods = "ALT", action = act.ActivateTab(7) },
    { key = "9", mods = "ALT", action = act.ActivateTab(-1) },

    -- ペイン操作（分割・移動）．
    { key = "d", mods = "LEADER", action = split_pane("Down") },
    { key = "r", mods = "LEADER", action = split_pane("Right") },
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = false } },
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

    -- コピーモード（Leader + [）．
    { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

    -- コマンドパレット（Ctrl + Shift + P）．
    { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

    -- コピー & 貼り付け（Ctrl + Shift + C/V 及び CMD + C/V）．
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

    -- フォントサイズの調整を行います．
    { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    -- 設定のリロードを行います．
    { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

    -- キーテーブルの設定を行います．
    { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
    { key = "a", mods = "LEADER", action = act.ActivateKeyTable({ name = "activate_pane", timeout_milliseconds = 1000 }) },

    -- キーバインド一覧を表示します．
    {
      key = "m",
      mods = "LEADER",
      action = act.OpenUri("https://github.com/Naruto-Takahashi/dotfiles/blob/main/wezterm/KEYBINDINGS.md"),
    },
  },

  -- キーテーブルの詳細設定を行います．
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
