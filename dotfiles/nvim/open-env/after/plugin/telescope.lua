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
vim.keymap.set('n', '<leader>sf', builtin.find_files, {desc = '[S]earch [F]iles'})

