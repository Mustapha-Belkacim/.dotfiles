-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-save buffer on various events
local auto_save_events = {
  "BufLeave",
  "FocusLost",
  "InsertLeave",
  "TextChanged",
  "TextChangedI",
}
vim.api.nvim_create_autocmd(auto_save_events, {
  callback = function()
    if vim.bo.modifiable and vim.bo.modified then
      vim.cmd("silent! write")
    end
  end,
})
