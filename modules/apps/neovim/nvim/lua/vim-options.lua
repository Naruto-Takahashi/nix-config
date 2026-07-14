-- ==========================================================================
--  基本設定 (vim-options.lua)
-- ==========================================================================

vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set number")
vim.cmd("set relativenumber") -- 動画では relative number を使うことが多いので合わせますが、お好みで変えてください
vim.cmd("set clipboard=unnamedplus")
vim.cmd("set mouse=a")
vim.cmd("set cursorline")   -- カーソル行をハイライト
vim.cmd("set cursorcolumn") -- カーソル列をハイライト
vim.g.mapleader = " "       -- スペースキーをリーダーキーにする（Typecraft推奨）
vim.opt.showmode = false    -- "-- INSERT --" 表示はステータスバーにあるため不要
vim.opt.cmdheight = 0       -- コマンドライン行を隠して本文領域を1行広げる (入力時のみ出現)

-- matugen 配色 (フォールバック付き)
local mc = require("matugen")

-- Transparency settings (背景透過設定)
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        local hl = vim.api.nvim_set_hl
        local no_bg = { bg = "none" }
        hl(0, "Normal", no_bg)
        hl(0, "NormalFloat", no_bg)
        hl(0, "FloatBorder", no_bg)
        hl(0, "FloatTitle", no_bg)
        hl(0, "FloatFooter", no_bg)
        hl(0, "NeoTreeFloatBorder", no_bg)
        hl(0, "NeoTreeFloatTitle", no_bg)
        hl(0, "NeoTreeFloatNormal", no_bg)
        hl(0, "NeoTreeTitleBar", no_bg)
        hl(0, "NeoTreePreview", no_bg)
        -- フォルダのアイコンと名前は matugen の secondary (2番めの色)
        hl(0, "NeoTreeDirectoryIcon", { fg = mc.secondary })
        hl(0, "NeoTreeDirectoryName", { fg = mc.secondary })
        hl(0, "NeoTreeRootName", { fg = mc.secondary, bold = true })
        hl(0, "NormalNC", no_bg)
        hl(0, "SignColumn", no_bg)
        -- lualine の透過セクションは StatusLine にフォールバックするため、ここも透過必須
        hl(0, "StatusLine", no_bg)
        hl(0, "StatusLineNC", no_bg)
        hl(0, "LineNr", { bg = "none" })
        hl(0, "CursorLineNr", { bg = "none", bold = true })
        hl(0, "CursorLine", { bg = "#444444" })
        hl(0, "CursorColumn", { bg = "#444444" })
        -- hl(0, "CursorLine", { bg = "none", underline = true }) -- カーソル行の背景を表示するためにコメントアウト

        -- Telescope Transparency (Telescope の背景透過)
        hl(0, "TelescopeNormal", no_bg)
        hl(0, "TelescopeBorder", no_bg)
        hl(0, "TelescopePromptNormal", no_bg)
        hl(0, "TelescopePromptBorder", no_bg)
        hl(0, "TelescopeResultsNormal", no_bg)
        hl(0, "TelescopeResultsBorder", no_bg)
        hl(0, "TelescopePreviewNormal", no_bg)
        hl(0, "TelescopePreviewBorder", no_bg)

        -- Diagnostic Colors (エラーを赤，警告・情報・ヒントをゴールド化)
        hl(0, "DiagnosticError", { fg = "#fb4934" })
        hl(0, "DiagnosticWarn", { fg = mc.accent })
        hl(0, "DiagnosticInfo", { fg = mc.accent })
        hl(0, "DiagnosticHint", { fg = mc.accent })
        hl(0, "DiagnosticFloatingError", { fg = "#fb4934" })
        hl(0, "DiagnosticFloatingWarn", { fg = mc.accent })
        hl(0, "DiagnosticFloatingInfo", { fg = mc.accent })
        hl(0, "DiagnosticFloatingHint", { fg = mc.accent })
        hl(0, "DiagnosticSignError", { fg = "#fb4934" })
        hl(0, "DiagnosticSignWarn", { fg = mc.accent })
        hl(0, "DiagnosticSignInfo", { fg = mc.accent })
        hl(0, "DiagnosticSignHint", { fg = mc.accent })
        hl(0, "DiagnosticUnderlineError", { sp = "#fb4934", undercurl = true })
        hl(0, "DiagnosticUnderlineWarn", { sp = mc.accent, undercurl = true })
        hl(0, "DiagnosticUnderlineInfo", { sp = mc.accent, undercurl = true })
        hl(0, "DiagnosticUnderlineHint", { sp = mc.accent, undercurl = true })

        -- Mode Message (-- INSERT -- などのモード表示をゴールド化)
        hl(0, "ModeMsg", { fg = mc.accent, bold = true })

        -- Lazygit のアクティブ枠色
        hl(0, "LazygitActiveBorder", { fg = mc.accent, bold = true })

        -- Dashboard: matugen パレット
        --   ロゴ/起動メッセージ = secondary，アイコン = accent，メニュー文字 = text，
        --   キー割当 = tertiary，Quit = 赤系
        -- snacks は行別指定が効かない場合に基底グループで描くため、基底も上書きする
        hl(0, "SnacksDashboardHeader", { fg = mc.secondary, bold = true })
        for i = 1, 6 do
            hl(0, "SnacksDashboardHeader" .. i, { fg = mc.secondary, bold = true })
        end
        hl(0, "SnacksDashboardIcon", { fg = mc.accent })
        hl(0, "SnacksDashboardWhite", { fg = mc.text })
        hl(0, "SnacksDashboardKeyHint", { fg = mc.tertiary, bold = true })
        hl(0, "SnacksDashboardIconRed", { fg = "#c4746e" })
        hl(0, "SnacksDashboardFooter", { fg = mc.secondary })
        hl(0, "SnacksDashboardSpecial", { fg = mc.secondary })

        -- 対応する括弧のハイライトを matugen の accent 色に統一
        -- (他プラグインが同じ ColorScheme イベントで後からデフォルト色を
        --  再適用することがあるため，イベントループの最後に回して確実に勝たせる)
        vim.schedule(function()
            hl(0, "MatchParen", { fg = mc.accent, bold = true, underline = true })
        end)
    end,
})

