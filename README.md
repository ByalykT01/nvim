# Neovim config

Requires Neovim 0.12 or newer. Plugins are installed with Neovim's built-in
`vim.pack.add()` and pinned in `nvim-pack-lock.json`. On first startup, allow
Neovim to install them, then restart. Git, [ripgrep](https://github.com/BurntSushi/ripgrep),
the [tree-sitter CLI](https://tree-sitter.github.io/tree-sitter/), and a C
compiler enable the corresponding features. Language servers, formatters, and
debuggers are separate executables; install only those you use.

This config was originally based on [ThePrimeagen's config](https://github.com/ThePrimeagen/init.lua).
