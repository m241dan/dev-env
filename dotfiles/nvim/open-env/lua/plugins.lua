local path = vim.fn.stdpath("data") .. "/plugins/lazy.nvim"

vim.opt.rtp:append(path)

local plugins = {
   -- Telescope
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

   -- Tree-sitter
   {
       "nvim-treesitter/nvim-treesitter",
       build = ':TSUpdate',
   },

   -- Darcula Theme
   {
       "xiantang/darcula-dark.nvim",
       config = function()
           vim.cmd.colorscheme("darcula-dark")
       end,
   },
}

local options = {
    root = vim.fn.stdpath("data") .. "/plugins"
}

require("lazy").setup(plugins, options)

