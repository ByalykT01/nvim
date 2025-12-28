vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4

vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.g.mapleader = " "

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set('n', "<leader>f", vim.lsp.buf.format)


vim.pack.add({
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/vague2k/vague.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/ThePrimeagen/harpoon",         version = "harpoon2" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/mfussenegger/nvim-jdtls" },
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

vim.lsp.enable({ "lua_ls", "jdtls" })

require 'telescope'.setup()
require 'oil'.setup({
    view_options = {
        show_hidden = true
    }
})

-- telescope
local builtin_telescope = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', builtin_telescope.find_files, {})
vim.keymap.set('n', '<leader>ps', builtin_telescope.live_grep, {})
vim.keymap.set('n', '<leader>vh', builtin_telescope.help_tags, {})

-- oil
vim.keymap.set('n', '<leader>pv', ":Oil<CR>")


-- jdtls
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    callback = function()
        local jdtls = require('jdtls')
        local java_home = os.getenv("JAVA_HOME")

        local root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
        local home = os.getenv("HOME")
        local jdtls_base_path = home ..
            '/.local/share/nvim/site/pack/core/opt/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository'
        local lombok_path = home .. '/.m2/repository/org/projectlombok/lombok/1.18.38/lombok-1.18.38.jar'
        local launcher_path = vim.fn.glob(jdtls_base_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
        local config_path = jdtls_base_path .. '/config_' .. (vim.fn.has('mac') == 1 and 'mac' or 'linux')

        local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
        local workspace_dir = home .. '/.cache/jdtls-workspace/' .. project_name

        local config = {
            cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xms1g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '-javaagent:' .. lombok_path,
                '-jar', launcher_path,
                '-configuration', config_path,
                '-data', workspace_dir,
            },
            root_dir = root_dir,
            --capabilities = require('cmp_nvim_lsp').default_capabilities(),

            settings = {
                java = {
                    signatureHelp = { enabled = true },
                    contentProvider = { preferred = 'fernflower' },
                    saveActions = { organizeImports = true },

                    -- Java 25 support
                    configuration = {
                        runtimes = {
                            {
                                name = "JavaSE-25",
                                path = java_home,
                                default = true,
                            },
                        },
                    },

                    -- Completion settings
                    completion = {
                        favoriteStaticMembers = {
                            "org.junit.Assert.*",
                            "org.junit.jupiter.api.Assertions.*",
                            "org.mockito.Mockito.*",
                            "java.util.Objects.requireNonNull",
                            "java.util.Objects.requireNonNullElse",
                        },
                        importOrder = {
                            "java",
                            "javax",
                            "com",
                            "org",
                        },
                        filteredTypes = {
                            "com.sun.*",
                            "io.micrometer.shaded.*",
                            "java.awt.*",
                            "jdk.*",
                            "sun.*",
                        },
                    },

                    -- Sources
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },

                    -- Code generation
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                        },
                        useBlocks = true,
                        hashCodeEquals = {
                            useInstanceof = true,
                            useJava7Objects = true,
                        },
                    },

                    -- Formatting
                    format = {
                        enabled = true,
                        settings = {
                            profile = "GoogleStyle",
                        },
                    },

                    -- Inlay hints
                    inlayHints = {
                        parameterNames = {
                            enabled = "all",
                        },
                    },

                    -- References and implementation code lens
                    referencesCodeLens = { enabled = true },
                    implementationsCodeLens = { enabled = true },
                },
            },

        }

        jdtls.start_or_attach(config)
    end,
})