-- キーマップ
vim.keymap.set("n", "<leader>cd", ":Ex<CR>", { desc = "Open Netrw Explorer" })

-- OS 別設定
if vim.fn.has("win32") == 1 then
    vim.opt.makeprg = "mingw32-make"
    -- Windows: シェルを PowerShell にする
    vim.opt.shell = "powershell.exe"
    vim.opt.shellcmdflag = "-NoProfile -NoLogo -NonInteractive -Command"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
else
    vim.opt.makeprg = "make"
    -- Linux / WSL: シェルは既定 (bash/zsh) のまま
end

-- ウィンドウ間の移動 (Ctrl+HJKL)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Navigate Left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Navigate Down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Navigate Up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Navigate Right" })

-- ビジュアルモードでインデント後も選択を維持
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left and Stay" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right and Stay" })

-- jk でインサートモードを抜ける
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })

-- 検索ハイライトの消去
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear Highlight" })

-- GitHub 上の KEYBINDINGS.md を開く
vim.keymap.set("n", "<leader>m", function()
    local url = "https://github.com/Naruto-Takahashi/dotfiles/blob/main/nvim/KEYBINDINGS.md"
    local cmd
    if vim.fn.has("win32") == 1 then
        cmd = "start " .. url
    else
        -- WSL / Linux: powershell.exe 経由で Windows 側のブラウザを開く
        cmd = string.format("powershell.exe -Command Start-Process '%s'", url)
    end
    vim.fn.jobstart(cmd, { detach = true })
end, { desc = "Open KEYBINDINGS.md on GitHub" })

