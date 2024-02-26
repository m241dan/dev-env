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
   "nvim-treesitter/playground",

   -- Color Scheming
   "rktjmp/lush.nvim",
   {
       "m241dan/ksd_theme",
       config = function()
           vim.cmd.colorscheme("ksd_theme")
       end,
   },

   -- LSP
   "neovim/nvim-lspconfig",
   {"j-hui/fidget.nvim", tag = 'legacy', opts = {}}, -- A progress bar for what the LSP is doing
   "folke/neodev.nvim", -- lsp support for lua when working on vim specific things

   -- Auto complete and snippet support
   "hrsh7th/nvim-cmp",
   "L3MON4D3/LuaSnip",
   "saadparwaiz1/cmp_luasnip",
   "hrsh7th/cmp-nvim-lsp",
   {
       "windwp/nvim-autopairs",
       event = "InsertEnter",
   },
   "lpoto/telescope-docker.nvim",

   -- Git plugins
   "lewis6991/gitsigns.nvim",

   -- CMake Tools
   "Civitasv/cmake-tools.nvim",

   -- Nav Buddy
   "MunifTanjim/nui.nvim",
   "SmiteshP/nvim-navic",
   "SmiteshP/nvim-navbuddy",

   -- Lsp Signatures (highlights things like which parameter you are on in a function call as you write it)
   {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
   },

   -- Notifications, Messages, and Commands
   {
       "folke/noice.nvim",
       event = "VeryLazy",
       opts = {},
       dependencies = {
           "MunifTanjim/nui.nvim",
           "rcarriga/nvim-notify",
       },
   }
}

local options = {
    root = vim.fn.stdpath("data") .. "/plugins"
}

require("lazy").setup(plugins, options)

