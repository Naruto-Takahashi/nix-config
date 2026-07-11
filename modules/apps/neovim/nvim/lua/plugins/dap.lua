return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- デバッグ用キーバインド (Space + d + ...)
      vim.keymap.set('n', '<Leader>dc', function() dap.continue() end, { desc = "Debug: Continue" })
      vim.keymap.set('n', '<Leader>dn', function() dap.step_over() end, { desc = "Debug: Step Over (Next)" })
      vim.keymap.set('n', '<Leader>di', function() dap.step_into() end, { desc = "Debug: Step Into" })
      vim.keymap.set('n', '<Leader>do', function() dap.step_out() end, { desc = "Debug: Step Out" })
      vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set('n', '<Leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Debug: Set Conditional Breakpoint" })
      vim.keymap.set('n', '<Leader>dt', function() dap.terminate() end, { desc = "Debug: Terminate" })
      vim.keymap.set('n', '<Leader>du', function() dapui.toggle() end, { desc = "Debug: Toggle UI" })

      -- F キーもフォールバックとして残す
      vim.keymap.set('n', '<F5>', function() dap.continue() end)
      vim.keymap.set('n', '<F10>', function() dap.step_over() end)
      vim.keymap.set('n', '<F11>', function() dap.step_into() end)
      vim.keymap.set('n', '<F12>', function() dap.step_out() end)
    end,
  }
}
