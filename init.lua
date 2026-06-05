vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.opt.guicursor = ""

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

-- Packer
vim.pack.add({
    { src = "https://github.com/vague2k/vague.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter",          version = "main" },
    { src = "https://github.com/mfussenegger/nvim-jdtls" },
    { src = "https://github.com/mbbill/undotree" },
    { src = "https://github.com/ThePrimeagen/harpoon",                     version = "harpoon2" },
    { src = "https://github.com/zigtools/zls" },
    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/mfussenegger/nvim-lint" },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/jackielii/gopls.nvim" },
    { src = "https://github.com/seblyng/roslyn.nvim" },
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/kndndrj/nvim-dbee" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    -- { src = "https://github.com/MrcJkb/haskell-tools.nvim" }
})

-- Set diagnostic display options
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
    },
})




-- LSP
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('gopls', {
    capabilities = capabilities,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                shadow = true,
                unusedwrite = true,
            },
            staticcheck = true,
            gofumpt = true, -- very popular choice nowadays
        },
    },
})

vim.lsp.config('html', {
    capabilities = capabilities,
})

vim.lsp.config('cssls', {
    capabilities = capabilities,
})

vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
})

vim.lsp.config('ts_ls', {
    capabilities = capabilities,
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            suggest = {
                completeFunctionCalls = true,
            },
            format = {
                indentSize = 2,
                tabSize = 2,
                convertTabsToSpaces = true,
            },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            suggest = {
                completeFunctionCalls = true,
            },
            format = {
                indentSize = 2,
                tabSize = 2,
                convertTabsToSpaces = true,
            },
        },
    },
})

vim.lsp.config('zls', { capabilities = capabilities })

vim.lsp.config('pyright', { capabilities = capabilities })

vim.lsp.config('hls', {
    capabilities = capabilities,
    cmd = { 'haskell-language-server-wrapper', '--lsp' },
})

vim.lsp.config('marksman', { capabilities = capabilities })

vim.lsp.enable({ 'lua_ls', 'ts_ls', 'zls', 'pyright', 'html', 'cssls', 'gopls', 'hls', 'marksman' })

local roslyn_cmd = (function()
    local home = os.getenv("HOME") or ""
    local log_args = { "--logLevel=Information", "--extensionLogDirectory=" .. vim.fn.stdpath("log"), "--stdio" }

    local bin_candidates = vim.tbl_filter(function(v) return v and v ~= "" end, {
        os.getenv("ROSLYN_LSP"),
        "Microsoft.CodeAnalysis.LanguageServer",
        home .. "/.local/share/roslyn/Microsoft.CodeAnalysis.LanguageServer",
    })
    for _, bin in ipairs(bin_candidates) do
        if vim.fn.executable(bin) == 1 then
            return vim.list_extend({ bin }, log_args)
        end
    end

    local dll = home .. "/.local/share/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll"
    if vim.fn.filereadable(dll) == 1 and vim.fn.executable("dotnet") == 1 then
        return vim.list_extend({ "dotnet", dll }, log_args)
    end

    return nil
end)()

if roslyn_cmd then
    vim.lsp.config('roslyn', {
        cmd = roslyn_cmd,
        capabilities = capabilities,
    })
    require('roslyn').setup({})
else
    vim.schedule(function()
        vim.notify(
            "roslyn: LSP binary not found. Install Microsoft.CodeAnalysis.LanguageServer to $PATH or ~/.local/share/roslyn/, or set $ROSLYN_LSP.",
            vim.log.levels.WARN
        )
    end)
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local bufnr = ev.buf

        -- keybinds for lsp
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = bufnr })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to Definition", buffer = bufnr })
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to Declaration", buffer = bufnr })
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation,
            { desc = "LSP: Go to Implementation", buffer = bufnr })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: Go to References", buffer = bufnr })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename", buffer = bufnr })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action", buffer = bufnr })
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float,
            { desc = "Show Line Diagnostics", buffer = bufnr })
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
            vim.diagnostic.open_float()
        end, { desc = "Go to Previous Diagnostic", buffer = bufnr })
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
            vim.diagnostic.open_float()
        end, { desc = "Go to Next Diagnostic", buffer = bufnr })
    end,
})


vim.api.nvim_create_autocmd('FileType', {
    pattern = { "html" },
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = "cs",
    callback = function()
        vim.bo.cindent = true
    end,
})

