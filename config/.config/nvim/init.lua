-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")

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
