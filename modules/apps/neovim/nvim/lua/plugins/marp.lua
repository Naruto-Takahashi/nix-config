-- Marp (Markdown Presentation Ecosystem) スライドのプレビュー・書き出し
-- markdown-preview.nvim (render-markdown.nvim) はMarpのfrontmatter/スライド区切りを
-- 正しく解釈しないため，Marp専用のプラグインを別途用いる。
return {
  "nwiizo/marp.nvim",
  cmd = { "MarpWatch", "MarpStop", "MarpPreview", "MarpExport", "MarpThumbnail", "MarpTheme" },
  ft = { "markdown" },
  config = function()
    -- markdown-preview.lua と同じ理由 (WSLではPATHにcmd.exe/PowerShellが無い) で
    -- ブラウザを開く処理だけWSL用に上書きする。
    local is_wsl = vim.fn.has("wsl") == 1
      or (function()
        local f = io.open("/proc/version", "r")
        if not f then return false end
        local content = f:read("*a")
        f:close()
        return content:lower():find("microsoft") ~= nil
      end)()

    require("marp").setup({
      -- Nix (modules/apps/neovim/default.nix) が pkgs.marp-cli をPATHに供給しているため
      -- npx経由 (毎回ダウンロード) ではなくこちらを直接使う。
      marp_command = { "marp" },
      -- marp.nvim は browser (table) の末尾にURLを別引数として追加して vim.system() で
      -- 直接execする (シェルを介さない)。さらに html_file を開く際は
      -- vim.uri_from_fname() で file:///home/... というWSL内Linuxパスの
      -- URIを渡してくるが，Windows側のcmd.exe/ブラウザはこのパスを解決できない
      -- (wslpath -w で \\wsl.localhost\... UNC形式に変換する必要がある)。
      -- そのためbashラッパー経由でfile://を剥がしてwslpath変換してから
      -- cmd /c start に渡す。http(s)://のURL (server_mode時) はそのまま渡す。
      browser = is_wsl
          and {
            "bash",
            "-c",
            [[
              url="$1"
              case "$url" in
                file://*)
                  path="${url#file://}"
                  # printf %b で %XX 形式のURLエンコードをデコード
                  path=$(printf '%b' "${path//%/\\x}")
                  winpath=$(wslpath -w "$path")
                  /mnt/c/Windows/System32/cmd.exe /c start "" "$winpath"
                  ;;
                *)
                  /mnt/c/Windows/System32/cmd.exe /c start "" "$url"
                  ;;
              esac
            ]],
            "marp-open-wsl",
          }
        or nil,
    })
  end,
  keys = {
    { "<leader>mw", "<cmd>MarpWatch<cr>", desc = "Marp Watch (ライブプレビュー)", ft = "markdown" },
    { "<leader>ms", "<cmd>MarpStop<cr>", desc = "Marp Stop", ft = "markdown" },
    { "<leader>mp", "<cmd>MarpExport pptx<cr>", desc = "Marp Export -> pptx", ft = "markdown" },
  },
}
