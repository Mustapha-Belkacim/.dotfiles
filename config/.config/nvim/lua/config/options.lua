-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.colorcolumn = "120"

if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"
end

-- Disable unused remote-plugin providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
