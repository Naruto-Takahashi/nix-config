-- nvim-web-devicons: 拡張子ごとの色を devicons 独自パレットではなく
-- matugen (kanagawa-dragon) パレットへ寄せる。カテゴリ分けは yazi の
-- modules/apps/yazi/theme-template.toml の [filetype] ルールと揃えてあり、
-- NeoTree / Telescope など devicons を使う箇所すべてに一貫して反映される。
return {
  "nvim-tree/nvim-web-devicons",
  config = function()
    local mc = require("matugen")
    local devicons = require("nvim-web-devicons")

    -- yazi の TRIAD 相当: Web/データ系 + 画像
    local triad_exts = {
      "js", "ts", "jsx", "tsx", "json", "jsonc", "yaml", "yml", "toml", "lock",
      "html", "htm", "css", "scss",
      "png", "jpg", "jpeg", "gif", "webp", "svg",
    }
    -- yazi の TERTIARY 相当: ドキュメント・テキスト・インフラ系
    local tertiary_exts = {
      "md", "pdf", "txt", "log", "csv", "docx", "doc", "xlsx", "xls",
      "pptx", "ppt", "ini", "tex", "bib", "nix", "sql", "exe", "out",
    }
    -- yazi の COMPLEMENT 相当: スクリプト・メディア系
    local complement_exts = {
      "py", "sh", "lua", "rb", "php", "pl",
      "mp4", "mkv", "avi", "mov", "webm", "mp3", "wav", "flac", "m4a", "ogg",
    }
    -- yazi の ERROR 相当: コンパイル言語・アーカイブ
    local error_exts = {
      "rs", "cpp", "c", "h", "hpp", "go", "java", "kt", "cs", "swift",
      "zip", "tar", "gz", "7z", "rar", "xz",
    }

    -- setup({override_by_extension=...}) は "loaded" ガードにより、他プラグインが
    -- 先に devicons を初期化していると無視されることがあるため、既存アイコンを保持した
    -- まま即時ハイライトを再生成する set_icon() を使う (実行順に依存しない)。
    local existing = devicons.get_icons()
    local override = {}
    local function apply(exts, color)
      for _, ext in ipairs(exts) do
        local icon = existing[ext]
        if icon then
          override[ext] = {
            icon = icon.icon,
            color = color,
            cterm_color = icon.cterm_color,
            name = icon.name,
          }
        end
      end
    end
    apply(triad_exts, mc.triad)
    apply(tertiary_exts, mc.tertiary)
    apply(complement_exts, mc.complement)
    apply(error_exts, mc.error)

    devicons.set_icon(override)
  end,
}
