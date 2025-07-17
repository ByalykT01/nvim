return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',

    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim', opts = {} },

    -- `nvim-jdtls` is a separate plugin that provides extra functionality for Java
    'mfussenegger/nvim-jdtls',
  },
  config = function()
    -- This is our new, reusable on_attach function.
    -- It will be used for every LSP server we configure.
    local on_attach = function(client, bufnr)
      vim.notify("LSP attached. Client: " .. client.name .. " (ID: " .. client.id .. ")", vim.log.levels.INFO)

      -- Enable completion triggered by typing
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      -- Keymaps now live inside the shared on_attach function.
      -- We use `vim.keymap.set` with the `buffer = bufnr` option
      -- to ensure these keymaps are local to the buffer.
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP: Hover Documentation', buffer = bufnr })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP: Go to Definition', buffer = bufnr })
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'LSP: Go to Declaration', buffer = bufnr })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'LSP: Go to Implementation', buffer = bufnr })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'LSP: Go to References', buffer = bufnr })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP: Rename', buffer = bufnr })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP: Code Action', buffer = bufnr })

      -- Diagnostic keymaps
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to Previous Diagnostic', buffer = bufnr })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to Next Diagnostic', buffer = bufnr })
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show Line Diagnostics', buffer = bufnr })
    end

    -- Configure mason-lspconfig
    require('mason-lspconfig').setup({
      ensure_installed = { 'jdtls' ,'ts_ls'}, -- Add other servers here later, e.g., "lua_ls", "rust_analyzer"
      handlers = {
        -- The first handler is the default handler.
        -- It will be called for every server that is not overridden below.
        function(server_name)
          require('lspconfig')[server_name].setup({
            on_attach = on_attach,
            -- `capabilities` will be defined in the next step when we add autocompletion
          })
        end,

        -- For jdtls, we need a custom handler because it requires special setup.
        ['jdtls'] = function()
          -- We use the same on_attach function here.
          require('jdtls').start_or_attach({
            cmd = {
              'java',
              '-Declipse.application=org.eclipse.jdt.ls.core.id1',
              '-Dosgi.bundles.defaultStartLevel=4',
              '-Declipse.product=org.eclipse.jdt.ls.core.product',
              '-Dlog.protocol=true',
              '-Dlog.level=ALL',
              '-Xmx1g',
              '--add-modules=ALL-SYSTEM',
              '--add-opens', 'java.base/java.util=ALL-UNNAMED',
              '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
              '-javaagent:' .. vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
              '-jar', vim.fn.glob(vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar')),
              '-configuration', vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/config_linux'),
              '-data', vim.fn.expand('~/.local/share/nvim/jdtls-workspace/') .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t'),
            },
            root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),
            on_attach = on_attach,
            -- `capabilities` will be defined in the next step
          })
        end,
      },
    })
  end,
}
