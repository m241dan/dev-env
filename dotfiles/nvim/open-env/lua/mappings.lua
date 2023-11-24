vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)

-- Normal mode keymaps
vim.keymap.set('n', 'j', "<Left>")
vim.keymap.set('n', 'l', "<Right>")
vim.keymap.set('n', 'i', "<Up>")
vim.keymap.set('n', 'k', "<Down>")
vim.keymap.set('n', 'J', "<Home>")
vim.keymap.set('n', 'L', "<End>")
vim.keymap.set('n', 'I', "<C-u>zz")
vim.keymap.set('n', 'K', "<C-d>zz")

-- Insert mode keymaps
vim.keymap.set('n', '<C-I>', "<Insert>")
vim.keymap.set('i', '<C-D>', "<Esc>")

-- Visual mode keymaps
vim.keymap.set('v', 'j', "<Left>")
vim.keymap.set('v', 'l', "<Right>")
vim.keymap.set('v', 'i', "<Up>")
vim.keymap.set('v', 'k', "<Down>")
vim.keymap.set('v', 'J', "<Home>")
vim.keymap.set('v', 'L', "<End>")

-- Netrw
vim.api.nvim_create_autocmd('filetype', {
  pattern = 'netrw',
  desc = 'Better mappings for netrw',
  callback = function()
    vim.keymap.set('n', 'i', "<Up>", {remap = true, buffer = true})
  end
})