-- jdtls
local function jdtls_paths()
    local home = os.getenv("HOME") or ""
    local candidates = vim.tbl_filter(function(v) return v and v ~= "" end, {
        os.getenv("JDTLS_HOME"),
        home .. "/.local/share/jdtls",
        home .. "/.local/share/nvim/site/pack/core/opt/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository",
    })
    -- Antigravity Red Hat Java extension fallback (bundles a recent JDT.LS).
    vim.list_extend(candidates,
        vim.fn.glob(home .. "/.antigravity/extensions/redhat.java-*-linux-x64/server", false, true))

    local os_tag = vim.fn.has("mac") == 1 and "mac" or "linux"
    for _, base in ipairs(candidates) do
        local launcher = vim.fn.glob(base .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local config_dir = base .. "/config_" .. os_tag
        if launcher ~= "" and vim.fn.isdirectory(config_dir) == 1 then
            return { launcher = launcher, config = config_dir }
        end
    end
    return nil
end

local function latest_lombok_jar()
    local home = os.getenv("HOME") or ""
    local jars = vim.fn.glob(home .. "/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar", false, true)
    local main = vim.tbl_filter(function(p)
        return not (p:match("%-sources%.jar$") or p:match("%-javadoc%.jar$"))
    end, jars)
    table.sort(main)
    return main[#main]
end

local jdtls_group = vim.api.nvim_create_augroup("UserJdtls", { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = jdtls_group,
    pattern = 'java',
    callback = function()
        local paths = jdtls_paths()
        if not paths then
            vim.schedule(function()
                vim.notify(
                    "jdtls: launcher not found. Set $JDTLS_HOME or install to ~/.local/share/jdtls.",
                    vim.log.levels.WARN
                )
            end)
            return
        end

        local jdtls = require('jdtls')
        local java_home = os.getenv("JAVA_HOME")
        local home = os.getenv("HOME")
        local lombok = latest_lombok_jar()

        local root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
        local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
        local workspace_dir = home .. '/.cache/jdtls-workspace/' .. project_name

        local cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xms1g',
            '-Xmx4g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        }
        if lombok then
            table.insert(cmd, '-javaagent:' .. lombok)
        end
        vim.list_extend(cmd, {
            '-jar', paths.launcher,
            '-configuration', paths.config,
            '-data', workspace_dir,
        })

        local config = {
            cmd = cmd,
            root_dir = root_dir,
            capabilities = capabilities,

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

-- Packages
require 'telescope'.setup()
require 'oil'.setup({
    view_options = {
        show_hidden = true
    }
})
require 'harpoon'.setup({
    settings = {
        save_on_toggle = true,
    },
    menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
    },
})

-- Treesitter setup for Neovim 0.12 API
local treesitter = require('nvim-treesitter')
local treesitter_parsers = { "java", "typescript", "javascript", "tsx", "lua", "python", "zig", "json", "html", "css",
    "c_sharp", "haskell", "markdown", "markdown_inline" }

treesitter.setup()

if vim.fn.executable('tree-sitter') == 1 then
    local installed_parsers = treesitter.get_installed()
    local missing_parsers = vim.iter(treesitter_parsers)
        :filter(function(parser)
            return not vim.tbl_contains(installed_parsers, parser)
        end)
        :totable()

    if #missing_parsers > 0 then
        treesitter.install(missing_parsers)
    end
else
    vim.notify(
        "tree-sitter CLI is required for nvim-treesitter parser installs. Install it via your package manager.",
        vim.log.levels.WARN
    )
end

local treesitter_augroup = vim.api.nvim_create_augroup('UserTreesitter', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = treesitter_augroup,
    callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
            local lang = vim.treesitter.language.get_lang(args.match) or args.match
            local ok, query = pcall(vim.treesitter.query.get, lang, "indents")
            if ok and query then
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end
    end,
})

require('render-markdown').setup({
    completions = { lsp = { enabled = true } },
})

-- telescope
local builtin_telescope = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', builtin_telescope.find_files, {})
vim.keymap.set('n', '<leader>ps', builtin_telescope.live_grep, {})
vim.keymap.set('n', '<leader>vh', builtin_telescope.help_tags, {})

-- oil
vim.keymap.set('n', '<leader>pv', ":Oil<CR>")

-- undotree
vim.keymap.set('n', '<leader><F5>', ":UndotreeToggle<CR>")

-- harpoon
local function set_harpoon_keys()
    local keys = {
        {
            "<leader>H",
            function()
                require("harpoon"):list():add()
            end,
            desc = "Harpoon File",
        },
        {
            "<leader>h",
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            desc = "Harpoon Quick Menu",
        },
    }

    for i = 1, 5 do
        table.insert(keys, {
            "<leader>" .. i,
            function()
                require("harpoon"):list():select(i)
            end,
            desc = "Harpoon to File " .. i,
        })
    end

    for _, mapping in ipairs(keys) do
        vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping.desc })
    end
end

set_harpoon_keys()

-- Completion setup
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    completion = {
        completeopt = "menu,menuone,preview,noselect",
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    -- Keymappings are now set up to match ThePrimeagen's configuration
    mapping = cmp.mapping.preset.insert({
        -- Select the next and previous item
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),

        -- Scroll the documentation window
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- Trigger completion
        ["<C-Space>"] = cmp.mapping.complete(),

        -- Abort completion
        ["<C-e>"] = cmp.mapping.abort(),

        -- Accept the selected item
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),

        -- Tab completion to navigate snippets and suggestions
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    -- Completion sources, in order of priority
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    }),
    -- Formatting to add icons/text next to completion items
    formatting = {
        format = function(_, vim_item)
            vim_item.kind = string.format("%s", vim_item.kind)
            return vim_item
        end,
    },
    -- Bordered windows for a nicer UI
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})

