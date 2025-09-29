vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.winborder = "rounded"

vim.g.mapleader = " "

-- Binds
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Packer
vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/mfussenegger/nvim-jdtls" },
  { src = "https://github.com/mbbill/undotree" },
  { src = "https://github.com/JavaHello/spring-boot.nvim" },
  { src = "https://github.com/ThePrimeagen/harpoon",           version = "harpoon2" },
  { src = "https://github.com/zigtools/zls" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})

-- Filetype-to-Indentation Mapping
local indent_settings = {
  python = { tabstop = 4, shiftwidth = 4, expandtab = true },
  java = { tabstop = 4, shiftwidth = 4, expandtab = true },
  javascript = { tabstop = 2, shiftwidth = 2, expandtab = true },
  typescript = { tabstop = 2, shiftwidth = 2, expandtab = true },
  lua = { tabstop = 2, shiftwidth = 2, expandtab = true },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = vim.tbl_keys(indent_settings),
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    local settings = indent_settings[ft]
    if settings then
      vim.bo[ev.buf].tabstop = settings.tabstop
      vim.bo[ev.buf].shiftwidth = settings.shiftwidth
      vim.bo[ev.buf].expandtab = settings.expandtab
    end
  end,
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
local lspconfig = require('lspconfig') 
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.lua_ls.setup({ capabilities = capabilities })
lspconfig.ts_ls.setup({ capabilities = capabilities })
lspconfig.zls.setup({ capabilities = capabilities })

vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

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
-- vim.cmd("set completeopt+=noselect") -- Removed, as cmp.setup handles completeopt

-- jdtls

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local jdtls = require('jdtls')

    local root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
    local home = os.getenv("HOME")
    local jdtls_base_path = home .. '/.local/share/nvim/mason/packages/jdtls'
    local lombok_path = home .. '/.m2/repository/org/projectlombok/lombok/1.18.38/lombok-1.18.38.jar'
    local launcher_path = vim.fn.glob(jdtls_base_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
    local config_path = jdtls_base_path .. '/config_' .. (vim.fn.has('mac') == 1 and 'mac' or 'linux')

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
        '-data', vim.fn.expand('~/.cache/jdtls-workspace') .. '/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')
      },
      root_dir = root_dir,
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    jdtls.start_or_attach(config)
  end,
})

require('spring_boot').init_lsp_commands()

vim.lsp.config['jdtls'] = {
      init_options = {
        bundles = require("spring_boot").java_extensions(), -- Add Spring Boot extensions
      },
}
-- Packages
require 'telescope'.setup()
require 'oil'.setup()
require 'harpoon'.setup({
  settings = {
    save_on_toggle = true,
  },
  menu = {
    width = vim.api.nvim_win_get_width(0) - 4,
  },
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

-- spring boot
require('spring_boot').setup({
  lsp_fallback = true,
})

vim.keymap.set('n', '<leader>sb', function()
  require('telescope.builtin').lsp_workspace_symbols({
    query = '@',
  })
end, { desc = "Find Spring Beans" })

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
vim.cmd("colorscheme rose-pine")
vim.cmd(":hi statusline guibg=NONE")
