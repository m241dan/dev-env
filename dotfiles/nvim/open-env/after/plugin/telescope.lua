require('telescope').setup({
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    }
})

pcall(require('telescope').load_extension, 'fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>tsf', builtin.find_files, {desc = '[S]earch [F]iles'})
vim.keymap.set('n', '<leader>tsg', builtin.git_files, {desc = '[S]earch [G]it Files'})
vim.keymap.set('n', '<leader>tgf', builtin.live_grep, {desc = '[G]rep [F]iles'})
vim.keymap.set('n', '<leader>tgw', builtin.grep_string, {desc = '[G]rep [W]ord'})
vim.keymap.set('n', '<leader>tsb', builtin.buffers, {desc = '[S]earch [B]uffers'})
vim.keymap.set('n', '<leader>tsd', builtin.diagnostics, {desc = '[S]earch [D]iagnostics'})

