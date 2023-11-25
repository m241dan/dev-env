vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)

-- Normal mode keymaps
vim.keymap.set('n', '<leader><leader>', "<Insert>")
vim.keymap.set('n', 'j', "<Left>")
vim.keymap.set('n', 'l', "<Right>")
vim.keymap.set('n', 'i', "<Up>")
vim.keymap.set('n', 'k', "<Down>")
vim.keymap.set('n', 'J', "<Home>")
vim.keymap.set('n', 'L', "<End>")
vim.keymap.set('n', 'I', "<C-u>zz")
vim.keymap.set('n', 'K', "<C-d>zz")
vim.keymap.set('n', '<leader>di', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>di', "<cmd>lua vim.diagnostic.goto_prev()<CR><Insert>")
vim.keymap.set('n', '<leader>dk', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>dK', "<cmd>lua vim.diagnostic.goto_next()<CR><Insert>")
vim.keymap.set('n', '<C-i>', "<cmd>res +1<CR>") -- Grow current width height wise
vim.keymap.set('n', '<C-k>', "<cmd>res -1<CR>") -- Shrink current width height wise
vim.keymap.set('n', '<C-l>', "<cmd>vert res +1<CR>") -- Grow current window width wise
vim.keymap.set('n', '<C-j>', "<cmd>vert res -1<CR>") -- Shrink current window width wise
vim.keymap.set('n', '<leader>wi', "<C-W>k") -- Move to the window above of the current
vim.keymap.set('n', '<leader>wk', "<C-W>j") -- Move to the window below of the current
vim.keymap.set('n', '<leader>wl', "<C-W>l") -- Move to the window right of the current
vim.keymap.set('n', '<leader>wj', "<C-W>h") -- Move to the window left of the current

-- Insert mode keymaps
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

