-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.textwidth = 80

-- Python type-checking LSP. Ruff handles lints + formatting regardless.
vim.g.lazyvim_python_lsp = "ty"
