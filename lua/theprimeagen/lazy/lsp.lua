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
        -- START of necessary changes to fix Lombok
        {
            'mfussenegger/nvim-jdtls',
            ft = "java", -- Load the plugin only for Java files
            config = function()
                -- This function runs when the plugin is loaded
                local home = os.getenv 'HOME'
                local workspace_path = home .. '/.local/share/nvim/jdtls-workspace/'
                local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
                local workspace_dir = workspace_path .. project_name

                local config = {
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
                        '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar', -- The critical line
                        '-jar', vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
                        '-configuration', home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',
                        '-data', workspace_dir,
                    },
                    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
                    -- on_attach is configured below in the main lspconfig setup
                    settings = {
                        java = {
                            -- Your original settings are preserved
                            signatureHelp = { enabled = true },
                            extendedClientCapabilities = require('jdtls').extendedClientCapabilities,
                            maven = { downloadSources = true },
                            referencesCodeLens = { enabled = true },
                            references = { includeDecompiledSources = true },
                            inlayHints = { parameterNames = { enabled = 'all' } },
                            format = { enabled = false },
                        },
                    },
                    init_options = {
                        bundles = {},
                    },
                }
                -- Start jdtls with our custom config
                require('jdtls').start_or_attach(config)
            end,
        },
        -- END of necessary changes
    },
    config = function()
        local on_attach = function(client, bufnr)
            vim.notify("LSP attached. Client: " .. client.name .. " (ID: " .. client.id .. ")", vim.log.levels.INFO)
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP: Hover Documentation', buffer = bufnr })
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP: Go to Definition', buffer = bufnr })
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'LSP: Go to Declaration', buffer = bufnr })
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'LSP: Go to Implementation', buffer = bufnr })
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'LSP: Go to References', buffer = bufnr })
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP: Rename', buffer = bufnr })
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP: Code Action', buffer = bufnr })
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to Previous Diagnostic', buffer = bufnr })
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to Next Diagnostic', buffer = bufnr })
            vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show Line Diagnostics', buffer = bufnr })
        end

        -- Configure mason-lspconfig for non-jdtls servers
        require('mason-lspconfig').setup({
            ensure_installed = { 'jdtls' ,'ts_ls'},
            handlers = {
                function(server_name)
                    -- Setup for all servers EXCEPT jdtls, which is now handled by its own plugin config
                    if server_name ~= 'jdtls' then
                        require('lspconfig')[server_name].setup({
                            on_attach = on_attach,
                        })
                    end
                end,
                -- No special handler for jdtls here anymore
            },
        })
    end,
}