-- Style
vim.cmd("colorscheme vague")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.cmd(":hi statusline guibg=NONE")

require("conform").setup({
    formatters_by_ft = {
        json = { "jq" },
        -- jq can't parse comments, so let the LSP handle jsonc
        jsonc = { lsp_format = "fallback" },
    },
    formatters = {
        jq = {
            -- keep 4-space indentation to match the rest of the config
            prepend_args = { "--indent", "4" },
        },
    },
    format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    },
})


require("dbee").setup()

local conform = require("conform")

-- Use real tabs in any file named Makefile or makefile
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "Makefile", "makefile", "*.mk", "GNUmakefile" },
    callback = function()
        vim.bo.expandtab   = false
        vim.bo.tabstop     = 8
        vim.bo.shiftwidth  = 8
        vim.bo.softtabstop = 8
    end,
})

-- Add manual format keymap (replaces your existing <leader>f)
vim.keymap.set({ "n", "v" }, "<leader>f", function()
    conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
    })
end, { desc = "Format file or range (in visual mode)" })

-- DAP (Debug Adapter Protocol) setup for C#
local dap = require('dap')
local dapui = require('dapui')

local function resolve_executable(candidates)
    for _, candidate in ipairs(candidates) do
        if vim.fn.executable(candidate) == 1 then
            return candidate
        end
    end

    return nil
end

local function get_dll_path()
    local cwd = vim.fn.getcwd()
    local debug_dlls = vim.fn.glob(cwd .. '/**/bin/Debug/**/*.dll', true, true)
    local default_path = debug_dlls[1] or (cwd .. '/bin/Debug/')

    return vim.fn.input('Path to dll: ', default_path, 'file')
end

local netcoredbg = resolve_executable({
    'netcoredbg',
    vim.fn.stdpath('data') .. '/mason/bin/netcoredbg',
    vim.fn.expand('~/.local/share/netcoredbg/netcoredbg'),
})

-- Configure the netcoredbg adapter for C#
dap.adapters.coreclr = {
    type = 'executable',
    command = netcoredbg or 'netcoredbg',
    args = { '--interpreter=vscode' }
}

-- C# debug configurations
dap.configurations.cs = {
    {
        type = "coreclr",
        name = "Launch - netcoredbg",
        request = "launch",
        program = get_dll_path,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        console = "integratedTerminal",
        env = {
            ASPNETCORE_ENVIRONMENT = "Development",
        },
    },
    {
        type = "coreclr",
        name = "Attach - netcoredbg",
        request = "attach",
        processId = require('dap.utils').pick_process,
    },
}

-- DAP UI Setup
dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    -- Expand lines larger than the window
    expand_lines = true,
    layouts = {
        {
            elements = {
                { id = "scopes",      size = 0.35 },
                { id = "breakpoints", size = 0.15 },
                { id = "stacks",      size = 0.25 },
                { id = "watches",     size = 0.25 },
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 },
            },
            size = 0.25,
            position = "bottom",
        },
    },
    controls = {
        enabled = true,
        element = "repl",
        icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "↩",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
        },
    },
    floating = {
        max_height = nil,
        max_width = nil,
        border = "rounded",
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    render = {
        max_type_length = nil,
        max_value_lines = 100,
        indent = 1,
    },
})

-- Automatically open/close DAP UI when debugging starts/ends
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

-- DAP Keymaps
vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = "DAP: Continue" })
vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = "DAP: Step Over" })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = "DAP: Step Into" })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = "DAP: Step Out" })
vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set('n', '<leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = "DAP: Conditional Breakpoint" })
vim.keymap.set('n', '<leader>dl', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, { desc = "DAP: Log Point" })
vim.keymap.set('n', '<leader>dr', function() dap.repl.toggle() end, { desc = "DAP: Toggle REPL" })
vim.keymap.set('n', '<leader>dc', function() dap.run_to_cursor() end, { desc = "DAP: Run to Cursor" })
vim.keymap.set('n', '<leader>dt', function() dap.terminate() end, { desc = "DAP: Terminate" })

-- DAP UI Keymaps
vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { desc = "DAP UI: Toggle" })
vim.keymap.set('n', '<leader>de', function() dapui.eval() end, { desc = "DAP UI: Evaluate" })
vim.keymap.set('v', '<leader>de', function() dapui.eval() end, { desc = "DAP UI: Evaluate Selection" })
vim.keymap.set('n', '<leader>df', function()
    dapui.float_element(nil, { enter = true })
end, { desc = "DAP UI: Float Element" })
vim.keymap.set('n', '<leader>dw', function()
    dapui.elements.watches.add(vim.fn.expand('<cword>'))
end, { desc = "DAP UI: Add Watch" })

-- DAP UI signs
vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '◐', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

-- Highlight groups for DAP signs
vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#f0a000' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d' })
vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#656565' })
