local path = vim.fn.stdpath("data") .. "/plugins/lazy.nvim"

vim.opt.rtp:append(path)

local plugins = {
   -- Tree-sitter
   {
       'nvim-telescope/telescope.nvim',
       branch = '0.1.x',
       dependencies = {
           'nvim-lua/plenary.nvim',
           {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable('make') == 1
                end,
           },
       },
   },
}

local options = {
    root = vim.fn.stdpath("data") .. "/plugins"
}

require("lazy").setup(plugins, options)

