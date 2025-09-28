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

-- LSP
vim.lsp.enable({ "lua_ls", "ts_ls", "zls"})
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
    end, { desc = "Go to Previous Diagnostic", buffer = bufnr })
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1 })
    end, { desc = "Go to Next Diagnostic", buffer = bufnr })

    -- completion for lsp
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
vim.cmd("set completeopt+=noselect")


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

-- Style
vim.cmd("colorscheme rose-pine")
vim.cmd(":hi statusline guibg=NONE")
