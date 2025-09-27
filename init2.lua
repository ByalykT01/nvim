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
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

-- LSP
vim.lsp.enable({ "lua_ls", "ts_ls" })
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end
})
vim.cmd("set completeopt+=noselect")

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