-- ==========================================================================
--  Zenn Tools (Custom)
-- ==========================================================================
-- 既存の get-clip-img スクリプトを利用して、Windowsクリップボードの画像を
-- 現在のZenn記事プロジェクトの images ディレクトリに保存し、Markdownリンクを挿入します。

local function paste_zenn_image()
    -- プロジェクトルート検出（.gitがある場所、なければカレント）
    local root = vim.fs.dirname(vim.fs.find(".git", { path = vim.fn.expand("%:p:h"), upward = true })[1]) or
        vim.fn.getcwd()

    -- 現在のファイル名（拡張子なし）をslugとして取得
    local slug = vim.fn.expand("%:t:r")

    -- デフォルトファイル名の生成
    local date = os.date("%Y%m%d%H%M%S")
    local default_name

    -- slugが取得できればフォルダ分けする
    if slug and slug ~= "" then
        default_name = slug .. "/image-" .. date
    else
        default_name = "image-" .. date
    end

    -- ファイル名（パス）の入力
    vim.ui.input({ prompt = "Image name (under /images/): ", default = default_name }, function(input)
        if not input or input == "" then
            return -- キャンセルまたは空入力
        end

        -- 拡張子 .png がなければ付与（get-clip-imgがpngを出力するため）
        if not input:match("%.png$") then
            input = input .. ".png"
        end

        -- Zenn推奨の images ディレクトリ配下に保存
        local img_rel_path = "/images/" .. input
        local fullpath = root .. img_rel_path
        local img_dir = vim.fs.dirname(fullpath)

        -- ディレクトリが存在しない場合は作成
        if vim.fn.isdirectory(img_dir) == 0 then
            vim.fn.mkdir(img_dir, "p")
        end

        -- スクリプト実行
        local cmd = "get-clip-img " .. vim.fn.shellescape(fullpath)

        vim.notify("Saving image to " .. img_rel_path .. " ...", vim.log.levels.INFO)
        local result = vim.fn.system(cmd)

        if vim.v.shell_error == 0 then
            -- 成功時: 相対パスでMarkdownリンクを挿入
            local insert_text = "![](" .. img_rel_path .. ")"
            vim.api.nvim_put({ insert_text }, "c", true, true)
            vim.notify("Saved: " .. img_rel_path, vim.log.levels.INFO)
        else
            -- 失敗時
            vim.notify("Failed: " .. result, vim.log.levels.ERROR)
        end
    end)
end

-- キーバインド設定: <leader>ip
vim.keymap.set("n", "<leader>ip", paste_zenn_image, { desc = "Paste Image (Zenn/Custom)" })

-- ==========================================================================
--  TOhtml Auto-Save
-- ==========================================================================
vim.api.nvim_create_user_command("ToHtmlSave", function()
    -- 現在のファイルパスを取得
    local current_file = vim.fn.expand("%:p")
    local current_dir = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")

    if current_file == "" then
        vim.notify("No file associated with this buffer.", vim.log.levels.ERROR)
        return
    end

    -- HTMLファイル名を決定 (拡張子を .html に変更、なければ追加)
    local html_name = file_name:gsub("%.%w+$", "") .. ".html"
    if html_name == file_name then html_name = file_name .. ".html" end
    local output_path = current_dir .. "/" .. html_name

    -- TOhtml実行
    vim.cmd("TOhtml")

    -- 生成されたHTMLバッファで保存を実行
    vim.cmd("w! " .. vim.fn.fnameescape(output_path))

    -- HTMLバッファを閉じる（今のバッファがHTMLになっているので）
    vim.cmd("bd")

    vim.notify("HTML saved to: " .. output_path, vim.log.levels.INFO)
end, { desc = "Convert to HTML and save in the same directory" })

vim.keymap.set("n", "<leader>th", ":ToHtmlSave<CR>", { desc = "TOhtml and Save" })
