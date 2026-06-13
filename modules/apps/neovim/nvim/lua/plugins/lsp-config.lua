return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pylsp", "marksman", "clangd" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Neovim 0.11+ の新しい作法 (Reverted to original working state)
      
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- 1. 普通のサーバー (特別な設定不要)
      local servers = { "lua_ls", "marksman" }
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      -- pylsp の設定 (Line too long 警告を無効化 または 制限を緩和)
      vim.lsp.config["pylsp"] = vim.tbl_deep_extend("force", vim.lsp.config["pylsp"] or {}, {
        capabilities = capabilities,
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                enabled = true,
                maxLineLength = 120,
                ignore = { "E501", "W503", "W293", "E203" },
              },
              flake8 = {
                enabled = false,
              },
            },
          },
        },
      })
      vim.lsp.enable("pylsp")
      
      -- 2. clangd (C++) 個別設定
      local clangd_cmd = { "clangd", "--background-index" }
      local cxx_path = vim.fn.exepath("g++")
      if cxx_path == "" then
        cxx_path = vim.fn.exepath("clang++")
      end

      if cxx_path ~= "" then
        -- コンパイラが見つかれば、そのパスだけでなく全てのバージョンを許可するパターンを追加
        table.insert(clangd_cmd, "--query-driver=" .. cxx_path .. ",/usr/bin/g++*,/usr/bin/clang++*")
      end

      -- vim.lsp.config に設定を注入 (Neovim 0.11+ / nvim-lspconfig update 対応)
      -- 既存の設定があればマージ、なければ新規作成
      vim.lsp.config["clangd"] = vim.tbl_deep_extend("force", vim.lsp.config["clangd"] or {}, {
        capabilities = capabilities,
        cmd = clangd_cmd,
      })
      
      vim.lsp.enable("clangd")

      -- LspAttach の設定 (共通)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            client.capabilities = vim.tbl_deep_extend("force", client.capabilities, capabilities)
          end
        end,
      })

      -- キーマッピング (LSP関連)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

      -- 診断 (Diagnostics) 関連
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {})
      vim.keymap.set("n", "[d", function()
        if vim.diagnostic.jump then
          vim.diagnostic.jump({ count = -1 })
        else
          vim.diagnostic.goto_prev()
        end
      end, {})
      vim.keymap.set("n", "]d", function()
        if vim.diagnostic.jump then
          vim.diagnostic.jump({ count = 1 })
        else
          vim.diagnostic.goto_next()
        end
      end, {})
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, {})

      -- 診断の表示設定 (明示的に全ての波線とアイコンを有効化)
      vim.diagnostic.config({
        underline = true,
        virtual_text = true,
        signs = true,
        update_in_insert = false,
      })
    end,
  },
}