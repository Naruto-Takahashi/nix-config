return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 
          'nvim-lua/plenary.nvim',
          'nvim-telescope/telescope-ghq.nvim',
          { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
      config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        
        -- 拡張機能の設定
        telescope.setup({
          pickers = {
            find_files = {
              hidden = true,
              -- .git ディレクトリは除外する
              find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
            },
            live_grep = {
              additional_args = function(opts)
                return { "--hidden", "--glob", "!**/.git/*" }
              end,
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,                    -- false will only do exact matching
              override_generic_sorter = true,  -- override the generic sorter
              override_file_sorter = true,     -- override the file sorter
              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
            }
          }
        })

        -- 拡張機能の読み込み
        telescope.load_extension('ghq')
        telescope.load_extension('fzf')

        -- キーマッピングの設定
        -- <space>ff : ファイル名を検索
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        
        -- <space>fg : ファイル内の文字を検索 (要: ripgrep)
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        
        -- <space>fb : 開いているバッファを検索
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        
        -- <space>fh : ヘルプタグを検索
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

        -- <space>fq : ghq管理のリポジトリを検索
        vim.keymap.set('n', '<leader>fq', telescope.extensions.ghq.list, { desc = 'Telescope ghq list' })

        -- <space>fr : 最近開いたファイルを検索
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope recent files' })

        -- <space>fw : カーソル下の単語を検索
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope word under cursor' })

        -- <space>f. : 前回の検索を再開
        vim.keymap.set('n', '<leader>f.', builtin.resume, { desc = 'Telescope resume' })
      end
    }
}
