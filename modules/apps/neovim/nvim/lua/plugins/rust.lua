return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    ft = { 'rust' },
    dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap' },
    config = function()
      local mason_registry = require('mason-registry')
      
      local dap_adapter = nil
      
      local function setup_codelldb()
        local codelldb = mason_registry.get_package('codelldb')
        if not codelldb:is_installed() then
           return nil
        end
        
        local extension_path = codelldb:get_install_path() .. '/extension/'
        local codelldb_path = extension_path .. 'adapter/codelldb'
        local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'
        
        return require('rustaceanvim.config').get_codelldb_adapter(codelldb_path, liblldb_path)
      end

      local status, adapter = pcall(setup_codelldb)
      if status then
        dap_adapter = adapter
      end

      vim.g.rustaceanvim = {
        dap = {
          adapter = dap_adapter,
        },
        server = {
          on_attach = function(client, bufnr)
            vim.keymap.set('n', 'K', function() vim.cmd.RustLsp({'hover', 'actions'}) end, { buffer = bufnr })
            vim.keymap.set('n', '<leader>ca', function() vim.cmd.RustLsp('codeAction') end, { buffer = bufnr })

            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end,
          default_settings = {
            ['rust-analyzer'] = {
              check = {
                command = 'clippy',
              },
            },
          },
        },
      }
    end
  },
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    config = function()
        require('crates').setup()
    end,
  }
}