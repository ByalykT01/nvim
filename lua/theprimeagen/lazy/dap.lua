-- Full configuration for nvim-dap and its UI
-- Last updated: 2025-07-29 for user ByalykT01
return {
  -- Debug Adapter Protocol client for Neovim
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Installs DAP adapters automatically
    { 'williamboman/mason.nvim', opts = { ensure_installed = { 'java-debug-adapter' } } },

    -- UI for nvim-dap
    'rcarriga/nvim-dap-ui',
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    -- Setup for nvim-dap-ui
    dapui.setup({
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = 'single',
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
      controls = {
        enabled = true,
        element = 'repl',
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
        },
      },
    })

    -- Set up signs for breakpoints
    vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '➡️', texthl = '', linehl = 'DapStopped', numhl = '' })

    -- Open and close DAP UI based on events
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- Keymaps for debugging
    -- We revert F5 to the standard dap.continue(). After jdtls attaches and populates
    -- the configurations, this will automatically prompt you to choose a main class.
    vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'DAP: Continue / Start' })
    vim.keymap.set('n', '<F6>', function() require('dap').terminate() end, { desc = 'DAP: Terminate' })
    vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'DAP: Step Over' })
    vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'DAP: Step Into' })
    vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'DAP: Step Out' })
    vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'DAP: Toggle Breakpoint' })
    vim.keymap.set('n', '<Leader>B', function()
      require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = 'DAP: Set Conditional Breakpoint' })
    vim.keymap.set('n', '<Leader>du', function() require('dapui').toggle() end, { desc = 'DAP: Toggle UI' })
  end,
}
