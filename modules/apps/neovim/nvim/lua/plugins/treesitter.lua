-- =========================================================================
-- nvim-treesitter 設定プラグイン (main ブランチ / 新API)
-- =========================================================================
-- パーサー(.so)は Nix (modules/apps/neovim/default.nix) が
-- ~/.local/share/nvim/site/parser に供給するため、:TSInstall は不要。
-- 追加言語を試すときは tree-sitter CLI 経由で :TSInstall <lang> も使える。
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        config = function()
            require("nvim-treesitter").setup({
                -- Nix管理の site/parser (読み取り専用) と衝突しないよう、
                -- :TSInstall の書き込み先は別ディレクトリにする
                install_dir = vim.fn.stdpath("data") .. "/site-treesitter",
            })

            -- verilog ファイルタイプに systemverilog パーサーを対応付ける
            vim.treesitter.language.register("systemverilog", { "verilog" })

            -- パーサーが存在するバッファでハイライトとインデントを有効化
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    if not lang then
                        return
                    end
                    -- パーサーが無い言語では start が失敗するので pcall で握りつぶす
                    if not pcall(vim.treesitter.start, ev.buf, lang) then
                        return
                    end
                    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true, -- カーソルが対象より前にある場合、自動的にジャンプして選択
                },
                move = {
                    set_jumps = true, -- 移動履歴(jumplist)に残す
                },
            })

            -- テキストオブジェクトの選択
            local select = require("nvim-treesitter-textobjects.select")
            local function sel(query)
                return function()
                    select.select_textobject(query, "textobjects")
                end
            end
            vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "関数全体を選択" })
            vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "関数の中身を選択" })
            vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "クラス全体を選択" })
            vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "クラスの中身を選択" })

            -- テキストオブジェクト間の移動
            local move = require("nvim-treesitter-textobjects.move")
            local function mv(fn, query)
                return function()
                    move[fn](query, "textobjects")
                end
            end
            vim.keymap.set({ "n", "x", "o" }, "]m", mv("goto_next_start", "@function.outer"), { desc = "次の関数の先頭へ" })
            vim.keymap.set({ "n", "x", "o" }, "]]", mv("goto_next_start", "@class.outer"), { desc = "次のクラスの先頭へ" })
            vim.keymap.set({ "n", "x", "o" }, "]M", mv("goto_next_end", "@function.outer"), { desc = "次の関数の末尾へ" })
            vim.keymap.set({ "n", "x", "o" }, "][", mv("goto_next_end", "@class.outer"), { desc = "次のクラスの末尾へ" })
            vim.keymap.set({ "n", "x", "o" }, "[m", mv("goto_previous_start", "@function.outer"), { desc = "前の関数の先頭へ" })
            vim.keymap.set({ "n", "x", "o" }, "[[", mv("goto_previous_start", "@class.outer"), { desc = "前のクラスの先頭へ" })
            vim.keymap.set({ "n", "x", "o" }, "[M", mv("goto_previous_end", "@function.outer"), { desc = "前の関数の末尾へ" })
            vim.keymap.set({ "n", "x", "o" }, "[]", mv("goto_previous_end", "@class.outer"), { desc = "前のクラスの末尾へ" })
        end,
    },
}
