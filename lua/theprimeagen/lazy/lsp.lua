return {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP
        { 'j-hui/fidget.nvim', opts = {} },

        -- `nvim-jdtls` is a separate plugin that provides extra functionality for Java
        {
            'mfussenegger/nvim-jdtls',
            ft = "java",
            config = function()
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
                        '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
                        '-jar', vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
                        '-configuration', home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',
                        '-data', workspace_dir,
                    },
                    root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),
                    settings = {
                        java = {
                            eclipse = {
                                downloadSources = true,
                            },
                            configuration = {
                                updateBuildConfiguration = "interactive",
                            },
                            maven = {
                                downloadSources = true,
                            },
                            implementationsCodeLens = {
                                enabled = true,
                            },
                            referencesCodeLens = {
                                enabled = true,
                            },
                            references = {
                                includeDecompiledSources = true,
                            },
                            format = {
                                enabled = true,
                                settings = {
                                    url = vim.fn.stdpath "config" .. "/lang-servers/intellij-java-google-style.xml",
                                    profile = "GoogleStyle",
                                },
                            },
                        },
                        signatureHelp = { enabled = true },
                        completion = {
                            favoriteStaticMembers = {
                                "org.hamcrest.MatcherAssert.assertThat",
                                "org.hamcrest.Matchers.*",
                                "org.hamcrest.CoreMatchers.*",
                                "org.junit.jupiter.api.Assertions.*",
                                "java.util.Objects.requireNonNull",
                                "java.util.Objects.requireNonNullElse",
                                "org.mockito.Mockito.*",
                            },
                        },
                        contentProvider = { preferred = "fernflower" },
                        extendedClientCapabilities = require('jdtls').extendedClientCapabilities,
                        sources = {
                            organizeImports = {
                                starThreshold = 9999,
                                staticStarThreshold = 9999,
                            },
                        },
                        codeGeneration = {
                            toString = {
                                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                            },
                            useBlocks = true,
                        },
                    },
                    init_options = {
                        bundles = {}
                    },
                    on_attach = function(client, bufnr)
                        -- Enhanced formatting support for Java
                        client.server_capabilities.documentFormattingProvider = true
                        client.server_capabilities.documentRangeFormattingProvider = true

                        local opts = { buffer = bufnr, silent = true }

                        -- JDTLS specific mappings
                        vim.keymap.set('n', '<leader>jo', "<cmd>lua require'jdtls'.organize_imports()<cr>", opts)
                        vim.keymap.set('n', '<leader>jv', "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
                        vim.keymap.set('x', '<leader>jv', "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
                        vim.keymap.set('n', '<leader>jc', "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
                        vim.keymap.set('x', '<leader>jc', "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
                        vim.keymap.set('x', '<leader>jm', "<esc><Cmd>lua require('jdtls').extract_method(true)<cr>", opts)

                        -- Standard LSP mappings
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

                        -- Java-specific formatting mapping
                        vim.keymap.set('n', '<leader>f', function()
                            if vim.bo.filetype == 'java' then
                                vim.lsp.buf.format({ async = true })
                            else
                                require("conform").format({ async = true, lsp_fallback = true })
                            end
                        end, { desc = 'Format Java file', buffer = bufnr })
                    end,
                }

                require('jdtls').start_or_attach(config)
            end,
        },
    },
    config = function()
        -- Mason tool installer setup
        require('mason-tool-installer').setup({
            ensure_installed = {
                'jdtls',
                'ts_ls',
                'google-java-format',
                'prettier',
                'prettierd',
                'stylua',
            },
        })

        -- Global LSP attach function for non-Java files
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local bufnr = event.buf
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                -- Skip if this is JDTLS (handled separately)
                if client and client.name == 'jdtls' then
                    return
                end

                vim.notify("LSP attached. Client: " .. (client and client.name or "unknown"), vim.log.levels.INFO)
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                local opts = { buffer = bufnr, silent = true }
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
        })

        -- Configure mason-lspconfig for non-jdtls servers
        require('mason-lspconfig').setup({
            ensure_installed = { 'jdtls', 'ts_ls' },
            handlers = {
                function(server_name)
                    -- Skip jdtls as it's handled separately
                    if server_name == 'jdtls' then
                        return
                    end

                    require('lspconfig')[server_name].setup({})
                end,
            },
        })
    end,
}
