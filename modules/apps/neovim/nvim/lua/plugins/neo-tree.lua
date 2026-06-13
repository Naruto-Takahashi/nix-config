return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    window = {
      position = "left",
      width = 30,
      mappings = {
        ["<space>"] = "none",
        ["l"] = "open",
        ["h"] = "close_node",
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      hijack_netrw_behavior = "open_default", -- netrwを無効化し、サイドバーで開く
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true, -- 別のファイルに移ってもディレクトリを閉じない
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)
    
    -- <leader>e でファイルツリーの開閉（トグル）
    vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', {})
  end
}
